//
//  DCBlurMenuNavigationController.m
//  DCBlurMenu
//
//  Created by David Chavez on 3/2/14.
//  Copyright (c) 2014 David Chavez. All rights reserved.
//

#import "DCBlurMenuNavigationController.h"
#import "NSObject+AbstractAdditions.h"

@interface DCBlurMenuNavigationController()
@property (strong, nonatomic) UIViewController *fakeRootViewController;
@property (strong, nonatomic) DCBlurMenu *blurMenu;
@property (assign, nonatomic) NSInteger currentIndex;
@end

@implementation DCBlurMenuNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    UIViewController *fakeController = [[UIViewController alloc] init];
    if (self)
    {
        self.fakeRootViewController = fakeController;
        NSMutableArray *array = [NSMutableArray arrayWithArray:[super viewControllers]];
        [array insertObject:fakeController atIndex:0];
        self.viewControllers = array;
        self.currentIndex = 0;
        
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
    [self popToViewController:self.fakeRootViewController animated:NO];
    [self pushViewController:rootViewController animated:NO];
}

- (void)createMenu
{
    [self doesNotImplementSelector:_cmd];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self createMenu];
    
    if (!self.startIndex)
    {
        NSLog(@"No start index set. Using 0 by default");
        self.startIndex = 0;
    }
    
    DCMenuItem *startItem = self.menuItems[self.startIndex];
    
    // do this to remove the back attribute
    UIViewController *firstView = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:startItem.storyboardID];
    [self setRootViewController:firstView];
    
    self.blurMenu = [[DCBlurMenu alloc] initWithNavigationController:self];
    [self.view insertSubview:self.blurMenu belowSubview:self.navigationBar];
    
    [self.blurMenu setDelegate:self];
    [self.blurMenu setCellHeight:50.f];
    [self.blurMenu setCellSelectedColor:self.cellSelectedColor];
    [self.blurMenu setAnimationDuration:self.animationDuration];
    [self.blurMenu setCellHeight:self.cellHeight];
    [self.blurMenu loadMenuWithButtons:self.menuItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectedItemAtIndex:(NSInteger)index
{
    [self doesNotImplementSelector:_cmd];
}

// will return the indexPath of the selected menu row
-(void)menuItemSelected:(NSInteger)index
{
    if (index != self.currentIndex)
    {
        DCMenuItem *selectedItem = self.menuItems[index];
        
    	// will change view to view with identifier equal to selected item title
        UIViewController *selectedView = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:selectedItem.storyboardID];
        [self setRootViewController:selectedView];
    }
    
    self.currentIndex = index;
    [self selectedItemAtIndex:index];
    [self.blurMenu hideMenu];
}

-(void)menuIsAnimating
{
    [self doesNotImplementOptionalSelector:_cmd];
}

@end