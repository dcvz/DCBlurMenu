//
//  ExampleNavigationController.m
//  DCBlurMenu
//
//  Created by David Chavez on 11/14/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import "ExampleNavigationController.h"

@implementation ExampleNavigationController

- (void)createMenu
{
    // Create Menu Items
    DCMenuItem *first = [DCMenuItem new];
    first.title = @"First";
    first.storyboardID = @"firstView";
    
    DCMenuItem *second = [DCMenuItem new];
    second.title = @"Second";
    second.storyboardID = @"secondView";
    
    DCMenuItem *third = [DCMenuItem new];
    third.title = @"Third";
    third.storyboardID = @"thirdView";
    
    DCMenuItem *fourth = [DCMenuItem new];
    fourth.title = @"Fourth";
    fourth.storyboardID = @"fourthView";
    
    self.menuItems = [[NSArray alloc] initWithObjects:first, second, third, fourth, nil];
    
    // Set starting index
    self.startIndex = 0;
    self.cellSelectedColor = [UIColor colorWithRed:137/255.f green:224/255.f blue:250/255.f alpha:.4];
    self.animationDuration = 0.4f;
    self.cellHeight = 70.f;
}

- (void)selectedItemAtIndex:(NSInteger)index
{
    NSLog(@"IndexPath Selected: %li", index);
}

@end