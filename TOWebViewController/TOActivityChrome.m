//
//  TOActivityChrome.m
//
//  Copyright 2014 Timothy Oliver. All rights reserved.
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

#import "TOActivityChrome.h"

/* Detect if we're running iOS 7.0 or higher */
#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1  993.00
#endif
#define MINIMAL_UI (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)

/* Detect which user idiom we're running on */
#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TOActivityChrome ()

/* The URL to load */
@property (nonatomic, strong) NSURL *url;

+ (UIImage *)sharedActivityImage;

@end

@implementation TOActivityChrome

#pragma mark - Activity Display Properties -
- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"Chrome", @"TOWebViewControllerLocalizable", @"Open in Chrome Action");
}

- (UIImage *)activityImage
{
    return [TOActivityChrome sharedActivityImage];
}

#pragma mark - Activity Action Handlers -
- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Grab the first URL in the list
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSURL class]]) {
            self.url = (NSURL *)item;
            break;
        }
    }
}

- (void)performActivity
{
    if (self.url == nil) {
        [self activityDidFinish:NO];
        return;
    }
    
    NSURL *inputURL = self.url;
    NSString *scheme = inputURL.scheme;
    
    // Replace the URL Scheme with the Chrome equivalent.
    NSString *chromeScheme = nil;
    if ([scheme isEqualToString:@"http"]) {
        chromeScheme = @"googlechrome";
    } else if ([scheme isEqualToString:@"https"]) {
        chromeScheme = @"googlechromes";
    }
    
    // Proceed only if a valid Google Chrome URI Scheme is available.
    if (chromeScheme) {
        NSString *absoluteString = [inputURL absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme =
        [absoluteString substringFromIndex:rangeForScheme.location];
        NSString *chromeURLString =
        [chromeScheme stringByAppendingString:urlNoScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];

        // Open the URL with Chrome.
        [[UIApplication sharedApplication] openURL:chromeURL];
        [self activityDidFinish:YES];
        return;
    }
    
    [self activityDidFinish:NO];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]] == NO)
        return YES;
    
    //Check to see if there is an NSURL in the provided items
    BOOL containsURL = NO;
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSURL class]]) {
            containsURL = YES;
            break;
        }
    }
    
    return containsURL;
}

