//
//  DCBlurMenuNavigationController.h
//  DCBlurMenu
//
//  Created by David Chavez on 3/2/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBlurMenu.h"

@interface DCBlurMenuNavigationController : UINavigationController <DCBlurMenuDelegate>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) UIColor *cellSelectedColor;
@property (assign, nonatomic) NSInteger startIndex;
@property (assign, nonatomic) float animationDuration;
@property (assign, nonatomic) float cellHeight;
@end