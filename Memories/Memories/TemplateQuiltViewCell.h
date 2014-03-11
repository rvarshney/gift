//
//  TemplateQuiltViewCell
//
//  Created by Ruchi Varshney on 3/08/14.
//
//

#import <UIKit/UIKit.h>
#import "TMQuiltViewCell.h"
#import <Parse/Parse.h>

@interface TemplateQuiltViewCell : TMQuiltViewCell

@property (nonatomic, retain) PFImageView *photoView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *freeView;
@property (nonatomic, retain) UIView *contentView;

@end
