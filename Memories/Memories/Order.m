//
//  Order.m
//  Memories
//
//  Created by Ruchi Varshney on 2/25/14.
//
//

#import "Order.h"
#import <Parse/PFObject+Subclass.h>

@implementation Order

@dynamic user;
@dynamic album;
@dynamic albumFile;
@dynamic quantity;
@dynamic price;
@dynamic total;
@dynamic name;
@dynamic email;
@dynamic address;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic cardToken;
@dynamic paymentToken;
@dynamic charged;
@dynamic fulfilled;

+ (NSString *)parseClassName
{
    return @"Order";
}

@end
