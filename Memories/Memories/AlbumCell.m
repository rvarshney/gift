//
//  AlbumCell.m
//  Memories
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
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;

        self.coverPictureImageView = [[PFImageView alloc] initWithFrame:self.bounds];
        self.coverPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverPictureImageView.clipsToBounds = YES;

        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 160, 220, 60)];
        self.overlay.backgroundColor = [UIColor blackColor];
        self.overlay.alpha = 0.35f;

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 220, 20)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20.0f];
        self.titleLabel.textColor = [UIColor whiteColor];

        [self.contentView addSubview:self.coverPictureImageView];
        [self.contentView addSubview:self.overlay];
        [self.contentView addSubview:self.titleLabel];
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
