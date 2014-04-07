//
//  DCBlurMenuNavigationController.m
//  DCBlurMenu
//
//  Created by David Chavez on 3/2/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import "DCBlurMenuNavigationController.h"

@implementation DCBlurMenuNavigationController
{
    UIViewController *fakeRootViewController;
    DCBlurMenu *blurMenu;
    
    NSInteger currentSelected;
    NSArray *menuItems;
    
    int startIndex;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    UIViewController *fakeController = [[UIViewController alloc] init];
    if (self)
    {
        fakeRootViewController = fakeController;
        NSMutableArray *array = [NSMutableArray arrayWithArray:[super viewControllers]];
        [array insertObject:fakeController atIndex:0];
        self.viewControllers = array;
        currentSelected = 0;
        
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    
    return self;
}

// override to remove fake root controller
-(NSArray *)viewControllers
{
    NSArray *viewControllers = [super viewControllers];
    if (viewControllers != nil && viewControllers.count > 0)
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:viewControllers];
        [array removeObjectAtIndex:0];
        return array;
    }
    return viewControllers;
}

// override so it pops to the perceived root
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    // we use index 0 because we overrode viewControllers
    return [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

// this is the new method that lets you set the perceived root, the previous one will be popped (released)
-(void)setRootViewController:(UIViewController *)rootViewController
{
    rootViewController.navigationItem.hidesBackButton = YES;
    [self popToViewController:fakeRootViewController animated:NO];
    [self pushViewController:rootViewController animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /* edit the values here */
    // menuItem titles must match storyboard identifiers
    menuItems = [[NSArray alloc] initWithObjects:@"First", @"Second", @"Third", @"Fourth", @"Fifth", nil];
    startIndex = 0;
    /* edit the values here */
    
    // do this to remove the back attribute
    UIViewController *firstView = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:menuItems[startIndex]];
    [self setRootViewController:firstView];
    
    blurMenu = [[DCBlurMenu alloc] initWithNavigationController:self];
    [self.view insertSubview:blurMenu belowSubview:self.navigationBar];
    
    [blurMenu setDelegate:self];
    [blurMenu setCellHeight:50.f];  // set the height of the menu cells
    [blurMenu loadMenuWithButtons:menuItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// will return the indexPath of the selected menu row
-(void)menuItemSelected:(NSIndexPath *)indexPath
{
    if (indexPath.row != currentSelected)
    {
    	// will change view to view with identifier equal to selected item title
        UIViewController *selectedView = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:menuItems[indexPath.row]];
        [self setRootViewController:selectedView];
    }
    
    currentSelected = indexPath.row;
    [blurMenu hideMenu];
}

-(void)menuIsAnimating
{
    if (blurMenu.isShowing)
        NSLog(@"Menu is open!");
    else
        NSLog(@"Menu is closed!");
}

@end
