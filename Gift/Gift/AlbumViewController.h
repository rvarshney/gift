//
//  AlbumViewController.h
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Album.h"

@interface AlbumViewController : UIViewController <MFMailComposeViewControllerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) Album *album;
@property (nonatomic, strong) NSMutableArray *picturesForAlbum;

@end
