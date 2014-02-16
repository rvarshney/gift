//
//  TemplateCell.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-13.
//
//

#import <UIKit/UIKit.h>
#import "UICollectionViewCell+Tag.h"

@interface TemplateCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *templateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *templateImage;

@end
