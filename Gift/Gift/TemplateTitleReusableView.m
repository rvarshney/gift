//
//  TemplateTitleReusableView.m
//  Gift
//
//  Created by Upkar Lidder on 2014-03-03.
//
//

#import "TemplateTitleReusableView.h"

@interface TemplateTitleReusableView()
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@end

@implementation TemplateTitleReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {      
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20.0f];
        self.titleLabel.textColor = [UIColor darkGrayColor];
        //self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        //self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel.text = nil;
}

@end
