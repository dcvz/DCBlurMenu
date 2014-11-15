//
//  DCBlurMenu.m
//  DCBlurMenu
//
//  Created by David Chavez on 4/5/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import "DCBlurMenu.h"

@implementation DCMenuItem
@end

@interface DCBlurMenu()
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) UINavigationController *masterNavigationController;
@property (strong, nonatomic) UIView *masterView;
@property (strong, nonatomic) NSLayoutConstraint *pullDownTopPositionConstraint;
@property (strong, nonatomic) NSLayoutConstraint *menuListTopPositionConstraint;
@property (strong, nonatomic) NSString *currentItem;
@property (assign, nonatomic) UIDeviceOrientation currentOrientation;
@property (assign, nonatomic) BOOL scrolled;
@property (assign, nonatomic) BOOL didChange;
@property (assign, nonatomic) float tableHeight;
@property (assign, nonatomic) float menuHeight;
@end

@implementation DCBlurMenu

- (id)init
{
    self = [super init];
        
    self.menuItems = [NSMutableArray new];
    
    // optional setup for ILTranslucentView
    self.translucentAlpha = 1;
    self.translucentStyle = UIBarStyleBlack;
    self.translucentTintColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.scrolled = NO;
    
    return self;
}

- (id)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [self init];
    
    if (self)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
        
        self.masterNavigationController = navigationController;
        self.masterView = self.masterNavigationController.view;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        
        [self.masterNavigationController.navigationBar addGestureRecognizer:pan];
        
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    return self;
}

#pragma mark - Functionality Methods

- (void)loadMenuWithButtons:(NSArray *)buttons
{
    self.tableHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self setFrame:CGRectMake(0, 0, 0, self.tableHeight)];
    
    self.menuList = [[UITableView alloc] init];
    [self.menuList setBackgroundColor:[UIColor clearColor]];
    [self.menuList setScrollEnabled:NO];
    [self.menuList setRowHeight:self.cellHeight];
    [self.menuList setDataSource:self];
    [self.menuList setDelegate:self];
    [self.menuList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.menuList];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.menuList setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.menuHeight = self.menuList.bounds.size.height;
    
    [self createConstraints];
    
    self.menuItems = buttons;
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuListCell"];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuListCell"];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *cellSelectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cellSelectedBackgroundView.backgroundColor = self.cellSelectedColor;
    cell.selectedBackgroundView = cellSelectedBackgroundView;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    DCMenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    [cell.textLabel setText:item.title];
    
    return cell;
}

#pragma mark - Gesture Recognizer Methods

- (void)dragMenu:(UIPanGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        self.currentItem = self.masterNavigationController.navigationBar.topItem.title;
        if (!self.scrolled)
            [self.masterNavigationController.navigationBar.topItem setTitle:@"Pull Down"];
    }
    else if ([sender state] == UIGestureRecognizerStateChanged)
    {        
        CGPoint gesturePosition = [sender translationInView:self.masterNavigationController.navigationBar];
        CGPoint newPosition = gesturePosition;
        
        newPosition.x = self.frame.size.width / 2;
        newPosition.y += -((self.frame.size.height / 2) - [self topMargin]);
        
        if (!self.scrolled)
        {
            if (newPosition.y > -160.f)
            {
                [self showMenu];
                self.scrolled = YES;
            }
            else if (newPosition.y > -210.f)
                [self setCenter:newPosition];
        }
        else
        {
            CGPoint point = [sender locationInView:self.menuList];
            NSIndexPath *indexPath = [self.menuList indexPathForRowAtPoint:point];
            
            [self.menuList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        if (!self.scrolled)
            [self.masterNavigationController.navigationBar.topItem setTitle:self.currentItem];
        else
        {
            CGPoint point = [sender locationInView:self.menuList];
            NSIndexPath *indexPath = [self.menuList indexPathForRowAtPoint:point];
            DCMenuItem *item = self.menuItems[indexPath.row];
            
            if ([self.currentItem isEqualToString:item.title])
                self.didChange = false;
            
            self.currentItem = item.title;
            [self.delegate menuItemSelected:indexPath.row];
        }
    }
}

#pragma mark - View Methods

- (void)hideMenu
{
    [UIView animateWithDuration: self.animationDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.menuList deselectRowAtIndexPath:[self.menuList indexPathForSelectedRow] animated:YES];
                         
                         if (self.didChange)
                             self.center = CGPointMake(self.frame.size.width / 2, -(self.frame.size.height / 2));
                         else
                             self.center = CGPointMake(self.frame.size.width /2, -((self.frame.size.height / 3) + (self.frame.size.height / 20)));
                         
                         self.isShowing = NO;
                         self.scrolled = NO;
                     }
                     completion:^(BOOL finished){
                         [self.delegate menuIsAnimating];
                         [self.masterNavigationController.navigationBar.topItem setTitle:self.currentItem];
                     }];
}

