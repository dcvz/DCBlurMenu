#import <Foundation/Foundation.h>

@interface NSObject (PVAbstractAdditions)

+ (void)doesNotImplementSelector:(SEL)aSel;
+ (void)doesNotImplementOptionalSelector:(SEL)aSel;

- (void)doesNotImplementSelector:(SEL)aSel;
- (void)doesNotImplementOptionalSelector:(SEL)aSel;

@end