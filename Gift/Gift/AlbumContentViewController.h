//
//  AlbumContentViewController.h
//  Gift
//
//  Created by Ruchi Varshney on 2/17/14.
//
//

#import <UIKit/UIKit.h>

@interface AlbumContentViewController : UIViewController

@property (nonatomic) NSUInteger pageNum;
@property (nonatomic, strong) NSMutableArray *pictures;
@property (weak, nonatomic) IBOutlet UILabel *labelText;

@end
