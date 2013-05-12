//
//  TOModalWebViewController.m
//
//  Copyright 2013 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOModalWebViewController.h"
#import <QuartzCore/QuartzCore.h>

/* Navigation Bar Properties */
#define NAVIGATION_BUTTON_WIDTH     31
#define NAVIGATION_BUTTON_SIZE      CGSizeMake(31,31)
#define NAVIGATION_BUTTON_SPACING   5
#define NAVIGATION_BAR_HEIGHT       44.0f
#define NAVIGATION_TOGGLE_ANIM_TIME 0.3

/* The distance down from the top of the scrollview,
    that must be scrolled before the rotation animation
    aligns to the middle, and not along the top */
#define CONTENT_OFFSET_THRESHOLD    20

#pragma mark -
#pragma mark Hidden Properties/Methods
@interface TOModalWebViewController () <UIWebViewDelegate,UIScrollViewDelegate> {
    
    //Save the state for the web view before we rotate so we can properly align it after
    struct {
        CGSize     frameSize;
        CGSize     contentSize;
        CGPoint    contentOffset;
        CGFloat    zoomScale;
        CGFloat    minimumZoomScale;
        CGFloat    maximumZoomScale;
    } _webViewState;
}

/* Gradient layer added to the background view */
@property (nonatomic,strong) CAGradientLayer *gradientLayer;

/* Navigation bar shown along the top of the view */
@property (nonatomic,strong) UINavigationBar *navigationBar;

/* The web view where all the magic happens */
@property (nonatomic,strong) UIWebView *webView;

/* The loading bar, displayed when a page is being loaded */
@property (nonatomic,strong) UIImageView *loadingImageView;

/* A snapshot of the web view, shown when rotating */
@property (nonatomic,strong) UIImageView *webViewRotationSnapshot;

/* Buttons to be displayed on the left in the navigation bar*/
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *forwardButton;
@property (nonatomic,strong) UIButton *reloadStopButton;

/* The reload icon and stop icon will share the same icon */
@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

/* The dismissal button displayed on the right of the nav bar. */
@property (nonatomic,strong) UIButton *doneButton;

/* Methods to derive state information from the web view */
- (UIView *)webViewContentView;             //pull out the actual UIView used to display the web content
- (BOOL)webViewPageWidthIsDynamic;          //The page will rescale its own content if the web view frame is changed (ie DON'T play a zooming animation)
- (UIColor *)webViewPageBackgroundColor;    //try and determine the background colour of the current page
- (CGFloat)webViewActualZoomScale;          //since zoomScale is sometimes inaccurate, this derives the proper active zoom scale in relation to the window size

/* Review the current state of the web view and update the UI controls in the nav bar to match it */
- (void)refreshButtonsState;

/* Methods to contain all of the functionality needed to properly animate the UIWebView rotating */
- (void)setUpWebViewForRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration;
- (void)animateWebViewRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration;
- (void)restoreWebViewFromRotationFromOrientation:(UIInterfaceOrientation)fromOrientation;

/* Calcuate the necessary positions/dimensions to render a snapshot of the web view for animation */
- (CGRect)rectForVisibleRegionOfWebViewAnimatingToOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

/* Event callbacks for button taps */
- (void)backButtonTapped:(id)sender;
- (void)forwardButtonTapped:(id)sender;
- (void)reloadStopButtonTapped:(id)sender;
- (void)doneButtonTapped:(id)sender;

@end

// -------------------------------------------------------

#pragma mark -  
#pragma mark Class Implementation
@implementation TOModalWebViewController

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init])
    {
        self.url = url;
    }
    
    return self;
}