- (void)showMenu
{
    [self.masterNavigationController.navigationBar.topItem setTitle:@""];
    [UIView animateWithDuration: self.animationDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2));
                         self.isShowing = YES;
                     }
                     completion:^(BOOL finished){
                         [self.delegate menuIsAnimating];
                         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection: 0];
                         [self.menuList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                     }];
}

#pragma mark - Helper Methods

- (void)createConstraints
{
    self.pullDownTopPositionConstraint = [NSLayoutConstraint
                                     constraintWithItem:self
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.masterView
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0
                                     constant:-self.frame.size.height + [self topMargin]];
    
    NSLayoutConstraint *pullDownCenterXPositionConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:self.masterView
                                                             attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                             constant:0];
    
    NSLayoutConstraint *pullDownWidthConstraint = [NSLayoutConstraint
                                                   constraintWithItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self.masterView
                                                   attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                   constant:0];
    
    NSLayoutConstraint *pullDownHeightMaxConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                       toItem:self.masterView
                                                       attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                       constant:0];
    
    pullDownHeightMaxConstraint.priority = 1000;
    
    NSLayoutConstraint *pullDownHeightConstraint = [NSLayoutConstraint
                                                    constraintWithItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:0
                                                    toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                    constant:self.tableHeight];
    
    pullDownHeightConstraint.priority = 900;
    
    
    NSLayoutConstraint *menuListHeightMaxConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.menuList
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                       toItem:self.masterView
                                                       attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                       constant:0];
    
    NSLayoutConstraint *menuListHeightConstraint = [NSLayoutConstraint
                                                    constraintWithItem:self.menuList
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                    toItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                    constant:0];
    
    NSLayoutConstraint *menuListWidthConstraint = [NSLayoutConstraint
                                                   constraintWithItem:self.menuList
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                   constant:0];
    
    NSLayoutConstraint *menuListCenterXPositionConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self.menuList
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                             constant:0];
    
    self.menuListTopPositionConstraint = [NSLayoutConstraint
                                     constraintWithItem:self.menuList
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0
                                     constant:-(self.menuList.bounds.size.height - 280)/2];
    
    [self.masterView addConstraint: self.pullDownTopPositionConstraint];
    [self.masterView addConstraint: pullDownCenterXPositionConstraint];
    [self.masterView addConstraint: pullDownWidthConstraint];
    [self.masterView addConstraint: pullDownHeightConstraint];
    [self.masterView addConstraint: pullDownHeightMaxConstraint];
    
    [self.masterView addConstraint: menuListHeightMaxConstraint];
    [self.masterView addConstraint: menuListHeightConstraint];
    [self.masterView addConstraint: menuListWidthConstraint];
    [self.masterView addConstraint: menuListCenterXPositionConstraint];
    [self.masterView addConstraint: self.menuListTopPositionConstraint];
    
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || self.currentOrientation == orientation) {
        return;
    }
    
    self.currentOrientation = orientation;
    
    [self performSelector:@selector(orientationChanged) withObject:nil afterDelay:0];
}

- (void)orientationChanged
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((UIDeviceOrientationIsPortrait(self.currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(self.currentOrientation) && UIDeviceOrientationIsLandscape(orientation)))
    {
        self.currentOrientation = orientation;
        
        self.pullDownTopPositionConstraint.constant = -self.frame.size.height + [self topMargin];
        
        if (UIDeviceOrientationIsPortrait(orientation))
            self.menuListTopPositionConstraint.constant = -(self.menuHeight - 280) / 2;
        else
            self.menuListTopPositionConstraint.constant = -(self.menuHeight - 33) / 2;
        
        if (self.isShowing)
            [self hideMenu];
        
        return;
    }
}

#pragma mark - Values

- (float)topMargin
{
    BOOL isStatusBarShowing = ![[UIApplication sharedApplication] isStatusBarHidden];
    
    if (UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation))
    {
        if (isStatusBarShowing)
            return [UIApplication.sharedApplication statusBarFrame].size.width + self.masterNavigationController.navigationBar.frame.size.height;
        else
            return self.masterNavigationController.navigationBar.frame.size.height;
    }
    else
    {
        if (isStatusBarShowing)
            return [UIApplication.sharedApplication statusBarFrame].size.height + self.masterNavigationController.navigationBar.frame.size.height;
        else
            return self.masterNavigationController.navigationBar.frame.size.height;
    }
}

@end