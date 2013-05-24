//
//  TOActionListPopoverView.m
//  TOModalWebViewControllerExample
//
//  Created by Tim Oliver on 13/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import "TOActionListPopoverView.h"
#import <QuartzCore/QuartzCore.h>

#define ARROW_SIZE      CGSizeMake(19,10)
#define POPUP_WIDTH     235
#define BUTTON_PADDING  8
#define BUTTON_HEIGHT   45
#define SCREEN_INSET    10

@interface TOActionListPopoverView ()

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
@property (nonatomic,strong)    UIView *backgroundView;

- (CGRect)setUpViewDisplayInTopLevelView:(UIView *)topLevelView;
- (void)setUpButtons;
- (void)itemButtonTapped:(id)sender;
- (void)backgroundViewTapped:(id)sender;
- (void)deviceOrientationChange:(id)sender;
- (void)dismissAnimated:(BOOL)animated;

@end

@implementation TOActionListPopoverView

- (id)initWithItems:(NSArray *)items
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 300, 300)])
    {
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowOffset = CGSizeMake(0.0f,5.0f);
        self.layer.shadowRadius = 10.0f;
        self.layer.shouldRasterize = YES;
        
        self.items = items;
        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

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
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [self.arrowImage drawInRect:drawRect];
}

- (void)presentPopoverFromView:(UIView *)view animated:(BOOL)animated
{
    self.anchorView = view;
    
    //Get the top level view to present the view in
    UIView *topLevelView = view.superview;
    while (topLevelView.superview != nil)
    {
        topLevelView = topLevelView.superview;
    }
    
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
    }];
    
    //set up an invisible background view to detect taps outside the popup
    self.backgroundView = [[UIView alloc] initWithFrame:topLevelView.frame];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //attach a gesture recognizer to detect taps
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
    [self.backgroundView addGestureRecognizer:tapRecognizer];
    
    //insert the background below the popup
    [topLevelView insertSubview:self.backgroundView belowSubview:self];
}

- (CGRect)setUpViewDisplayInTopLevelView:(UIView *)view
{
    CGRect frame = CGRectZero;
    
    NSInteger numberOfButtons = [self.items count];
    if (self.splitFirstTwoItems)
        numberOfButtons--;
    
    //work out the size
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
    else if (CGRectGetMaxX(frame) > (CGRectGetWidth(view.frame) - self.screenInset))
        newOffset = (CGRectGetWidth(view.frame) - self.screenInset) - CGRectGetWidth(frame);
    
    //Work out how much of an offset the arrow needs to be shifted
    self.arrowOffset = frame.origin.x - newOffset;
    
    //set the final x offset
    frame.origin.x = newOffset;
    
    return frame;
}

- (void)setUpButtons
{
    NSInteger i = 0;

    for (TOActionListItem *item in self.items)
    {
        NSInteger j = (self.splitFirstTwoItems && i > 1) ? i-1 : i;
        
        CGRect buttonFrame = CGRectZero;
        buttonFrame.size.width = CGRectGetWidth(self.frame) - (self.buttonPadding*2);
        buttonFrame.size.height = self.buttonHeight;
        buttonFrame.origin.x = self.buttonPadding;
        buttonFrame.origin.y = (self.arrowSize.height-1) + self.buttonPadding + ((self.buttonPadding+self.buttonHeight) * j);
        
        if (self.splitFirstTwoItems && i <= 1)
        {
            buttonFrame.size.width = (CGRectGetWidth(self.frame) - (self.buttonPadding*3)) * 0.5f;
        
            if (i == 1)
                buttonFrame.origin.y = (self.arrowSize.height-1) + self.buttonPadding;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = buttonFrame;
        button.reversesTitleShadowWhenHighlighted = YES;
        [button setBackgroundImage:self.buttonBGImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.buttonBGPressedImage forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(itemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor colorWithWhite:0.29f alpha:1.0f] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [button setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.6f] forState:UIControlStateNormal];
        button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        if ([item.title length])
            [button setTitle:item.title forState:UIControlStateNormal];
        else if (item.offImage)
            [button setImage:item.offImage forState:UIControlStateNormal];
        
        [self addSubview:button];
        
        i++;
    }
}

- (void)itemButtonTapped:(id)sender
{
    TOActionListItem *item = [self.items objectAtIndex:[(UIButton *)sender tag]];
    
    if (item.action)
        item.action();
    
    [self dismissAnimated:YES];
}

- (void)deviceOrientationChange:(id)sender
{
    [self dismissAnimated:NO];
}

- (void)backgroundViewTapped:(id)sender
{
    [self dismissAnimated:YES];
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

@end

// ---
// Popup Item
@implementation TOActionListItem

- (id)initWithTitle:(NSString *)title withTapAction:(TapAction)action
{
    if (self = [super init])
    {
        self.title = title;
        self.action = action;
    }

    return self;
}

@end