- (void)loadView
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //Create the all-encompassing container view
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    view.opaque = YES;
    self.view = view;
    
    //add a gradient to the background view
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[(id)[[UIColor colorWithWhite:0.0f alpha:0.0f] CGColor],(id)[[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor]];
    self.gradientLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.gradientLayer];
    
    //Create the web view
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-NAVIGATION_BAR_HEIGHT)];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.delegate = self;
    self.webView.contentMode = UIViewContentModeRedraw;
    self.webView.opaque = YES;
    [self.view addSubview:self.webView];
  
    //Create the navigation bar
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame),NAVIGATION_BAR_HEIGHT)];
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationBar];
    
    //Set up the custom skinning for the navigation bar
    UIImage *navigationBarImage = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebNavigationBarBG.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    [self.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    
    //set up custom styling for the navigation bar
    self.navigationBar.titleTextAttributes = @{UITextAttributeFont:[UIFont boldSystemFontOfSize:17.0f],
                                               UITextAttributeTextColor:[UIColor colorWithWhite:0.3f alpha:1.0f],
                                               UITextAttributeTextShadowOffset:[NSValue valueWithCGSize:CGSizeMake(0.0f,1.0f)],
                                               UITextAttributeTextShadowColor:[UIColor colorWithWhite:1.0f alpha:0.4f]};
  
    //Set up the loading image bar
    UIImage *loadingImage = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewLoadingBar.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 45)];
    self.loadingImageView = [[UIImageView alloc] initWithImage:loadingImage];
  
    //set up the buttons for the navigation bar
    CGRect buttonFrame; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    UIImage *buttonPressedImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewIconPressedBG.png"]];
    
    UIImage *backButtonImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewBackIcon.png"]];
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame: buttonFrame];
    [self.backButton setImage:backButtonImage forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    UIImage *forwardButtonImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewForwardIcon.png"]];
    self.forwardButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forwardButton setFrame:buttonFrame];
    [self.forwardButton setImage:forwardButtonImage forState:UIControlStateNormal];
    [self.forwardButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    self.reloadIcon = [[UIImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewRefreshIcon.png"]];
    self.stopIcon   = [[UIImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewStopIcon.png"]];
    
    self.reloadStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.reloadStopButton setFrame:buttonFrame];
    [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
    [self.reloadStopButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //remove the top and bottom shadows from the webview
    for (UIView *view in self.webView.scrollView.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]] && CGRectGetWidth(view.frame) == CGRectGetWidth(self.view.frame))
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    CGRect buttonFrame = CGRectZero; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    
    //set up the icons for the navigation bar
    UIView *iconsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (NAVIGATION_BUTTON_WIDTH*2)+NAVIGATION_BUTTON_SPACING, NAVIGATION_BUTTON_WIDTH)];
    iconsContainerView.backgroundColor = [UIColor clearColor];
    
    //add the back button
    self.backButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.backButton];
    
    //add the reload button
    buttonFrame.origin.x = NAVIGATION_BUTTON_WIDTH + NAVIGATION_BUTTON_SPACING;
    self.reloadStopButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.reloadStopButton];
    
    //add the forward button too, but keep it hidden for now
    self.forwardButton.frame = buttonFrame;
    self.forwardButton.hidden = YES;
    [iconsContainerView addSubview:self.forwardButton];
    
    //push the buttons on the left to this controller's navigation item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconsContainerView];

    //create the 'Done' button
    UIImage *doneButtonBG           = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewButtonBG.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    UIImage *doneButtonBGPressed    = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewButtonBGPressed.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Modal Web View Controller Close") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    [self.navigationItem.rightBarButtonItem setBackgroundImage:doneButtonBG forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setBackgroundImage:doneButtonBGPressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = @{UITextAttributeTextColor:[UIColor colorWithWhite:0.31f alpha:1.0f],
                                     UITextAttributeTextShadowOffset:[NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)],
                                     UITextAttributeTextShadowColor:[UIColor colorWithWhite:1.0f alpha:0.75f]};
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:textAttributes forState:UIControlStateHighlighted];
    
    //push the navigation item to the navigation bar
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    
    //Set the appropriate actions to the buttons
    [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self action:@selector(forwardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadStopButton addTarget:self action:@selector(reloadStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{ 
    //get the web view ready for rotation
    [self setUpWebViewForRotationToOrientation:toInterfaceOrientation withDuration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //reset the gradient layer's frame to match the new bounds
    self.gradientLayer.frame = self.view.bounds;
    
    //animate the web view snapshot into the proper place
    [self animateWebViewRotationToOrientation:toInterfaceOrientation withDuration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self restoreWebViewFromRotationFromOrientation:fromInterfaceOrientation];
}

#pragma mark -
#pragma mark WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self refreshButtonsState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshButtonsState];
    
    //set the navigation bar title
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshButtonsState];
}

#pragma mark -
#pragma mark Button Callbacks
- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
    [self refreshButtonsState];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
    [self refreshButtonsState];
}

- (void)reloadStopButtonTapped:(id)sender
{
    if (self.webView.isLoading)
        [self.webView stopLoading];
    else
        [self.webView reload];
    
    [self refreshButtonsState];
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Button State Handling
- (void)refreshButtonsState
{
  //Toggle the stop/reload button
  if (self.webView.isLoading == NO)
    [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
  else
    [self.reloadStopButton setImage:self.stopIcon forState:UIControlStateNormal];
  
  //update the state for the back button
  if (self.webView.canGoBack)
    [self.backButton setEnabled:YES];
  else
    [self.backButton setEnabled:NO];
  
  //update the state for the forward button
  if (self.webView.canGoForward && self.forwardButton.hidden)
  {
    UIView *containerView = self.forwardButton.superview;
    
    self.forwardButton.alpha = 0.0f;
    self.forwardButton.hidden = NO;
    
    [UIView animateWithDuration:NAVIGATION_TOGGLE_ANIM_TIME animations:^{
      //make the forward button visible
      self.forwardButton.alpha = 1.0f;
      
      //animate the container to accomodate
      CGRect frame = containerView.frame;
      frame.size.width = (NAVIGATION_BUTTON_WIDTH*3) + (NAVIGATION_BUTTON_SPACING*2);
      containerView.frame = frame;
      
      //move the reload buttons
      frame = self.reloadStopButton.frame;
      frame.origin.x = (NAVIGATION_BUTTON_WIDTH*2) + (NAVIGATION_BUTTON_SPACING*2);
      self.reloadStopButton.frame = frame;
    }];
  }
  
  if (self.webView.canGoForward == NO && self.forwardButton.hidden == NO)
  {
    UIView *containerView = self.forwardButton.superview;
    self.forwardButton.alpha = 1.0f;
    
    [UIView animateWithDuration:NAVIGATION_TOGGLE_ANIM_TIME animations:
     ^{
       //make the forward button invisible
       self.forwardButton.alpha = 0.0f;
       
       //animate the container to accomodate
       CGRect frame = containerView.frame;
       frame.size.width = (NAVIGATION_BUTTON_WIDTH*2) + (NAVIGATION_BUTTON_SPACING);
       containerView.frame = frame;
       
       //move the reload buttons
       frame = self.reloadStopButton.frame;
       frame.origin.x = (NAVIGATION_BUTTON_WIDTH) + (NAVIGATION_BUTTON_SPACING);
       self.reloadStopButton.frame = frame;
     }
    completion:^(BOOL completion)
     {
       self.forwardButton.hidden = YES;
     }];
  }
}

#pragma mark -
#pragma mark UIWebView Attrbutes
- (UIView *)webViewContentView
{
    //loop through the views inside the webview, and pull out the one that renders HTML content
    for (UIView *view in self.webView.scrollView.subviews)
    {
        if ([NSStringFromClass([view class]) rangeOfString:@"WebBrowser"].location != NSNotFound)
            return view;
    }
    
    return nil;
}

- (CGFloat)webViewActualZoomScale
{
    UIView *contentView = [self webViewContentView];
    return CGRectGetWidth(contentView.frame) / CGRectGetWidth(self.webView.frame);
}

- (BOOL)webViewPageWidthIsDynamic
{
    //A bit of a crazy JavaScript that scans the HTML for a <meta name="viewport"> tag and dumps its contents
    NSString *metaDataQuery =   @"(function() {"
                                    @"var metaTags = document.getElementsByTagName('meta');"
                                    @"for (i=0; i<metaTags.length; i++) {"
                                        @"if (metaTags[i].name=='viewport') {"
                                            @"return metaTags[i].getAttribute('content');"
                                        @"}"
                                    @"}"
                                @"})()";
    
    NSString *pageViewPortContent = [self.webView stringByEvaluatingJavaScriptFromString:metaDataQuery];
    if ([pageViewPortContent length] == 0)
        return NO;
    
    //remove all white space and make sure it's all lower case
    pageViewPortContent = [[pageViewPortContent stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    
    //check if the max page zoom is locked at 1
    if ([pageViewPortContent rangeOfString:@"maximum-scale=1"].location != NSNotFound)
        return YES;
    
    //check if zooming is intentionally disabled
    if ([pageViewPortContent rangeOfString:@"user-scalable=no"].location != NSNotFound)
        return YES;
    
    //check if width is set to align to the width of the device
    if ([pageViewPortContent rangeOfString:@"width=device-width"].location != NSNotFound)
        return YES;
    
    //check if initial scale is being forced (Apple seem to blanket apply this in Safari)
    if ([pageViewPortContent rangeOfString:@"initial-scale=1"].location != NSNotFound)
        return YES;
    
    return NO;
}

- (UIColor *)webViewPageBackgroundColor
{
    //Pull the current background colour from the web view
    NSString *rgbString = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getComputedStyle(document.body,null).getPropertyValue('background-color');"];
    
    //if it wasn't found, or if it isn't a proper rgb value, just return white as the default
    if ([rgbString length] == 0 || [rgbString rangeOfString:@"rgb"].location == NSNotFound)
        return [UIColor whiteColor];
    
    //Assuming now the input is either 'rgb(255, 0, 0)' or 'rgba(255, 0, 0, 255)'
    
    //remove the 'rgba' componenet
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"rgba" withString:@""];
    //conversely, remove the 'rgb' component
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"rgb" withString:@""];
    //remove the brackets
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@")" withString:@""];
    //remove all spaces
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //we should now have something like '0,0,0'. Split it up via the commas
    NSArray *componenets = [rgbString componentsSeparatedByString:@","];
    
    //Final output componenets
    CGFloat red, green, blue, alpha = 1.0f;
    
    //if the alpha value is 0, this indicates the RGB value wasn't actually set in the page, so just return white
    if ([componenets count] < 3 || ([componenets count] >= 4 && [[componenets objectAtIndex:3] integerValue] == 0))
        return [UIColor whiteColor];
    
    red     = (CGFloat)[[componenets objectAtIndex:0] integerValue] / 255.0f;
    green   = (CGFloat)[[componenets objectAtIndex:1] integerValue] / 255.0f;
    blue    = (CGFloat)[[componenets objectAtIndex:2] integerValue] / 255.0f;
    
    if ([componenets count] >= 4)
        alpha = (CGFloat)[[componenets objectAtIndex:3] integerValue] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark -
#pragma mark UIWebView Interface Rotation Handler
- (CGRect)rectForVisibleRegionOfWebViewAnimatingToOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect  rect          = CGRectZero;
    CGPoint contentOffset = self.webView.scrollView.contentOffset;
    CGSize  contentSize   = self.webView.scrollView.contentSize;
    CGSize  webViewSize   = self.webView.bounds.size;
    CGFloat heightInPortraitMode = webViewSize.width - CGRectGetHeight(self.navigationBar.frame);
    
    //we're in portrait now, target orientation is landscape
    //(So since we're zooming in, we don't need to worry about content outside the visible boundaries)
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        //save the current scroll offset and size of the web view
        rect.origin = contentOffset;
        rect.size = webViewSize;
    }
    else //rotating from landscape to portrait. We need to make sure we capture content outside the visible region and pan it back in
    {
        if ([self webViewPageWidthIsDynamic])
        {
            //set the content offset for the view to be rendered
            rect.origin = contentOffset;
            if (contentOffset.y + heightInPortraitMode > contentSize.height )
                rect.origin.y = contentSize.height - heightInPortraitMode;
          
            rect.size.width = webViewSize.width;
            rect.size.height = heightInPortraitMode; //make it as tall as it is wide
        }
        else
        {
            //set the scroll offset
            rect.origin = contentOffset;
            
            //The height of the region we're animating to, in the same space as the current content
            CGFloat scaledHeight = heightInPortraitMode * (webViewSize.width / webViewSize.height);
            
            //assume we're animating outwards with the visible region being the center.
            //so make sure to capture everything above and below it
            rect.origin.y = (contentOffset.y+(webViewSize.height*0.5f)) - (scaledHeight*0.5f);
            
            //if this takes us past the visible region, clamp it
            if (rect.origin.y < 0.0f) 
                rect.origin.y = 0.0f;
            else if (rect.origin.y + scaledHeight > contentSize.height)
                rect.origin.y = contentSize.height - scaledHeight;
            
            rect.size.width = webViewSize.width;
            rect.size.height = scaledHeight;
        }
    }
  
    return rect;
}

/* Called outside of the animation block. All of the views are currently in their 'before' state. */
- (void)setUpWebViewForRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration
{
    //if there's already a snapshot in place (shouldn't be possible), just in case, remove it
    if (self.webViewRotationSnapshot)
    {
        [self.webViewRotationSnapshot removeFromSuperview];
        self.webViewRotationSnapshot = nil;
    }
    
    //Save the current state so we can use it to properly translate after the rotation is complete
    _webViewState.frameSize         = self.webView.frame.size;
    _webViewState.contentSize       = self.webView.scrollView.contentSize;
    _webViewState.zoomScale         = self.webView.scrollView.zoomScale;
    _webViewState.contentOffset     = self.webView.scrollView.contentOffset;
    _webViewState.minimumZoomScale  = self.webView.scrollView.minimumZoomScale;
    _webViewState.maximumZoomScale  = self.webView.scrollView.maximumZoomScale;
    
    UIView *webContentView      = [self webViewContentView];
    UIColor *backgroundColor    = [self webViewPageBackgroundColor];
    CGRect renderBounds         = [self rectForVisibleRegionOfWebViewAnimatingToOrientation:toOrientation];
    
    //generate a snapshot of the webview that we can animate more smoothly
    //Don't enable Retina on iPads since the 3rd gen iPad can't handle it very well 
    UIGraphicsBeginImageContextWithOptions(renderBounds.size, YES, (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) ? 1.0f : 0.0f);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //fill the who canvas with the web page's background colour (otherwise default colour is black)
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, CGRectMake(0,0,CGRectGetWidth(renderBounds),CGRectGetHeight(renderBounds)));
        //offset the scroll view by the necessary amount
        CGContextTranslateCTM(context, -renderBounds.origin.x, -renderBounds.origin.y);
        //render the webview to the context
        [webContentView.layer renderInContext:context];
        //save the image to the image view
        self.webViewRotationSnapshot = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    }
    UIGraphicsEndImageContext();
    
    //work out the starting frame for the snapshot based on page state and current orientation
    CGRect frame = self.webView.frame;
  
    //If we're presently portrait, and animating to landscape
    if (UIInterfaceOrientationIsLandscape(toOrientation))
    {
        //If the current web page zoom is locked (eg, it's a mobile site), set an appropriate background colour and don't zoom the image
        if ([self webViewPageWidthIsDynamic])
        {
            self.webViewRotationSnapshot.backgroundColor = backgroundColor;
            self.webViewRotationSnapshot.contentMode = UIViewContentModeTop;
        }
    }
    else //if we're currently landscape and we're animating to portrait
    {
        //If the current web page zoom is locked like above, 
        if ([self webViewPageWidthIsDynamic])
        {
            self.webViewRotationSnapshot.backgroundColor = backgroundColor;
            
            //if the landscape scrolloffset is outside the bounds of the portrait mode, animate from the bottom to line it up properly
            CGFloat heightInPortraitMode = CGRectGetWidth(self.webView.frame) - CGRectGetHeight(self.navigationBar.frame);
            if (self.webView.scrollView.contentOffset.y + heightInPortraitMode > self.webView.scrollView.contentSize.height )
                self.webViewRotationSnapshot.contentMode = UIViewContentModeBottomLeft;
            else
                self.webViewRotationSnapshot.contentMode = UIViewContentModeTopLeft;
        }
        else
        {
            frame.size  = self.webViewRotationSnapshot.image.size;
            //position the webview in the center
            if( _webViewState.contentOffset.y > CONTENT_OFFSET_THRESHOLD )
                frame.origin.y  = CGRectGetMinY(self.webView.frame) + ((CGRectGetHeight(self.webView.frame)*0.5) - CGRectGetHeight(frame)*0.5);
        }
    }

    self.webViewRotationSnapshot.frame = frame;
  
    [self.view insertSubview:self.webViewRotationSnapshot belowSubview:self.navigationBar];
    
    //This is a dirty, dirty, DIRTY hack. When a UIWebView's frame changes (At least on iOS 6), in certain conditions,
    //the content view will NOT resize with it. This can result in visual artifacts, such as black bars up the side,
    //and weird touch feedback like not being able to properly zoom out until the user has first zoomed in and released the touch.
    //So far, the only way I've found to actually correct this is to invoke a trivial zoom animation, and this will
    //trip the webview into redrawing its content.
    //Once the view has finished rotating, we'll figure out the proper placement + zoom scale and reset it
    CGFloat zoomScale = (self.webView.scrollView.minimumZoomScale+self.webView.scrollView.maximumZoomScale) * 0.5f; //zoom into the mid point of the scale. Zooming into either extreme does nothing.
    self.webView.scrollView.layer.speed = 9999.0f;
    [self.webView.scrollView setZoomScale:zoomScale animated:YES];
    self.webView.hidden = YES;
}

