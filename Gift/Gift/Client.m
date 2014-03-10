//
//  Client.m
//  Gift
//
//  Created by Ruchi Varshney on 2/9/14.
//
//

#import "Client.h"

@implementation Client

+ (Client *)instance
{
    static Client *instance;
    instance = [[Client alloc] init];
    return instance;
}

- (Album *)createAlbumForUser:(PFUser *)user title:(NSString *)title template:(Template*)template completion:(void (^)(BOOL succeeded, NSError *error))completion
{
    Album *album = [Album object];
    album.title = title;
    album.template = template;
    album.user = user;
    [album saveInBackgroundWithBlock:completion];
    return album;
}

- (void)albumsForUser:(PFUser *)user completion:(void (^)(NSArray *albums, NSError *error))completion
{
    PFQuery *query = [Album query];
    [query includeKey:@"template"];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

- (Picture *)createPictureForAlbum:(Album *)album imageData:(NSData *)imageData pageNumber:(NSUInteger)pageNumber rotationAngle:(NSNumber *)rotationAngle x:(NSNumber *)x y:(NSNumber *)y height:(NSNumber *)height width:(NSNumber *)width completion:(void (^)(BOOL succeeded, NSError *error))completion
{
    Picture *picture = [Picture object];
    picture.album = album;
    picture.image = [PFFile fileWithData:imageData];
    picture.x = x;
    picture.y = y;
    picture.rotationAngle = rotationAngle;
    picture.height = height;
    picture.width = width;
    picture.pageNumber = [NSNumber numberWithUnsignedInteger:pageNumber];
    [picture saveInBackgroundWithBlock:completion];
    return picture;
}

- (void)picturesForAlbum:(Album *)album completion:(void (^)(NSArray *pictures, NSError *error))completion
{
    PFQuery *query = [Picture query];
    [query whereKey:@"album" equalTo:album];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

-(void)templates:(void (^)(NSArray *templates, NSError *error))completion
{
    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

- (Order *)createOrderForUser:(PFUser *)user album:(Album *)album fileData:(NSData *)fileData price:(NSNumber *)price quantity:(NSNumber *)quantity total:(NSNumber *)total shippingInfo:(NSDictionary *)shippingInfo cardToken:(NSString *)cardToken
{
    Order *order = [Order object];
    order.user = user;
    order.album = album;
    order.albumFile = [PFFile fileWithData:fileData];
    order.price = price;
    order.quantity = quantity;
    order.total = total;

    order.name = [shippingInfo objectForKey:@"name"];
    order.email = [shippingInfo objectForKey:@"email"];
    order.address = [shippingInfo objectForKey:@"address"];
    order.city = [shippingInfo objectForKey:@"city"];
    order.state = [shippingInfo objectForKey:@"state"];
    order.zip = [shippingInfo objectForKey:@"zip"];

    order.cardToken = cardToken;
    order.charged = [NSNumber numberWithBool:NO];
    order.fulfilled = [NSNumber numberWithBool:NO];

    // Saves synchronously
    [order save];

    return order;
}

- (void)ordersForUser:(PFUser *)user completion:(void (^)(NSArray *orders, NSError *error))completion
{
    PFQuery *query = [Order query];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

@end
