//
//  TemplatesLayout.h
//  Gift
//
//  Created by Upkar Lidder on 2014-03-03.
//
//

#import <UIKit/UIKit.h>

@interface TemplatesLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets cellInsets;
@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat interCellSpacing;
@property (nonatomic) NSInteger numColumns;
@property (nonatomic) CGFloat titleHeight;

@end
