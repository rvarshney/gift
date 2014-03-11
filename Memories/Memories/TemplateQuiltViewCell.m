//
//  TemplateQuiltViewCell
//
//  Created by Ruchi Varshney on 3/08/14.
//
//


#import "TemplateQuiltViewCell.h"

const CGFloat kTMPhotoQuiltViewMargin = 5;

@implementation TemplateQuiltViewCell

@synthesize photoView = _photoView;
@synthesize titleLabel = _titleLabel;
@synthesize freeView = _freeView;
@synthesize contentView = _contentView;

- (void)dealloc
{
    [_photoView release], _photoView = nil;
    [_titleLabel release], _titleLabel = nil;
    [_freeView release], _freeView = nil;
    
    [super dealloc];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 5.0f;
        [self addSubview:self.contentView];
    }
    return self;
}

- (UIImageView *)photoView
{
    if (!_photoView) {
        _photoView = [[PFImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        [self.contentView addSubview:_photoView];
    }
    return _photoView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"Avenir" size:20.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)freeView
{
    if (!_freeView) {
        _freeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"free-ribbon.png"]];
        _freeView.contentMode = UIViewContentModeScaleAspectFill;
        _freeView.clipsToBounds = YES;
        [self addSubview:_freeView];
    }
    return _freeView;
}

- (void)layoutSubviews
{
    self.photoView.frame = CGRectInset(self.bounds, kTMPhotoQuiltViewMargin, kTMPhotoQuiltViewMargin);
    self.titleLabel.frame = CGRectMake(kTMPhotoQuiltViewMargin, self.bounds.size.height - 50 - kTMPhotoQuiltViewMargin, self.bounds.size.width - 2 * kTMPhotoQuiltViewMargin, 50);
    self.freeView.frame = CGRectMake(-4, 10, self.freeView.frame.size.width, self.freeView.frame.size.height);
}

@end
