//
//  Picture.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-09.
//
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface Picture : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property(nonatomic, strong) Album* album;
@property(nonatomic, strong) PFFile* image;
@property(nonatomic, retain) NSNumber* pageNumber;
@property(nonatomic, retain) NSNumber* rotationAngle;
@property(nonatomic, retain) NSNumber* height;
@property(nonatomic, retain) NSNumber* width;
@property (nonatomic, retain) NSNumber* x;
@property(nonatomic, retain) NSNumber* y;


@end
