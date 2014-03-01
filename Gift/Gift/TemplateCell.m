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
        self.frame = CGRectMake(0, 0, 400, 400);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
                self.frame = CGRectMake(0, 0, 400, 400);
    }
    return self;
}

@end
