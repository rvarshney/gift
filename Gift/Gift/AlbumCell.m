//
//  AlbumCell.m
//  Gift
//
//  Created by Ruchi Varshney on 2/14/14.
//
//

#import "AlbumCell.h"

@implementation AlbumCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 5.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;

        self.coverPictureImageView = [[PFImageView alloc] initWithFrame:self.bounds];
        self.coverPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverPictureImageView.clipsToBounds = YES;

        [self.contentView addSubview:self.coverPictureImageView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.coverPictureImageView.file = nil;
    self.coverPictureImageView.image = nil;
}

@end
