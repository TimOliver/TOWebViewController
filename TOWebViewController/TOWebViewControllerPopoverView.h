//
//  TOWebViewControllerPopoverView.h
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

#import <UIKit/UIKit.h>

@class TOWebViewControllerPopoverViewItem;

typedef enum {
  TOActionListPopoverViewArrowDirectionUp,
  TOActionListPopoverViewArrowDirectionDown
} TOActionListPopoverViewArrowDirection;

@interface TOWebViewControllerPopoverView : UIView

@property (nonatomic,strong)    TOWebViewControllerPopoverViewItem *leftHeaderItem;
@property (nonatomic,strong)    TOWebViewControllerPopoverViewItem *rightHeaderItem;
@property (nonatomic,copy)      NSArray          *items;

- (id)init;
- (void)presentPopoverFromView:(UIView *)view animated:(BOOL)animated;

@end

//----

//Block prototype for defining an action when a popover button is tapped
//Passes along the item entry that was tapped as well (So the item state may be changed)
typedef void (^TapAction)(TOWebViewControllerPopoverViewItem *item);

@interface TOWebViewControllerPopoverViewItem : NSObject

- (id)initWithTitle:(NSString *)title withTapAction:(TapAction)action;
- (id)initWithImage:(UIImage *)image withTapAction:(TapAction)action;

@property (nonatomic,copy)      NSString                *title;
@property (nonatomic,strong)    UIImage                 *image;
@property (nonatomic,copy)      TapAction               action;

@property (nonatomic,weak)      TOWebViewControllerPopoverView *popoverView;

@end