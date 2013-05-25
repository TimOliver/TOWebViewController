//
//  TOWebViewControllerPopoverView
//
//  Copyright 2013 Timothy Oliver. All rights reserved.
//
//  Features logic designed by Satoshi Asano (ninjinkun) for NJKWebViewProgress,
//  also licensed under the MIT License. Re-implemented by Timothy Oliver.
//  https://github.com/ninjinkun/NJKWebViewProgress
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

#import "TOWebViewControllerPopoverView.h"
#import <QuartzCore/QuartzCore.h>

#define ARROW_SIZE      CGSizeMake(19,10)
#define POPUP_WIDTH     235
#define BUTTON_PADDING  8
#define BUTTON_HEIGHT   45
#define SCREEN_INSET    10

#define LEFT_HEADER_TAG     101
#define RIGHT_HEADER_TAG    102

@interface TOWebViewControllerPopoverView ()

/* Size of the arrow graphic, so positioning can be properly derived. */
@property (nonatomic,assign)    CGSize arrowSize;

/* Offset of arrow from the center of the view */
@property (nonatomic,assign)    CGFloat arrowOffset;

/* The gap between the buttons */
@property (nonatomic,assign)    CGFloat buttonPadding;

/* The height of each button. */
@property (nonatomic,assign)    CGFloat buttonHeight;

/* Inset within the screen of the popup */
@property (nonatomic,assign)    CGFloat screenInset;

/* Popup image assets */
@property (nonatomic,strong)    UIImage *arrowImage;
@property (nonatomic,strong)    UIImage *backgroundImage;
@property (nonatomic,strong)    UIImage *buttonBGImage;
@property (nonatomic,strong)    UIImage *buttonBGPressedImage;

@property (nonatomic,weak)      UIView  *anchorView;

/* Background view that when tapped, will dismiss the popup */
@property (nonatomic,strong)    UIControl *backgroundView;

- (CGRect)setUpViewDisplayInTopLevelView:(UIView *)topLevelView;
- (void)setUpButtons;
- (void)itemButtonTapped:(id)sender;
- (void)backgroundViewTapped:(id)sender;
- (void)deviceOrientationChange:(id)sender;
- (void)dismissAnimated:(BOOL)animated;

@end

@implementation TOWebViewControllerPopoverView

