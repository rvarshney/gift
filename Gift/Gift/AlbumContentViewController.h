//
//  AlbumContentViewController.h
//  Gift
//
//  Created by Ruchi Varshney on 2/17/14.
//
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumContentViewController : UIViewController

@property (nonatomic) NSUInteger pageNum;
@property (nonatomic, strong) NSMutableArray *pictures;
@property (nonatomic, strong) Album *album;

- (void)showPlacementViews;
- (void)hidePlacementViews;
- (CGRect)placementRectForLocation:(CGPoint)location;

@end
