//
//  DraggableImageView.h
//  Gift
//
//  Created by Ruchi Varshney on 2/18/14.
//
//

#import <Parse/Parse.h>
#import "Picture.h"

@interface DraggableImageView : PFImageView

- (id)initWithPicture:(Picture *)picture;

@end
