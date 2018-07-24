//
//  TOWebViewController.h
//
//  Copyright 2013-2018 Timothy Oliver. All rights reserved.
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

NS_ASSUME_NONNULL_BEGIN

@interface TOWebViewController : UIViewController <UIWebViewDelegate>

/**
 Initializes a new `TOWebViewController` object with the specified URL.
 
 @param url The URL to the web page that the controller will initially display.
 
 @return The newly initialized `TOWebViewController` object.
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 Initializes a new `TOWebViewController` object with the specified URL string.
 
 @param urlString The URL as a string, of the web page that the controller will initially display.
 
 @return The newly initialized `TOWebViewController` object.
 */
- (instancetype)initWithURLString:(NSString *)urlString;

/** 
 Get/set the current URL being displayed. (Will automatically start loading) 
 */
@property (nonatomic, strong)    NSURL *url;

/** 
 Get/set the request
 */
@property (nonatomic, strong)    NSMutableURLRequest *urlRequest;

/**
 The web view used to display the HTML content. You can access it through this
 read-only property if you need to anything specific, such as having it execute arbitrary JS code.
 
 @warning Usage of the web view's delegate property is reserved by this view controller. Do not set it to another object.
 */
@property (nonatomic, readonly)  UIWebView *webView;

/** 
 Shows a loading progress bar underneath the top navigation bar. 
 
 Default value is YES.
 */
@property (nonatomic, assign)    BOOL showLoadingBar;

/** 
 Shows the URL of the web request currently being loaded, before the page's title attribute becomes available.
 
 Default value is YES.
 */
@property (nonatomic, assign)    BOOL showUrlWhileLoading;

/** 
 The tint colour of the page loading progress bar.
 If not set on iOS 7 and above, the loading bar will defer to the app's global UIView tint color.
 If not set on iOS 6 or below, it will default to the standard system blue tint color.
 
 Default value is nil.
 */
@property (nonatomic, copy, nullable)      UIColor *loadingBarTintColor;

/**
 Hides all of the page navigation buttons, and on iPhone, hides the bottom toolbar.
 
 Default value is NO.
 */
@property (nonatomic, assign)    BOOL navigationButtonsHidden;

/**
 An array of `UIBarButtonItem` objects that will be inserted alongside the default navigation
 buttons.
 
 These buttons will remain visible, even if `navigationButtonsHidden` is set to YES.
 
 */
@property (nonatomic, copy, nullable)      NSArray *applicationBarButtonItems;

/**
 Unlike `applicationBarButtonItems`, `UIBarButtonItem` objects placed set here
 will ALWAYS remain on the left hand side of this controller's `UINavigationController`.
 */
@property (nonatomic, copy, nullable)   NSArray *applicationLeftBarButtonItems;

/**
 An array of `UIBarButtonItem` objects from `applicationBarButtonitems` that will
 disabled until pages are completely loaded.
 */
@property (nonatomic, copy, nullable)      NSArray *loadCompletedApplicationBarButtonItems;

/**
 Shows the iOS 'Activty' button, which when tapped, presents a series of actions the user may
 take, including copying the page URL, tweeting the URL, or switching to Safari or Chrome.
 
 Default value is YES.
 */
@property (nonatomic, assign)    BOOL showActionButton;

/**
 Shows the Done button when presented modally. When tapped, it dismisses the view controller.

 Default value is YES.
 */
@property (nonatomic, assign)    BOOL showDoneButton;

/** 
 If desired, override the title of the system 'Done' button to this string.
 
 Default value is nil.
 */
@property (nonatomic, copy, nullable)    NSString *doneButtonTitle;

/**
 When web pages are loaded, the view controller's title property will be set to the page's
 HTML title attribute.
 
 Default value is YES.
 */
@property (nonatomic, assign)    BOOL showPageTitles;

/**
 View controller's title property will be set to the page's host. www prefix will be stripped
 
 Default value is NO.
 */
@property (nonatomic, assign)    BOOL showPageHost;

/** 
 Disables the contextual popups that can appear when the user taps and holds on a page link.
 
 Default value is NO.
 */
@property (nonatomic, assign)    BOOL disableContextualPopupMenu;

/** 
 Hides the default system background behind the outer bounds of the webview, and replaces it with
 a background color derived from the the page content currently being displayed by the web view.
 
 Default value is NO.
 */
@property (nonatomic, assign)    BOOL hideWebViewBoundaries;

/** 
 When the view controller is being presented as a modal popup, this block will be automatically performed
 right after the view controller is dismissed.
 */
@property (nonatomic, copy, nullable)      void (^modalCompletionHandler)(void);

/**
 An optional block that when set, will have each incoming web load request forwarded to it, and can
 determine whether to let them proceed or not.
 */
@property (nonatomic, copy, nullable)      BOOL (^shouldStartLoadRequestHandler)(NSURLRequest *request, UIWebViewNavigationType navigationType);

/**
 An optional block that when set, will be triggered if the web view failed to load a frame.
 */
@property (nonatomic, copy, nullable)      void (^didFailLoadWithErrorRequestHandler)(NSError *error);

/**
An optional block that when set, will be triggered each time the web view has finished a load operation.
*/
@property (nonatomic, copy, nullable)      void (^didFinishLoadHandler)(UIWebView *webView);

/** 
 This can be used to override the default tint color of the navigation button icons.
 This property is mainly for iOS 6 and lower. Where possible, you should use iOS 7's proper color styling
 system instead.
 */
@property (nonatomic, strong, nullable)    UIColor *buttonTintColor;

/** 
 On iOS 6 or below, this overrides the default opacity level of the bevel around the navigation buttons.
 */
@property (nonatomic, assign)    CGFloat buttonBevelOpacity;

@end

NS_ASSUME_NONNULL_END
