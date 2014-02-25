//
//  Album.m
//  Gift
//
//  Created by Upkar Lidder on 2014-02-09.
//
//

#import "Album.h"
#import <Parse/PFObject+Subclass.h>

@implementation Album

@dynamic title;
@dynamic user;
@dynamic template;


+ (NSString *)parseClassName
{
    return @"Album";
}

@end
