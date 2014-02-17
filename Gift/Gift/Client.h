//
//  Client.h
//  Gift
//
//  Created by Ruchi Varshney on 2/9/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "Album.h"
#import "Picture.h"

@interface Client : NSObject

+ (Client *)instance;

// Albums API
- (Album *)createAlbumWithTitle:(NSString *)title user:(PFUser *)user numPages:(NSUInteger)numPages completion:(void (^)(BOOL succeeded, NSError *error))completion;

- (void)albumsForUser:(PFUser *)user completion:(void (^)(NSArray *albums, NSError *error))completion;

// Pictures API
- (Picture *)createPictureForAlbum:(Album *)album imagePath:(NSString *)imagePath pageNumber:(NSUInteger)pageNumber rotationAngle:(CGFloat)rotationAngle x:(NSUInteger)x y:(NSUInteger)y height:(NSUInteger)height width:(NSUInteger)width completion:(void (^)(BOOL succeeded, NSError *error))completion;

- (void)picturesForAlbum:(Album *)album completion:(void (^)(NSArray *pictures, NSError *error))completion;

@end
