//
//  Picture.m
//  Gift
//
//  Created by Upkar Lidder on 2014-02-09.
//
//

#import "Picture.h"
#import <Parse/PFObject+Subclass.h>

@implementation Picture

@dynamic album;
@dynamic image;
@dynamic pageNumber;
@dynamic rotationAngle;
@dynamic height;
@dynamic width;
@dynamic x;
@dynamic y;

+ (NSString *)parseClassName
{
    return @"Picture";
}

@end
