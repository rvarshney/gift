//
//  TemplateCell.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-13.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TemplateCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet PFImageView *templateImage;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIImageView *albumImage;

@end