#pragma mark -
#pragma mark View Creation
- (id)init
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.layer.shadowColor      = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity    = 0.5f;
        self.layer.shadowOffset     = CGSizeMake(0.0f,5.0f);
        self.layer.shadowRadius     = 10.0f;
        self.layer.shouldRasterize  = YES;
        
        self.backgroundColor        = [UIColor clearColor];
        self.opaque                 = NO;
        
        self.arrowSize              = ARROW_SIZE;
        self.buttonPadding          = BUTTON_PADDING;
        self.buttonHeight           = BUTTON_HEIGHT;
        self.screenInset            = SCREEN_INSET;
        
        self.arrowImage             = [UIImage imageNamed:@"ModalWebViewPopupArrowTop.png"];
        self.backgroundImage        = [[UIImage imageNamed:@"ModalWebViewPopupViewBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(80, 15, 13, 15)];
        self.buttonBGImage          = [[UIImage imageNamed:@"ModalWebViewPopupButtonBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
        self.buttonBGPressedImage   = [[UIImage imageNamed:@"ModalWebViewPopupButtonPressedBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
        
        //attach a listener to let us know when the device is rotated
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    //remove the rotation detection listener
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark -
#pragma mark Background Drawing
- (void)drawRect:(CGRect)rect
{
    CGRect drawRect;
    
    //draw the background graphic
    drawRect.origin.x = 0.0f;
    drawRect.origin.y = self.arrowSize.height - 1;
    drawRect.size.width = CGRectGetWidth(self.frame);
    drawRect.size.height = CGRectGetHeight(self.frame) - drawRect.origin.y;
    [self.backgroundImage drawInRect:drawRect];
    
    //draw the arrow
    drawRect.size       = self.arrowSize;
    drawRect.origin.y   = 0.0f;
    drawRect.origin.x   = floorf(((CGRectGetWidth(self.frame)*0.5f) + self.arrowOffset) - (self.arrowSize.width*0.5f));
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy); //set to copy to completely override any visible arrow elements
    [self.arrowImage drawInRect:drawRect];
}

#pragma mark -
#pragma mark Presentation Setup
- (CGRect)setUpViewDisplayInTopLevelView:(UIView *)view
{
    CGRect frame = CGRectZero;
    
    NSInteger numberOfButtons = [self.items count];
    if (self.leftHeaderItem || self.rightHeaderItem)
        numberOfButtons++;
    
    //work out the size of the popoverview
    frame.size.width    = POPUP_WIDTH;
    
    frame.size.height   += (self.arrowSize.height-1);
    frame.size.height   += self.buttonPadding;
    frame.size.height   += (self.buttonHeight+self.buttonPadding) * numberOfButtons;
    
    CGRect convertedRect = [self.anchorView.superview convertRect:self.anchorView.frame toView:view];
    frame.origin.y = floorf(CGRectGetMaxY(convertedRect) - (CGRectGetHeight(convertedRect)*0.1f));
    frame.origin.x = floorf(CGRectGetMidX(convertedRect) - ((CGRectGetWidth(frame)*0.5f)));
    
    //see if the popup goes past the left hand threshold
    CGFloat newOffset = frame.origin.x;
    if (CGRectGetMinX(frame) < self.screenInset)
        newOffset = self.screenInset;
    else if (CGRectGetMaxX(frame) > (CGRectGetWidth(view.frame) - self.screenInset)) // or the right
        newOffset = (CGRectGetWidth(view.frame) - self.screenInset) - CGRectGetWidth(frame);
    
    //Work out how much of an offset the arrow needs to be shifted
    self.arrowOffset = frame.origin.x - newOffset;
    
    //set the final x offset
    frame.origin.x = newOffset;
    
    return frame;
}

- (void)setUpButtons
{
    NSMutableArray *buttonItems = [NSMutableArray arrayWithArray:self.items];
    
    // Move the special case items into the list so they can be built at the same time
    if (self.rightHeaderItem)
        [buttonItems addObject:self.rightHeaderItem];
    
    if (self.leftHeaderItem)
        [buttonItems addObject:self.leftHeaderItem];
    
    NSInteger i = 0;
    for (TOWebViewControllerPopoverViewItem *item in buttonItems)
    {
        CGRect buttonFrame = CGRectZero;
        
        //set up the special header items
        if (item == self.leftHeaderItem || item == self.rightHeaderItem)
        {
            buttonFrame.size.width = floorf((CGRectGetWidth(self.frame) - (self.buttonPadding*3)) * 0.5f);
            buttonFrame.size.height = self.buttonHeight;
            buttonFrame.origin.y = (self.arrowSize.height-1) + self.buttonPadding;
            
            if (item == self.leftHeaderItem)
                buttonFrame.origin.x = self.buttonPadding;
            else
                buttonFrame.origin.x = (self.buttonPadding*2) + buttonFrame.size.width;
        }
        else
        {
            //Offset all of the buttons by one if either of the header items are visible
            NSInteger offset = 0;
            if (self.leftHeaderItem || self.rightHeaderItem)
                offset = 1;
            
            buttonFrame.size.width = CGRectGetWidth(self.frame) - (self.buttonPadding*2);
            buttonFrame.size.height = self.buttonHeight;
            buttonFrame.origin.x = self.buttonPadding;
            buttonFrame.origin.y = (self.arrowSize.height-1) + self.buttonPadding + ((self.buttonPadding+self.buttonHeight)*(i+offset));
        }
        
        //set up the button view
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonFrame;
        button.reversesTitleShadowWhenHighlighted = YES;
        [button setBackgroundImage:self.buttonBGImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.buttonBGPressedImage forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(itemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor colorWithWhite:0.29f alpha:1.0f] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [button setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.6f] forState:UIControlStateNormal];
        button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        //assign the proper tag to the item's button
        if (item == self.leftHeaderItem)
            button.tag = LEFT_HEADER_TAG;
        else if (item == self.rightHeaderItem)
            button.tag = RIGHT_HEADER_TAG;
        else
            button.tag = i;
        
        //set up either title or image (and have title override image)
        if ([item.title length])
            [button setTitle:item.title forState:UIControlStateNormal];
        else if (item.image)
            [button setImage:item.image forState:UIControlStateNormal];
        
        //add the button to the view
        [self addSubview:button];
        
        //set ourselves back into the items, so they can pass update events to us
        item.popoverView = self;
        
        i++;
    }
}

#pragma mark -
#pragma mark Presentation/Dismissal
- (void)presentPopoverFromView:(UIView *)view animated:(BOOL)animated
{
    //hang onto the view we'll be pointing at
    self.anchorView = view;
    
    //Get the top level view to place the popover and background views in
    //(But not as high as the root window, else we lose the UIViewController benefits)
    UIView *topLevelView = view.superview;
    while ([topLevelView.superview isMemberOfClass:[UIWindow class]] == NO)
        topLevelView = topLevelView.superview;
    
    //work out the position+size of us, given the dimensions of the parent view
    self.frame = [self setUpViewDisplayInTopLevelView:topLevelView];
    
    //Now that our dimensions are sorted out, set up and insert all of the buttons
    [self setUpButtons];
    
    //animate the view fading in
    self.alpha = 0.0f;
    [topLevelView addSubview:self];
    
    CGFloat duration = animated ? 0.3f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1.0f;
    }completion:^(BOOL finished){
        //set up an invisible background view to detect taps outside the popup
        self.backgroundView = [[UIControl alloc] initWithFrame:topLevelView.bounds];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //attach an event callback to detect if the user 'touches up' inside the background view
        [self.backgroundView addTarget:self action:@selector(backgroundViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        //insert the background below the popup
        [topLevelView insertSubview:self.backgroundView belowSubview:self];
    }];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self.backgroundView removeFromSuperview];
    
    CGFloat duration = animated ? 0.3f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL complete) {
        [self removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark Event Handling
- (void)deviceOrientationChange:(id)sender
{
    [self dismissAnimated:NO];
}

- (void)backgroundViewTapped:(id)sender
{
    [self dismissAnimated:YES];
}

- (void)itemButtonTapped:(id)sender
{
    TOWebViewControllerPopoverViewItem *item = nil;
    NSInteger tag = [(UIButton *)sender tag];
    
    //get the appropriate item from the button that was tapped
    if (tag == LEFT_HEADER_TAG)
        item = self.leftHeaderItem;
    else if (tag == RIGHT_HEADER_TAG)
        item = self.rightHeaderItem;
    else if (tag < [self.items count])
        item = [self.items objectAtIndex:tag];
    
    if (item==nil)
        return;
    
    //execute the attached action
    if (item.action)
        item.action(item);
    
    //then dismiss ourselves
    [self dismissAnimated:YES];
}

@end

// ---
// Popup Item
@implementation TOWebViewControllerPopoverViewItem

- (id)initWithTitle:(NSString *)title withTapAction:(TapAction)action
{
    if (self = [super init])
    {
        self.title = title;
        self.action = action;
    }

    return self;
}

- (id)initWithImage:(UIImage *)image withTapAction:(TapAction)action
{
    if (self = [super init])
    {
        self.image = image;
        self.action = action;
    }
    
    return self;
}

@end