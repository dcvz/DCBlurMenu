//
//  DCBlurMenu.m
//  DCBlurMenu
//
//  Created by David Chavez on 4/5/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import "DCBlurMenu.h"

@implementation DCBlurMenu
{
    NSArray *menuItems;
    
    UINavigationController *masterNavigationController;
    UIView *masterView;
    
    UIDeviceOrientation currentOrientation;
    NSLayoutConstraint *pullDownTopPositionConstraint;
    NSLayoutConstraint *menuListTopPositionConstraint;
    
    NSString *currentItem;
    
    BOOL scrolled;
    float tableHeight;
    float menuHeight;
}

- (id)init
{
    self = [super init];
    
    menuItems = [NSMutableArray new];
    
    // setting defaults
    _animationDuration = 0.4f;
    _cellSelectedColor = [UIColor colorWithRed:137/255.f green:224/255.f blue:250/255.f alpha:.4];
    
    // optional setup for ILTranslucentView
    self.translucentAlpha = 1;
    self.translucentStyle = UIBarStyleBlack;
    self.translucentTintColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];

    _cellHeight = 70.f;
    scrolled = NO;
    
    return self;
}

- (id)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [self init];
    
    if (self)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
        
        masterNavigationController = navigationController;
        masterView = masterNavigationController.view;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        
        [masterNavigationController.navigationBar addGestureRecognizer:pan];
        
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    return self;
}

#pragma mark - Functionality Methods

- (void)loadMenuWithButtons:(NSArray *)buttons
{
    tableHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self setFrame:CGRectMake(0, 0, 0, tableHeight)];
    
    _menuList = [[UITableView alloc] init];
    [_menuList setBackgroundColor:[UIColor clearColor]];
    [_menuList setScrollEnabled:NO];
    [_menuList setRowHeight:_cellHeight];
    [_menuList setDataSource:self];
    [_menuList setDelegate:self];
    [_menuList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:_menuList];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_menuList setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    menuHeight = _menuList.bounds.size.height;
    
    [self createConstraints];
    
    menuItems = buttons;
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuListCell"];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuListCell"];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *cellSelectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cellSelectedBackgroundView.backgroundColor = _cellSelectedColor;
    cell.selectedBackgroundView = cellSelectedBackgroundView;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setText:[menuItems objectAtIndex:indexPath.item]];
    
    return cell;
}

#pragma mark - Gesture Recognizer Methods

- (void)dragMenu:(UIPanGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        currentItem = masterNavigationController.navigationBar.topItem.title;
        if (!scrolled)
            [masterNavigationController.navigationBar.topItem setTitle:@"Pull Down"];
    }
    else if ([sender state] == UIGestureRecognizerStateChanged)
    {        
        CGPoint gesturePosition = [sender translationInView:masterNavigationController.navigationBar];
        CGPoint newPosition = gesturePosition;
        
        newPosition.x = self.frame.size.width / 2;
        newPosition.y += -((self.frame.size.height / 2) - [self topMargin]);
        
        if (!scrolled)
        {
            if (newPosition.y > -160.f)
            {
                [self showMenu];
                scrolled = YES;
            }
            else if (newPosition.y > -210.f)
                [self setCenter:newPosition];
        }
        else
        {
            CGPoint point = [sender locationInView:_menuList];
            NSIndexPath *indexPath = [_menuList indexPathForRowAtPoint:point];
            
            [_menuList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        if (!scrolled)
            [masterNavigationController.navigationBar.topItem setTitle:currentItem];
        else
        {
            CGPoint point = [sender locationInView:_menuList];
            NSIndexPath *indexPath = [_menuList indexPathForRowAtPoint:point];
            currentItem = menuItems[[indexPath item]];
            [self.delegate menuItemSelected:indexPath];
        }
    }
}

#pragma mark - View Methods

- (void)hideMenu
{
    [UIView animateWithDuration: _animationDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_menuList deselectRowAtIndexPath:[_menuList indexPathForSelectedRow] animated:YES];
                         self.center = CGPointMake(self.frame.size.width / 2, -(self.frame.size.height / 2));
                         _isShowing = NO;
                         scrolled = NO;
                     }
                     completion:^(BOOL finished){
                         [_delegate menuIsAnimating];
                         [masterNavigationController.navigationBar.topItem setTitle:currentItem];
                     }];
}

