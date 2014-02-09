//
//  Album.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-09.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Album : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) PFUser* user;
@property int x;

@end