#pragma mark - Image Generation -
+ (UIImage *)sharedActivityImage
{
    static UIImage *sharedActivityImage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        UIColor *fillColor = [UIColor blackColor];
        
        if (IPAD) { //iPad
            if (MINIMAL_UI) {
                
            }
            else {
                UIGraphicsBeginImageContextWithOptions((CGSize){50, 50}, NO, [[UIScreen mainScreen] scale]);
                {
                    UIBezierPath* chromePadClassicPathPath = [UIBezierPath bezierPath];
                    [chromePadClassicPathPath moveToPoint: CGPointMake(25, 50)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(22.4, 49.86) controlPoint1: CGPointMake(24.12, 50) controlPoint2: CGPointMake(23.26, 49.95)];
                    [chromePadClassicPathPath addLineToPoint: CGPointMake(34.47, 32.31)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(36.97, 25) controlPoint1: CGPointMake(36.03, 30.29) controlPoint2: CGPointMake(36.97, 27.76)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(32.91, 16.02) controlPoint1: CGPointMake(36.97, 21.42) controlPoint2: CGPointMake(35.39, 18.22)];
                    [chromePadClassicPathPath addLineToPoint: CGPointMake(48.31, 16.02)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(50, 25) controlPoint1: CGPointMake(49.39, 18.81) controlPoint2: CGPointMake(50, 21.83)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(25, 50) controlPoint1: CGPointMake(50, 38.81) controlPoint2: CGPointMake(38.81, 50)];
                    [chromePadClassicPathPath closePath];
                    [chromePadClassicPathPath moveToPoint: CGPointMake(24.99, 13.02)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(13.12, 23.5) controlPoint1: CGPointMake(18.89, 13.02) controlPoint2: CGPointMake(13.86, 17.59)];
                    [chromePadClassicPathPath addLineToPoint: CGPointMake(4.54, 10.66)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(25, 0) controlPoint1: CGPointMake(9.06, 4.22) controlPoint2: CGPointMake(16.53, 0)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(46.93, 13) controlPoint1: CGPointMake(34.46, 0) controlPoint2: CGPointMake(42.68, 5.25)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(24.99, 13.02) controlPoint1: CGPointMake(46.93, 13) controlPoint2: CGPointMake(25.25, 13.02)];
                    [chromePadClassicPathPath closePath];
                    [chromePadClassicPathPath moveToPoint: CGPointMake(24.99, 15.97)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(34.02, 25) controlPoint1: CGPointMake(29.98, 15.97) controlPoint2: CGPointMake(34.02, 20.01)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(24.99, 34.03) controlPoint1: CGPointMake(34.02, 29.98) controlPoint2: CGPointMake(29.98, 34.03)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(15.97, 25) controlPoint1: CGPointMake(20.01, 34.03) controlPoint2: CGPointMake(15.97, 29.98)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(24.99, 15.97) controlPoint1: CGPointMake(15.97, 20.01) controlPoint2: CGPointMake(20.01, 15.97)];
                    [chromePadClassicPathPath closePath];
                    [chromePadClassicPathPath moveToPoint: CGPointMake(14.71, 31.12)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(24.99, 36.98) controlPoint1: CGPointMake(16.8, 34.62) controlPoint2: CGPointMake(20.62, 36.98)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(28.09, 36.56) controlPoint1: CGPointMake(26.07, 36.98) controlPoint2: CGPointMake(27.1, 36.82)];
                    [chromePadClassicPathPath addLineToPoint: CGPointMake(19.32, 49.33)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(0, 25) controlPoint1: CGPointMake(8.25, 46.75) controlPoint2: CGPointMake(0, 36.85)];
                    [chromePadClassicPathPath addCurveToPoint: CGPointMake(2.87, 13.39) controlPoint1: CGPointMake(0, 20.81) controlPoint2: CGPointMake(1.04, 16.86)];
                    [chromePadClassicPathPath addLineToPoint: CGPointMake(14.71, 31.12)];
                    [chromePadClassicPathPath closePath];
                    [fillColor setFill];
                    [chromePadClassicPathPath fill];
                    
                    sharedActivityImage = UIGraphicsGetImageFromCurrentImageContext();
                }
                UIGraphicsEndImageContext();
            }
        }
        else { //iPhone
            if (MINIMAL_UI) {
                
            }
            else {
                UIGraphicsBeginImageContextWithOptions((CGSize){40, 40}, NO, [[UIScreen mainScreen] scale]);
                {
                    //// ChromePhoneClassic Drawing
                    UIBezierPath* chromePhoneClassicPathPath = [UIBezierPath bezierPath];
                    [chromePhoneClassicPathPath moveToPoint: CGPointMake(20, 40)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(16.89, 39.73) controlPoint1: CGPointMake(18.94, 40) controlPoint2: CGPointMake(17.9, 39.89)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(27.84, 23.87)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(27.81, 23.85)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(29, 19.53) controlPoint1: CGPointMake(28.56, 22.58) controlPoint2: CGPointMake(29, 21.11)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(25.95, 12.99) controlPoint1: CGPointMake(29, 16.9) controlPoint2: CGPointMake(27.81, 14.56)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(38.71, 12.99)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(40, 20) controlPoint1: CGPointMake(39.53, 15.18) controlPoint2: CGPointMake(40, 17.53)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(20, 40) controlPoint1: CGPointMake(40, 31.05) controlPoint2: CGPointMake(31.05, 40)];
                    [chromePhoneClassicPathPath closePath];
                    [chromePhoneClassicPathPath moveToPoint: CGPointMake(37.83, 10.97)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(20, 0) controlPoint1: CGPointMake(34.53, 4.47) controlPoint2: CGPointMake(27.79, 0)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(4.54, 7.31) controlPoint1: CGPointMake(13.77, 0) controlPoint2: CGPointMake(8.21, 2.85)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(12.05, 18.57)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(20.22, 11.02) controlPoint1: CGPointMake(12.51, 14.41) controlPoint2: CGPointMake(15.97, 11.16)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(37.83, 10.97)];
                    [chromePhoneClassicPathPath closePath];
                    [chromePhoneClassicPathPath moveToPoint: CGPointMake(20.47, 12.99)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(20.49, 12.99)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(26.99, 19.51) controlPoint1: CGPointMake(24.08, 13) controlPoint2: CGPointMake(26.99, 15.91)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(20.48, 26.03) controlPoint1: CGPointMake(26.99, 23.11) controlPoint2: CGPointMake(24.07, 26.03)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(15.18, 23.27) controlPoint1: CGPointMake(18.29, 26.03) controlPoint2: CGPointMake(16.36, 24.93)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(15.01, 23.01)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(13.97, 19.51) controlPoint1: CGPointMake(14.36, 22) controlPoint2: CGPointMake(13.97, 20.8)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(20.47, 12.99) controlPoint1: CGPointMake(13.97, 15.91) controlPoint2: CGPointMake(16.88, 13)];
                    [chromePhoneClassicPathPath closePath];
                    [chromePhoneClassicPathPath moveToPoint: CGPointMake(13.81, 24.86)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(13.85, 24.84)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(20.49, 28.05) controlPoint1: CGPointMake(15.41, 26.79) controlPoint2: CGPointMake(17.8, 28.05)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(22.71, 27.74) controlPoint1: CGPointMake(21.26, 28.05) controlPoint2: CGPointMake(22, 27.94)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(14.74, 39.28)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(0, 20) controlPoint1: CGPointMake(6.25, 36.97) controlPoint2: CGPointMake(0, 29.22)];
                    [chromePhoneClassicPathPath addCurveToPoint: CGPointMake(3.27, 9.05) controlPoint1: CGPointMake(0, 15.96) controlPoint2: CGPointMake(1.21, 12.2)];
                    [chromePhoneClassicPathPath addLineToPoint: CGPointMake(13.81, 24.86)];
                    [chromePhoneClassicPathPath closePath];
                    [fillColor setFill];
                    [chromePhoneClassicPathPath fill];
                    
                    sharedActivityImage = UIGraphicsGetImageFromCurrentImageContext();
                }
                UIGraphicsEndImageContext();
            }
        }
    });
    
    return sharedActivityImage;
}


@end
