//
//  AlbumImageView.m
//  Memories
//
//  Created by Ruchi Varshney on 2/18/14.
//
//

#import "AlbumImageView.h"

@interface AlbumImageView()

@property (nonatomic) CGPoint startLocation;

@end

@implementation AlbumImageView

- (id)initWithPicture:(Picture *)picture
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.picture = picture;
        self.file = picture.image;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        [self loadInBackground];
        [self updateFrame];
    }
    return self;
}

- (void)updateFrame
{
    self.bounds = CGRectMake(0, 0, [self.picture.width floatValue], [self.picture.height floatValue]);
    self.frame = CGRectMake([self.picture.x floatValue], [self.picture.y floatValue], [self.picture.width floatValue], [self.picture.height floatValue]);
}

@end
