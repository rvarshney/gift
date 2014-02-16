//
//  UICollectionViewCell+Tag.m
//  Gift
//
//  Created by Upkar Lidder on 2014-02-15.
//
//

#import "UICollectionViewCell+Tag.h"
#import <objc/runtime.h>

static char const * const ObjectTagKey = "ObjectTag";
@implementation UICollectionViewCell (Tag)

-(void)setTag:(int)tag{
    objc_setAssociatedObject(self, ObjectTagKey, [NSNumber numberWithInt:tag], OBJC_ASSOCIATION_RETAIN);
}

-(int)tag{
    return [objc_getAssociatedObject(self, ObjectTagKey) intValue];
}

@end
