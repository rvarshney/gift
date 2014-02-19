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
- (Album *)createAlbumWithTitle:(NSString *)title user:(PFUser *)user numPages:(NSUInteger)numPages template:(Template*)template completion:(void (^)(BOOL succeeded, NSError *error))completion;

- (void)albumsForUser:(PFUser *)user completion:(void (^)(NSArray *albums, NSError *error))completion;

// Pictures API
- (Picture *)createPictureForAlbum:(Album *)album imagePath:(NSString *)imagePath pageNumber:(NSUInteger)pageNumber rotationAngle:(NSNumber *)rotationAngle x:(NSNumber *)x y:(NSNumber *)y height:(NSNumber *)height width:(NSNumber *)width completion:(void (^)(BOOL, NSError *))completion;

- (void)picturesForAlbum:(Album *)album completion:(void (^)(NSArray *pictures, NSError *error))completion;

-(void)templates:(void (^)(NSArray *templates, NSError *error))completion;


@end
