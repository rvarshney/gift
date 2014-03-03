//
//  TemplateCell.m
//  Gift
//
//  Created by Upkar Lidder on 2014-02-13.
//
//

#import "TemplateCell.h"
#import "TemplatesViewController.h"

@implementation TemplateCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 5.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        
        self.templateImage = [[PFImageView alloc] initWithFrame:self.bounds];
        self.templateImage.contentMode = UIViewContentModeScaleAspectFill;
        self.templateImage.clipsToBounds = YES;
        
        [self.contentView addSubview:self.templateImage];
    }
    return self;
}

@end
