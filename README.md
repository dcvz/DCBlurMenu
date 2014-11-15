DCBlurMenu
==========
A beautiful blurred swipe down menu designed for iOS.

<p align="center" >
  <img src="https://dl.dropboxusercontent.com/u/25869496/dcblurmenu1.png" width="35%" height="%35" alt="DCBlurMenu" title="DCBlurMenu">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://dl.dropboxusercontent.com/u/25869496/dcblurmenu2.png" width="35%" height="%35" alt="DCBlurMenu" title="DCBlurMenu">
</p>

#### Adding DCBlurMenu to your project

The easiest way to do this is using CocoaPods. Simply add ```'DCBlurMenu'``` into your Podfile.


To install manually you’ll have to:

    - Clone the git repository and initialize submodules
    - Drag the DCBlurMenu into your project
    
DCBlurMenu supports ARC.

#### Getting Started

As of now DCBlurMenu relies on the use of Storyboards. The setup should include one UINavigationController and the views you will show when a menu item is selected (make sure to give them an ID to reference them by). Subclass ```DCBlurMenuNavigationController``` and implement the following methods:

```objective-c
// mandatory
- (void)createMenu;
- (void)selectedItemAtIndex:(NSInteger)index // is triggered upon menu selection
// optional
-(void)menuIsAnimating;
```

*Make sure to also set your statusbar to light content!*

#### Example

```objective-c
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
```

Set your UINavigationController class to it and you're set! Make sure to check out the demo project for reference.

#### Appearance Attributes
The following styling properties are available for modification
```objective-c
@property (nonatomic) UIColor *cellSelectedColor;
@property (nonatomic) float animationDuration;
@property (nonatomic) float cellHeight; // default to 70 which only fits 4 items
```

###License
The MIT License (MIT)

Copyright (c) 2014 David Chavez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
