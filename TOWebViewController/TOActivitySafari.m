//
//  TOActivitySafari.m
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

#import "TOActivitySafari.h"

/* Detect if we're running iOS 7.0 or higher */
#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1  993.00
#endif
#define MINIMAL_UI (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)

/* Detect which user idiom we're running on */
#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TOActivitySafari ()

/* The URL to load */
@property (nonatomic, strong) NSURL *url;

+ (UIImage *)sharedActivityImage;

@end

@implementation TOActivitySafari

#pragma mark - Activity Display Properties -
- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"Safari", @"TOWebViewControllerLocalizable", @"Open in Safari Action");
}

- (UIImage *)activityImage
{
    return [TOActivitySafari sharedActivityImage];
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
    
    [[UIApplication sharedApplication] openURL:self.url];
    [self activityDidFinish:YES];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
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
                UIGraphicsBeginImageContextWithOptions((CGSize){53, 53}, NO, [[UIScreen mainScreen] scale]);
                {
                    UIBezierPath* safariPadMinimalPathPath = [UIBezierPath bezierPath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(26.5, 53)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(0, 26.5) controlPoint1: CGPointMake(11.86, 53) controlPoint2: CGPointMake(0, 41.14)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(26.5, 0) controlPoint1: CGPointMake(0, 11.86) controlPoint2: CGPointMake(11.86, 0)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(53, 26.5) controlPoint1: CGPointMake(41.14, 0) controlPoint2: CGPointMake(53, 11.86)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(26.5, 53) controlPoint1: CGPointMake(53, 41.14) controlPoint2: CGPointMake(41.14, 53)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(26.52, 0.99)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(0.99, 26.52) controlPoint1: CGPointMake(12.42, 0.99) controlPoint2: CGPointMake(0.99, 12.42)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(26.52, 52.05) controlPoint1: CGPointMake(0.99, 40.62) controlPoint2: CGPointMake(12.42, 52.05)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(52.05, 26.52) controlPoint1: CGPointMake(40.62, 52.05) controlPoint2: CGPointMake(52.05, 40.62)];
                    [safariPadMinimalPathPath addCurveToPoint: CGPointMake(26.52, 0.99) controlPoint1: CGPointMake(52.05, 12.42) controlPoint2: CGPointMake(40.62, 0.99)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(46.99, 27.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(46.99, 25.98)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(50.99, 25.98)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(50.99, 27.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(46.99, 27.05)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(47.97, 20.22)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(49.9, 19.7)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(50.15, 20.63)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(48.22, 21.15)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(47.97, 20.22)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(45.59, 14.84)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(47.32, 13.84)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(47.8, 14.68)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(46.07, 15.67)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(45.59, 14.84)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(9.07, 44.66)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(24.05, 22.89)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(44.6, 9.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(29.84, 28.58)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(9.07, 44.66)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(24.76, 23.66)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(13.27, 40.25)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(29.02, 27.93)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(24.76, 23.66)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(37.14, 6.79)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(38.14, 5.06)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(38.98, 5.54)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(37.98, 7.27)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(37.14, 6.79)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(31.65, 4.67)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(32.17, 2.74)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(33.1, 2.99)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(32.59, 4.92)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(31.65, 4.67)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(26.05, 2.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(27.02, 2.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(27.02, 6.04)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(26.05, 6.04)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(26.05, 2.05)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(19.71, 2.99)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(20.65, 2.74)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(21.17, 4.67)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(20.23, 4.92)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(19.71, 2.99)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(13.84, 5.54)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(14.68, 5.06)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(15.68, 6.79)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(14.84, 7.27)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(13.84, 5.54)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(8.81, 9.48)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(9.49, 8.8)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(10.9, 10.21)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(10.22, 10.9)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(8.81, 9.48)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(15.6, 46.27)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(14.6, 48)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(13.76, 47.52)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(14.76, 45.79)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(15.6, 46.27)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(21.08, 48.42)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(20.56, 50.35)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(19.62, 50.1)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(20.14, 48.17)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(21.08, 48.42)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(27.02, 50.98)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(26.05, 50.98)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(26.05, 46.99)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(27.02, 46.99)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(27.02, 50.98)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(33.19, 50.1)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(32.26, 50.35)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(31.74, 48.42)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(32.68, 48.17)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(33.19, 50.1)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(39.05, 47.52)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(38.22, 48)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(37.22, 46.27)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(38.05, 45.79)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(39.05, 47.52)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(44.09, 43.52)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(43.41, 44.21)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(41.99, 42.8)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(42.68, 42.11)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(44.09, 43.52)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(47.83, 38.34)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(47.35, 39.18)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(45.62, 38.18)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(46.1, 37.34)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(47.83, 38.34)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(50.15, 32.37)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(49.9, 33.3)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(47.97, 32.79)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(48.22, 31.85)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(50.15, 32.37)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(5.01, 14.68)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(5.5, 13.84)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(7.23, 14.84)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(6.74, 15.67)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(5.01, 14.68)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(2.67, 20.63)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(2.92, 19.7)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(4.85, 20.22)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(4.6, 21.15)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(2.67, 20.63)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(6.04, 27.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(2.05, 27.05)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(2.05, 25.98)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(6.04, 25.98)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(6.04, 27.05)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(4.84, 32.79)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(2.92, 33.3)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(2.66, 32.37)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(4.59, 31.85)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(4.84, 32.79)];
                    [safariPadMinimalPathPath closePath];
                    [safariPadMinimalPathPath moveToPoint: CGPointMake(7.2, 38.18)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(5.47, 39.18)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(4.98, 38.34)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(6.71, 37.34)];
                    [safariPadMinimalPathPath addLineToPoint: CGPointMake(7.2, 38.18)];
                    [safariPadMinimalPathPath closePath];
                    [fillColor setFill];
                    [safariPadMinimalPathPath fill];
                    
                    sharedActivityImage = UIGraphicsGetImageFromCurrentImageContext();
                }
                UIGraphicsEndImageContext();
            }
            else {
                UIGraphicsBeginImageContextWithOptions((CGSize){56, 56}, NO, [[UIScreen mainScreen] scale]);
                {
                    UIBezierPath* safariPadClassicPathPath = [UIBezierPath bezierPath];
                    [safariPadClassicPathPath moveToPoint: CGPointMake(4.52, 51.67)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(25.33, 24.55)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(52.42, 3.77)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(32.27, 31.1)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(4.52, 51.67)];
                    [safariPadClassicPathPath closePath];
                    [safariPadClassicPathPath moveToPoint: CGPointMake(29.11, 25.91)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(26.98, 28.01) controlPoint1: CGPointMake(27.93, 25.91) controlPoint2: CGPointMake(26.98, 26.85)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(29.11, 30.11) controlPoint1: CGPointMake(26.98, 29.17) controlPoint2: CGPointMake(27.93, 30.11)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(31.24, 28.01) controlPoint1: CGPointMake(30.29, 30.11) controlPoint2: CGPointMake(31.24, 29.17)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(29.11, 25.91) controlPoint1: CGPointMake(31.24, 26.85) controlPoint2: CGPointMake(30.29, 25.91)];
                    [safariPadClassicPathPath closePath];
                    [safariPadClassicPathPath moveToPoint: CGPointMake(28.17, 15.9)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(15.84, 28.2) controlPoint1: CGPointMake(21.36, 15.9) controlPoint2: CGPointMake(15.84, 21.41)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(16.55, 32.28) controlPoint1: CGPointMake(15.84, 29.63) controlPoint2: CGPointMake(16.1, 31)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(14.33, 35.13)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(12.87, 30.84) controlPoint1: CGPointMake(13.64, 33.81) controlPoint2: CGPointMake(13.15, 32.36)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(0, 28.02)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(12.82, 25.25)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(16.24, 18.03) controlPoint1: CGPointMake(13.31, 22.53) controlPoint2: CGPointMake(14.52, 20.05)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(13.14, 12.81)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(18.16, 16.14)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(25.16, 12.84) controlPoint1: CGPointMake(20.14, 14.5) controlPoint2: CGPointMake(22.53, 13.34)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(27.97, 0)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(30.74, 12.83)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(35, 14.22) controlPoint1: CGPointMake(32.24, 13.1) controlPoint2: CGPointMake(33.68, 13.56)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(31.94, 16.49)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(28.17, 15.9) controlPoint1: CGPointMake(30.75, 16.11) controlPoint2: CGPointMake(29.48, 15.9)];
                    [safariPadClassicPathPath closePath];
                    [safariPadClassicPathPath moveToPoint: CGPointMake(28.17, 40.49)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(40.5, 28.2) controlPoint1: CGPointMake(34.98, 40.49) controlPoint2: CGPointMake(40.5, 34.98)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(39.92, 24.49) controlPoint1: CGPointMake(40.5, 26.9) controlPoint2: CGPointMake(40.29, 25.66)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(42.11, 21.56)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(43.25, 25.16) controlPoint1: CGPointMake(42.63, 22.69) controlPoint2: CGPointMake(43.01, 23.9)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(56, 27.92)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(43.3, 30.7)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(40.1, 37.68) controlPoint1: CGPointMake(42.83, 33.31) controlPoint2: CGPointMake(41.71, 35.69)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(43.16, 42.8)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(38.28, 39.57)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(30.84, 43.18) controlPoint1: CGPointMake(36.22, 41.38) controlPoint2: CGPointMake(33.66, 42.66)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(28.07, 56)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(25.26, 43.16)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(21.29, 41.87) controlPoint1: CGPointMake(23.87, 42.9) controlPoint2: CGPointMake(22.53, 42.47)];
                    [safariPadClassicPathPath addLineToPoint: CGPointMake(24.07, 39.78)];
                    [safariPadClassicPathPath addCurveToPoint: CGPointMake(28.17, 40.49) controlPoint1: CGPointMake(25.35, 40.23) controlPoint2: CGPointMake(26.73, 40.49)];
                    [safariPadClassicPathPath closePath];
                    [fillColor setFill];
                    [safariPadClassicPathPath fill];
                    
                    sharedActivityImage = UIGraphicsGetImageFromCurrentImageContext();
                }
                UIGraphicsEndImageContext();
            }
        }
        else { //iPhone
            if (MINIMAL_UI) {
                UIGraphicsBeginImageContextWithOptions((CGSize){39, 39}, NO, [[UIScreen mainScreen] scale]);
                {
                    UIBezierPath* safariPhoneMinimalPath = [UIBezierPath bezierPath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(19.5, 39)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(0, 19.5) controlPoint1: CGPointMake(8.73, 39) controlPoint2: CGPointMake(0, 30.27)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(19.5, 0) controlPoint1: CGPointMake(0, 8.73) controlPoint2: CGPointMake(8.73, 0)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(39, 19.5) controlPoint1: CGPointMake(30.27, 0) controlPoint2: CGPointMake(39, 8.73)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(19.5, 39) controlPoint1: CGPointMake(39, 30.27) controlPoint2: CGPointMake(30.27, 39)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(32.73, 6.53)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(32.68, 6.56)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(19.51, 1.04) controlPoint1: CGPointMake(29.33, 3.16) controlPoint2: CGPointMake(24.67, 1.04)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(1.04, 19.51) controlPoint1: CGPointMake(9.31, 1.04) controlPoint2: CGPointMake(1.04, 9.31)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(6.6, 32.72) controlPoint1: CGPointMake(1.04, 24.69) controlPoint2: CGPointMake(3.17, 29.36)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(6.59, 32.74)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(6.61, 32.72)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(19.51, 37.99) controlPoint1: CGPointMake(9.94, 35.98) controlPoint2: CGPointMake(14.49, 37.99)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(37.99, 19.51) controlPoint1: CGPointMake(29.72, 37.99) controlPoint2: CGPointMake(37.99, 29.72)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(32.7, 6.58) controlPoint1: CGPointMake(37.99, 14.47) controlPoint2: CGPointMake(35.97, 9.91)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(32.73, 6.53)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(36.96, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(35.03, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.03, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.03, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(35.03, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(36.96, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(37.03, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(37.03, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(36.96, 20.02)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(34.38, 15.12)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(36.31, 14.6)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(36.55, 15.48)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.61, 15.99)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.38, 15.12)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(32.72, 11.43)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.45, 10.43)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.9, 11.21)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(33.17, 12.22)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(32.72, 11.43)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(34.92, 27.92)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.47, 28.7)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(32.73, 27.7)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(33.19, 26.92)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.92, 27.92)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(34.62, 23.13)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(36.56, 23.65)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(36.32, 24.53)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.39, 24.01)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(34.62, 23.13)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(30.18, 30.84)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(30.82, 30.2)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(32.24, 31.61)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(31.6, 32.26)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(30.18, 30.84)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(26.9, 33.21)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(27.69, 32.76)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(28.69, 34.49)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(27.9, 34.94)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(26.9, 33.21)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(23.12, 34.65)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(24, 34.42)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(24.52, 36.35)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(23.64, 36.59)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(23.12, 34.65)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(19.07, 34.1)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.98, 34.1)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.98, 37.04)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.07, 37.04)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.07, 34.1)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(14.56, 36.35)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(15.08, 34.42)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(15.96, 34.65)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(15.44, 36.59)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(14.56, 36.35)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(10.39, 34.49)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(11.39, 32.76)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(12.18, 33.21)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(11.18, 34.94)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(10.39, 34.49)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(6.61, 32.72)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(6.6, 32.72) controlPoint1: CGPointMake(6.6, 32.72) controlPoint2: CGPointMake(6.6, 32.72)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(17.71, 16.82)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(32.68, 6.56)];
                    [safariPhoneMinimalPath addCurveToPoint: CGPointMake(32.7, 6.58) controlPoint1: CGPointMake(32.69, 6.57) controlPoint2: CGPointMake(32.69, 6.57)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(21.87, 20.9)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(6.61, 32.72)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(18.39, 17.68)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(10.16, 29.01)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(21, 20.3)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(18.39, 17.68)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(19.98, 5.03)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.07, 5.03)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.07, 2.1)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.98, 2.1)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(19.98, 5.03)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(24.49, 2.8)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(23.97, 4.73)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(23.1, 4.5)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(23.61, 2.56)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(24.49, 2.8)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(28.66, 4.65)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(27.66, 6.39)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(26.88, 5.93)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(27.88, 4.2)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(28.66, 4.65)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(14.59, 2.8)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(15.47, 2.56)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(15.98, 4.5)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(15.11, 4.73)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(14.59, 2.8)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(10.41, 4.65)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(11.2, 4.2)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(12.2, 5.93)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(11.42, 6.39)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(10.41, 4.65)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(6.86, 7.52)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(7.51, 6.88)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(8.92, 8.3)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(8.28, 8.94)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(6.86, 7.52)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(4.17, 11.21)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.63, 10.43)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(6.36, 11.43)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(5.91, 12.22)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.17, 11.21)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(4.47, 15.99)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.53, 15.48)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.77, 14.6)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.7, 15.12)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.47, 15.99)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(4.98, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.98, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.05, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.05, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.05, 20.02)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.05, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.05, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.05, 19.11)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.98, 19.11)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(4.69, 24.01)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.76, 24.53)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(2.52, 23.65)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.46, 23.13)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.69, 24.01)];
                    [safariPhoneMinimalPath closePath];
                    [safariPhoneMinimalPath moveToPoint: CGPointMake(6.35, 27.7)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.61, 28.7)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(4.16, 27.92)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(5.89, 26.92)];
                    [safariPhoneMinimalPath addLineToPoint: CGPointMake(6.35, 27.7)];
                    [safariPhoneMinimalPath closePath];
                    [fillColor setFill];
                    [safariPhoneMinimalPath fill];
                    
                    sharedActivityImage = UIGraphicsGetImageFromCurrentImageContext();
                }
                UIGraphicsEndImageContext();
            }
            else {
                UIGraphicsBeginImageContextWithOptions((CGSize){40, 40}, NO, [[UIScreen mainScreen] scale]);
                {
                    UIBezierPath* safariPhoneClassicPathPath = [UIBezierPath bezierPath];
                    [safariPhoneClassicPathPath moveToPoint: CGPointMake(3.23, 36.91)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(18.09, 17.54)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(37.44, 2.69)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(23.05, 22.21)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(3.23, 36.91)];
                    [safariPhoneClassicPathPath closePath];
                    [safariPhoneClassicPathPath moveToPoint: CGPointMake(20.54, 18.43)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(19.02, 19.93) controlPoint1: CGPointMake(19.7, 18.43) controlPoint2: CGPointMake(19.02, 19.1)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(20.54, 21.44) controlPoint1: CGPointMake(19.02, 20.76) controlPoint2: CGPointMake(19.7, 21.44)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(22.07, 19.93) controlPoint1: CGPointMake(21.39, 21.44) controlPoint2: CGPointMake(22.07, 20.76)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(20.54, 18.43) controlPoint1: CGPointMake(22.07, 19.1) controlPoint2: CGPointMake(21.39, 18.43)];
                    [safariPhoneClassicPathPath closePath];
                    [safariPhoneClassicPathPath moveToPoint: CGPointMake(20.01, 10.95)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(10.94, 20) controlPoint1: CGPointMake(15, 10.95) controlPoint2: CGPointMake(10.94, 15)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(11.59, 23.36) controlPoint1: CGPointMake(10.94, 21.19) controlPoint2: CGPointMake(11.17, 22.32)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(10.24, 25.1)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(9.19, 22.03) controlPoint1: CGPointMake(9.74, 24.15) controlPoint2: CGPointMake(9.39, 23.11)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(0, 20.01)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(9.16, 18.03)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(11.6, 12.88) controlPoint1: CGPointMake(9.51, 16.09) controlPoint2: CGPointMake(10.37, 14.32)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(9.38, 9.15)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(12.97, 11.53)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(17.97, 9.17) controlPoint1: CGPointMake(14.38, 10.36) controlPoint2: CGPointMake(16.09, 9.53)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(19.98, 0)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(21.96, 9.16)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(25, 10.16) controlPoint1: CGPointMake(23.03, 9.35) controlPoint2: CGPointMake(24.06, 9.68)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(23.16, 11.53)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(20.01, 10.95) controlPoint1: CGPointMake(22.17, 11.16) controlPoint2: CGPointMake(21.12, 10.95)];
                    [safariPhoneClassicPathPath closePath];
                    [safariPhoneClassicPathPath moveToPoint: CGPointMake(20.01, 29.04)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(29.08, 20) controlPoint1: CGPointMake(25.02, 29.04) controlPoint2: CGPointMake(29.08, 24.99)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(28.66, 17.29) controlPoint1: CGPointMake(29.08, 19.06) controlPoint2: CGPointMake(28.93, 18.15)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(30.08, 15.4)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(30.89, 17.97) controlPoint1: CGPointMake(30.45, 16.21) controlPoint2: CGPointMake(30.72, 17.07)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(40, 19.94)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(30.93, 21.93)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(28.65, 26.91) controlPoint1: CGPointMake(30.59, 23.79) controlPoint2: CGPointMake(29.79, 25.5)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(30.83, 30.57)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(27.34, 28.26)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(22.03, 30.84) controlPoint1: CGPointMake(25.87, 29.56) controlPoint2: CGPointMake(24.05, 30.47)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(20.05, 40)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(18.04, 30.83)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(15.2, 29.9) controlPoint1: CGPointMake(17.05, 30.64) controlPoint2: CGPointMake(16.09, 30.34)];
                    [safariPhoneClassicPathPath addLineToPoint: CGPointMake(17.03, 28.54)];
                    [safariPhoneClassicPathPath addCurveToPoint: CGPointMake(20.01, 29.04) controlPoint1: CGPointMake(17.96, 28.86) controlPoint2: CGPointMake(18.96, 29.04)];
                    [safariPhoneClassicPathPath closePath];
                    [fillColor setFill];
                    [safariPhoneClassicPathPath fill];
                    
                    sharedActivityImage = UIGraphicsGetImageFromCurrentImageContext();
                }
                UIGraphicsEndImageContext();
            }
        }
    });
    
    return sharedActivityImage;
}


@end
