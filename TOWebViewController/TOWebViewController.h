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

@interface TOWebViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURLString:(NSString *)urlString;

/* Get/set the current URL being displayed. (Will automatically start loading) */
@property (nonatomic,strong)    NSURL *url;

/* Show the loading progress bar (default YES) */
@property (nonatomic,assign)    BOOL showLoadingBar;

/* Show the URL while loading the page, i.e. before the page's <title> tag is available (default YES) */
@property (nonatomic,assign)    BOOL showUrlWhileLoading;

/* Tint colour for the loading progress bar. Default colour is iOS system blue. */
@property (nonatomic,copy)      UIColor *loadingBarTintColor;

/* Show all of the navigation/action buttons (ON by default) */
@property (nonatomic,assign)    BOOL navigationButtonsHidden;

/* Show the 'Action' button instead of the stop/refresh button (YES by default)*/
@property (nonatomic,assign)    BOOL showActionButton;

/* Disable the contextual popup that appears if the user taps and holds on a link. */
@property (nonatomic,assign)    BOOL disableContextualPopupMenu;

/* Hide the gray/linin background and all shadows and use the same colour as the current page */
@property (nonatomic,assign)    BOOL hideWebViewBoundaries;

/* When being presented as modal, this optional block can be performed after the users dismisses the controller. */
@property (nonatomic,copy)      void (^modalCompletionHandler)(void);

/* On iOS 6 or below, this can be used to override the default fill color of the navigation button icons */
@property (nonatomic,strong)    UIColor *buttonTintColor UI_APPEARANCE_SELECTOR;

/* On iOS 6 or below, this overrides the default opacity level of the bevel around the navigation buttons */
@property (nonatomic,assign)    CGFloat buttonBevelOpacity UI_APPEARANCE_SELECTOR;

@end
