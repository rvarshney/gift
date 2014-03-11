//
//  Template.h
//  Memories
//
//  Created by Upkar Lidder on 2014-02-17.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Template : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) PFFile *themeCover;
@property (nonatomic, strong) PFFile *themeLeft;
@property (nonatomic, strong) PFFile *themeRight;
@property (nonatomic, strong) PFFile *themeLeftPreview;
@property (nonatomic, strong) PFFile *themeRightPreview;

@end
