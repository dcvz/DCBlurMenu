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

-(void)menuItemSelected:(NSIndexPath *)indexPath;
-(void)menuIsAnimating;

@end

@interface DCBlurMenu : ILTranslucentView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) id<DCBlurMenuDelegate> delegate;
@property (nonatomic, retain) UITableView *menuList;

@property (nonatomic) UIColor *cellSelectedColor;
@property (nonatomic) float animationDuration;
@property (nonatomic) float cellHeight;
@property (nonatomic) BOOL isShowing;

- (id)initWithNavigationController:(UINavigationController *)navigationController;
- (void)loadMenuWithButtons:(NSArray *)buttons;
- (void)showMenu;
- (void)hideMenu;

@end
