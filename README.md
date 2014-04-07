DCBlurMenu
==========
A blurred swipe down menu designed for iOS 7.

####How to use
Import DCBlurMenu Folder into your project. In your Storyboard set your Navigation Controller to DCBlurMenuNavigationController, or if doing it programatically make sure to use it as your navigation controller class.

DCBlurMenuNavigationController.m
```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /* edit the values here */
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
```
You must edit the items in /* edit the values here */ and set the cell height (if using more than 4 items). By default the cell height is 70.f which will fit only 4 items in your menu if you are using landscape mode. If you are not using landscape mode feel free to add more.

#### Fired Events
This control has two events: 1. when an item is selected 2. when the menu is being animated.

DCBlurMenuNavigationController.m
```objective-c
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
```
Here an example is set for when you are using storyboards, it will change the view to the whatever view has an identifier equal to the item selected.

#### Appearance Attributes
The following styling properties are available for modification
```objective-c
@property (nonatomic) UIColor *cellSelectedColor;
@property (nonatomic) float animationDuration;
@property (nonatomic) float cellHeight;
```