/* Called within the animation block. All views will be set to their 'destination' state. */
- (void)animateWebViewRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration
{
    //remove all animations presently applied to the web view
    [self.webView.layer removeAllAnimations];
    [self.webView.scrollView.layer removeAllAnimations];
  
    //animate the image view rotating to the proper dimensions
    CGRect frame = self.webView.frame;
    
    //We only need to scale/translate the image view if the web page has a static width
    if ([self webViewPageWidthIsDynamic] == NO)
    {
        frame.size.height = CGRectGetWidth(self.webView.frame) * (CGRectGetHeight(self.webViewRotationSnapshot.frame)/CGRectGetWidth(self.webViewRotationSnapshot.frame));
        
        //If we're sufficiently scrolled down, animate towards the center of the view, not the top
        if (_webViewState.contentOffset.y > CONTENT_OFFSET_THRESHOLD)
        {
            frame.origin.y = (CGRectGetHeight(self.webView.frame)*0.5f) - (CGRectGetHeight(frame)*0.5f);
        }
    }
    
    self.webViewRotationSnapshot.frame = frame;
}

- (void)restoreWebViewFromRotationFromOrientation:(UIInterfaceOrientation)fromOrientation
{
    
    //Side Note: When a UIWebView has just had its bounds change, its minimumZoomScale and maximumZoomScale become completely (almost arbitrarily) different.
    //But, it WILL rest back to minimumZoomScale = 1.0f, after the next time the user interacts with it.
    //For resetting the state right now (as the user hasn't touched it yet), we must use the 'different' values, and translate the original state to them.
    //---
    //Sweet merciful crap. This hack is even dirtier than the one above. ಠ_ಠ
    //So we need to get the web view content to align to the new zoom scale. The transition NEEDS to be instant,
    //but we can't use animated:NO since that won't commit the zoom properly and cause visual glitches (ie HAS to be animated:YES).
    //So to solve this, we're accessing the core animation layer and temporarily increasing the animation speed of the scrollview.
    //The zoom event is still occurring, but it's so fast, it seems instant
    [self.webView.scrollView.layer removeAllAnimations];
    CGFloat translatedScale = ((_webViewState.zoomScale/_webViewState.minimumZoomScale) * self.webView.scrollView.minimumZoomScale);
    
    //if we ended up scrolling past the max zoom size, just extend it.
    if (translatedScale > self.webView.scrollView.maximumZoomScale)
        self.webView.scrollView.maximumZoomScale = translatedScale;
    
    self.webView.scrollView.layer.speed = 9999.0f;
    [self.webView.scrollView setZoomScale:translatedScale animated:YES];
    
    //Pull out the animation and attach a delegate so we can tell when it's finished, and jam it back in
    CABasicAnimation *anim = [[self.webView.scrollView.layer animationForKey:@"bounds"] mutableCopy];
    if (anim == nil)
    {
        [self animationDidStop:nil finished:YES];
        return;
    }
    
    [self.webView.scrollView.layer removeAnimationForKey:@"bounds"];
    [anim setDelegate:self];
    [self.webView.scrollView.layer addAnimation:anim forKey:@"bounds"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag == NO)
        return;
    
    //when the rotation and animation is complete, FINALLY unhide the web view
    self.webView.hidden = NO;
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    CGPoint translatedContentOffset = _webViewState.contentOffset;
    
    //if the page is a mobile site, just re-add the original content offset
    if ([self webViewPageWidthIsDynamic])
    {
        //if the content offset expands beyond the new boundary of the view, reset it
        translatedContentOffset.y = MIN(_webViewState.contentOffset.y, (contentSize.height - CGRectGetHeight(self.webView.frame)));
        translatedContentOffset.y = MAX(_webViewState.contentOffset.y, self.webView.scrollView.contentInset.top);
    }
    else //else, determine the magnitude we zoomed in/out by and translate the scroll offset to compensate
    {
        CGFloat magnitude = contentSize.width / _webViewState.contentSize.width;
        translatedContentOffset.x *= magnitude;
        translatedContentOffset.y *= magnitude;
        
        //if we were sufficiently scrolled from the top, make sure to line up to the middle, not the top
        if (_webViewState.contentOffset.y > CONTENT_OFFSET_THRESHOLD)
        {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
                translatedContentOffset.y += ((CGRectGetHeight(self.webViewRotationSnapshot.frame))*0.5f) - (CGRectGetHeight(self.webView.frame)*0.5f) + CGRectGetHeight(self.navigationBar.frame);
            else
                translatedContentOffset.y -= (CGRectGetHeight(self.webView.frame)*0.5f) - (((_webViewState.frameSize.height*magnitude)*0.5f) + CGRectGetHeight(self.navigationBar.frame));
        }   
            
        //clamp it to the actual scroll region
        translatedContentOffset.x = MAX(translatedContentOffset.x, self.webView.scrollView.contentInset.left);
        translatedContentOffset.x = MIN(translatedContentOffset.x, contentSize.width - CGRectGetWidth(self.webView.frame));
        
        translatedContentOffset.y = MAX(translatedContentOffset.y, self.webView.scrollView.contentInset.top);
        translatedContentOffset.y = MIN(translatedContentOffset.y, contentSize.height - CGRectGetHeight(self.webView.frame));
    }
    
    [self.webView.scrollView setContentOffset:translatedContentOffset animated:NO];
    
    //restore proper scroll speed
    self.webView.scrollView.layer.speed = 1.0f;
    
    //remove the rotation screenshot
    [self.webViewRotationSnapshot removeFromSuperview];
    self.webViewRotationSnapshot = nil;
}

@end
