//
//  Template.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-17.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Template : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)PFFile *themeCover;
@property(nonatomic, strong)PFFile *themeLeft;
@property(nonatomic, strong)PFFile *themeRight;

@end
