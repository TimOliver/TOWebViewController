//
//  TOWebViewController.h
//
//  Copyright 2014 Timothy Oliver. All rights reserved.
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

#import <UIKit/UIKit.h>

@interface TOWebViewController : UIViewController <UIWebViewDelegate>

/**
 Initializes a new `TOWebViewController` object with the specified URL.
 
 @param url The URL to the web page that the controller will initially display.
 
 @return The newly initialized `TOWebViewController` object.
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 Initializes a new `TOWebViewController` object with the specified URL string.
 
 @param url The URL as a string, of the web page that the controller will initially display.
 
 @return The newly initialized `TOWebViewController` object.
 */
- (instancetype)initWithURLString:(NSString *)urlString;

/** 
 Get/set the current URL being displayed. (Will automatically start loading) 
 */
@property (nonatomic,strong)    NSURL *url;

/** 
 Get/set the request
 */
@property (nonatomic,strong)    NSMutableURLRequest *urlRequest;

/**
 The web view used to display the HTML content. You can access it through this
 read-only property if you need to anything specific, such as having it execute arbitrary JS code.
 
 @warning Usage of the web view's delegate property is reserved by this view controller. Do not set it to another object.
 */
@property (nonatomic,readonly)  UIWebView *webView;

/** 
 Shows a loading progress bar underneath the top navigation bar. 
 
 Default value is YES.
 */
@property (nonatomic,assign)    BOOL showLoadingBar;

/** 
 Shows the URL of the web request currently being loaded, before the page's title attribute becomes available.
 
 Default value is YES.
 */
@property (nonatomic,assign)    BOOL showUrlWhileLoading;

/** 
 The tint colour of the page loading progress bar.
 If not set on iOS 7 and above, the loading bar will defer to the app's global UIView tint color.
 If not set on iOS 6 or below, it will default to the standard system blue tint color.
 
 Default value is nil.
 */
@property (nonatomic,copy)      UIColor *loadingBarTintColor;

/**
 Hides all of the page navigation buttons, and on iPhone, hides the bottom toolbar.
 
 Default value is NO.
 */
@property (nonatomic,assign)    BOOL navigationButtonsHidden;

/**
 Shows the iOS 'Activty' button, which when tapped, presents a series of actions the user may
 take, including copying the page URL, tweeting the URL, or switching to Safari or Chrome.
 
 Default value is YES.
 */
@property (nonatomic,assign)    BOOL showActionButton;

/**
 Shows the Done button when presented modally. When tapped, it dismisses the view controller.

 Default value is YES.
 */
@property (nonatomic,assign)    BOOL showDoneButton;

/**
 When web pages are loaded, the view controller's title property will be set to the page's
 HTML title attribute.
 
 Default value is YES.
 */
@property (nonatomic,assign)    BOOL showPageTitles;

/** 
 Disables the contextual popups that can appear when the user taps and holds on a page link.
 
 Default value is NO.
 */
@property (nonatomic,assign)    BOOL disableContextualPopupMenu;

/** 
 Hides the default system background behind the outer bounds of the webview, and replaces it with
 a background color derived from the the page content currently being displayed by the web view.
 
 Default value is NO.
 */
@property (nonatomic,assign)    BOOL hideWebViewBoundaries;

/** 
 When the view controller is being presented as a modal popup, this block will be automatically performed
 right after the view controller is dismissed.
 */
@property (nonatomic,copy)      void (^modalCompletionHandler)(void);

/**
 An optional block that when set, will have each incoming web load request forwarded to it, and can
 determine whether to let them proceed or not.
 */
@property (nonatomic,copy)      BOOL (^shouldStartLoadRequestHandler)(NSURLRequest *request, UIWebViewNavigationType navigationType);

/** 
 This can be used to override the default tint color of the navigation button icons.
 */
@property (nonatomic,strong)    UIColor *buttonTintColor;

/** 
 On iOS 6 or below, this overrides the default opacity level of the bevel around the navigation buttons.
 */
@property (nonatomic,assign)    CGFloat buttonBevelOpacity;

@end
