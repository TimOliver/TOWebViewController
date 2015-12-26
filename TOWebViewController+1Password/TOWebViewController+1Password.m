//
//  TOWebViewController+1Password.m
//
//  Copyright 2013-2016 Timothy Oliver. All rights reserved.
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

#import "TOWebViewController+1Password.h"
#import <objc/runtime.h>
#import "OnePasswordExtension.h"

NSString const *onePasswordExtensionEnabledKey = @"au.com.timoliver.webviewcontroller.onepassword.enabled";
NSString const *onePasswordExtensionButtonKey = @"au.com.timoliver.webviewcontroller.onepassword.button";

@implementation TOWebViewController (OnePassword)

#pragma mark - Accessor Overrides -
- (void)setShowOnePasswordButton:(BOOL)showOnePasswordButton
{
    if (self.showOnePasswordButton == showOnePasswordButton)
        return;
 
#if TARGET_IPHONE_SIMULATOR
#else
    //Don't bother trying if 1Password isn't on the system
    if ([[OnePasswordExtension sharedExtension] isAppExtensionAvailable] == NO)
        return;
#endif
    
    objc_setAssociatedObject(self, &onePasswordExtensionEnabledKey, @(showOnePasswordButton), OBJC_ASSOCIATION_ASSIGN);
    
    if (showOnePasswordButton) {
        //Create the bar button item
        if (self.onePasswordButton == nil) {
            UIImage *onePasswordImage = [UIImage imageNamed:@"onepassword-navbar.png"];
            if (onePasswordImage == nil) {
                NSBundle *onepasswordExtensionResourcesBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[OnePasswordExtension class]] pathForResource:@"OnePasswordExtensionResources" ofType:@"bundle"]];
                onePasswordImage = [UIImage imageNamed:@"onepassword-navbar.png" inBundle:onepasswordExtensionResourcesBundle compatibleWithTraitCollection:nil];
            }
            
            UIBarButtonItem *onePasswordButton = [[UIBarButtonItem alloc] initWithImage:onePasswordImage
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(onePasswordButtonTapped:)];
            
            objc_setAssociatedObject(self, &onePasswordExtensionButtonKey, onePasswordButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        //Add or insert into our existing application bar buttons
        if (self.applicationBarButtonItems == nil) {
            self.applicationBarButtonItems = @[self.onePasswordButton];
        }
        else {
            NSMutableArray *buttons = [self.applicationBarButtonItems mutableCopy];
            [buttons addObject:self.applicationBarButtonItems];
            self.applicationBarButtonItems = [NSArray arrayWithArray:buttons];
        }
    }
    else {
        //remove it from application bar buttons
        NSMutableArray *buttons = [self.applicationBarButtonItems mutableCopy];
        [buttons removeObject:self.onePasswordButton];
        self.applicationBarButtonItems = [NSArray arrayWithArray:buttons];
        
        objc_setAssociatedObject(self, &onePasswordExtensionButtonKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)showOnePasswordButton
{
    return [objc_getAssociatedObject(self, &onePasswordExtensionEnabledKey) boolValue];
}

- (UIBarButtonItem *)onePasswordButton
{
    return objc_getAssociatedObject(self, &onePasswordExtensionButtonKey);
}

#pragma mark - Button Callback -
- (void)onePasswordButtonTapped:(id)sender
{
    [[OnePasswordExtension sharedExtension] fillItemIntoWebView:self.webView forViewController:self sender:sender showOnlyLogins:NO completion:nil];
}

@end
