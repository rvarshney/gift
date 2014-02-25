//
//  Order.h
//  Gift
//
//  Created by Ruchi Varshney on 2/25/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Album.h"

@interface Order : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) Album *album;
@property (nonatomic, strong) PFFile *albumFile;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *cardToken;
@property (nonatomic, strong) NSString *paymentToken;
@property (nonatomic, strong) NSNumber *charged;
@property (nonatomic, strong) NSNumber *fulfilled;

@end
