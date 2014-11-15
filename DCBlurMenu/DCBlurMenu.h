//
//  DCBlurMenu.h
//  DCBlurMenu
//
//  Created by David Chavez on 4/5/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILTranslucentView.h"

@protocol DCBlurMenuDelegate
-(void)menuItemSelected:(NSInteger)index;
@optional
-(void)menuIsAnimating;
@end

@interface DCMenuItem : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *storyboardID;
@end

@interface DCBlurMenu : ILTranslucentView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) id<DCBlurMenuDelegate> delegate;
@property (strong, nonatomic) UITableView *menuList;
@property (strong, nonatomic) UIColor *cellSelectedColor;
@property (assign, nonatomic) float animationDuration;
@property (assign, nonatomic) float cellHeight;
@property (assign, nonatomic) BOOL isShowing;

- (id)initWithNavigationController:(UINavigationController *)navigationController;
- (void)loadMenuWithButtons:(NSArray *)buttons;
- (void)showMenu;
- (void)hideMenu;
@end