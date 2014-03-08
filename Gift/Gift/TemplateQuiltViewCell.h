//
//  TMQuiltView
//
//  Created by Bruno Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories


#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"
#import <Parse/Parse.h>

@interface TemplateQuiltViewCell : TMQuiltViewCell

@property (nonatomic, retain) PFImageView *photoView;
@property (nonatomic, retain) UILabel *titleLabel;

@end