- (void)showMenu
{
    [masterNavigationController.navigationBar.topItem setTitle:@""];
    [UIView animateWithDuration: _animationDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2));
                         _isShowing = YES;
                     }
                     completion:^(BOOL finished){
                         [_delegate menuIsAnimating];
                         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection: 0];
                         [_menuList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                     }];
}

#pragma mark - Helper Methods

- (void)createConstraints
{
    pullDownTopPositionConstraint = [NSLayoutConstraint
                                     constraintWithItem:self
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:masterView
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0
                                     constant:-self.frame.size.height + [self topMargin]];
    
    NSLayoutConstraint *pullDownCenterXPositionConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:masterView
                                                             attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                             constant:0];
    
    NSLayoutConstraint *pullDownWidthConstraint = [NSLayoutConstraint
                                                   constraintWithItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:masterView
                                                   attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                   constant:0];
    
    NSLayoutConstraint *pullDownHeightMaxConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                       toItem:masterView
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
                                                    constant:tableHeight];
    
    pullDownHeightConstraint.priority = 900;
    
    
    NSLayoutConstraint *menuListHeightMaxConstraint = [NSLayoutConstraint
                                                       constraintWithItem:_menuList
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                       toItem:masterView
                                                       attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                       constant:0];
    
    NSLayoutConstraint *menuListHeightConstraint = [NSLayoutConstraint
                                                    constraintWithItem:_menuList
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                    toItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                    constant:0];
    
    NSLayoutConstraint *menuListWidthConstraint = [NSLayoutConstraint
                                                   constraintWithItem:_menuList
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                   constant:0];
    
    NSLayoutConstraint *menuListCenterXPositionConstraint = [NSLayoutConstraint
                                                             constraintWithItem:_menuList
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                             constant:0];
    
    menuListTopPositionConstraint = [NSLayoutConstraint
                                     constraintWithItem:_menuList
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0
                                     constant:-(_menuList.bounds.size.height - 280)/2];
    
    [masterView addConstraint: pullDownTopPositionConstraint];
    [masterView addConstraint: pullDownCenterXPositionConstraint];
    [masterView addConstraint: pullDownWidthConstraint];
    [masterView addConstraint: pullDownHeightConstraint];
    [masterView addConstraint: pullDownHeightMaxConstraint];
    
    [masterView addConstraint: menuListHeightMaxConstraint];
    [masterView addConstraint: menuListHeightConstraint];
    [masterView addConstraint: menuListWidthConstraint];
    [masterView addConstraint: menuListCenterXPositionConstraint];
    [masterView addConstraint: menuListTopPositionConstraint];
    
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation) {
        return;
    }
    
    currentOrientation = orientation;
    
    [self performSelector:@selector(orientationChanged) withObject:nil afterDelay:0];
}

- (void)orientationChanged
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientation)))
    {
        currentOrientation = orientation;
        
        pullDownTopPositionConstraint.constant = -self.frame.size.height + [self topMargin];
        
        if (UIDeviceOrientationIsPortrait(orientation))
            menuListTopPositionConstraint.constant = -(menuHeight - 280) / 2;
        else
            menuListTopPositionConstraint.constant = -(menuHeight - 33) / 2;
        
        if (_isShowing)
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
        {
            return [UIApplication.sharedApplication statusBarFrame].size.width + masterNavigationController.navigationBar.frame.size.height;
        }
        else
            return masterNavigationController.navigationBar.frame.size.height;
    }
    else
    {
        if (isStatusBarShowing)
        {
            return [UIApplication.sharedApplication statusBarFrame].size.height + masterNavigationController.navigationBar.frame.size.height;
        }
        else
            return masterNavigationController.navigationBar.frame.size.height;
    }
}

@end
