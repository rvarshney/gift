//
//  AlbumImageView.h
//  Gift
//
//  Created by Ruchi Varshney on 2/18/14.
//
//

#import <Parse/Parse.h>
#import "Picture.h"

@interface AlbumImageView : PFImageView

@property (nonatomic, strong) Picture *picture;

- (id)initWithPicture:(Picture *)picture;
- (void)updateFrame;

@end
