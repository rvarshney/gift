//
//  Album.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-09.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Template.h"

@interface Album : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) PFUser *user;
@property NSUInteger numPages;
@property (nonatomic, strong) Template *template;


@end
