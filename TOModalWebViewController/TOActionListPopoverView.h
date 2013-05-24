//
//  TOActionListPopoverView.h
//  TOModalWebViewControllerExample
//
//  Created by Tim Oliver on 13/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOActionListItem;

typedef enum {
  TOActionListPopoverViewArrowDirectionUp,
  TOActionListPopoverViewArrowDirectionDown
} TOActionListPopoverViewArrowDirection;

@interface TOActionListPopoverView : UIView

/* The array of items assigned to this popup */
@property (nonatomic,copy) NSArray *items;

/* Puts the first two button items in one row. */
@property (nonatomic,assign) BOOL splitFirstTwoItems;

- (id)initWithItems:(NSArray *)items;
- (void)presentPopoverFromView:(UIView *)view animated:(BOOL)animated;

@end

//----

typedef void (^TapAction)();

@interface TOActionListItem : NSObject

- (id)initWithTitle:(NSString *)title withTapAction:(TapAction)action;

@property (nonatomic,copy)      NSString    *title;
@property (nonatomic,strong)    UIImage     *offImage;
@property (nonatomic,strong)    UIImage     *onImage;
@property (nonatomic,copy)      TapAction   action;

@end