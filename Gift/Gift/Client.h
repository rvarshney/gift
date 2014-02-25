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
#import "Template.h"
#import "Order.h"

@interface Client : NSObject

+ (Client *)instance;

// Albums API
- (Album *)createAlbumForUser:(PFUser *)user title:(NSString *)title template:(Template*)template completion:(void (^)(BOOL succeeded, NSError *error))completion;

- (void)albumsForUser:(PFUser *)user completion:(void (^)(NSArray *albums, NSError *error))completion;

// Pictures API
- (Picture *)createPictureForAlbum:(Album *)album imageData:(NSData *)imageData pageNumber:(NSUInteger)pageNumber rotationAngle:(NSNumber *)rotationAngle x:(NSNumber *)x y:(NSNumber *)y height:(NSNumber *)height width:(NSNumber *)width completion:(void (^)(BOOL succeeded, NSError *error))completion;

- (void)picturesForAlbum:(Album *)album completion:(void (^)(NSArray *pictures, NSError *error))completion;

// Templates API
- (void)templates:(void (^)(NSArray *templates, NSError *error))completion;

// Orders API
- (Order *)createOrderForUser:(PFUser *)user album:(Album *)album fileData:(NSData *)fileData price:(NSNumber *)price quantity:(NSNumber *)quantity total:(NSNumber *)total shippingInfo:(NSDictionary *)shippingInfo cardToken:(NSString *)cardToken;

- (void)ordersForUser:(PFUser *)user completion:(void (^)(NSArray *orders, NSError *error))completion;

@end
