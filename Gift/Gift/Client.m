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

- (Album *)createAlbumWithTitle:(NSString *)title user:(PFUser *)user numPages:(NSUInteger)numPages template:(Template*)template completion:(void (^)(BOOL succeeded, NSError *error))completion
{
    Album *album = [Album object];
    album.title = title;
    album.user = user;
    album.numPages = numPages;
    [album saveInBackgroundWithBlock:completion];
    return album;
}

- (void)albumsForUser:(PFUser *)user completion:(void (^)(NSArray *, NSError *))completion
{
    PFQuery *query = [Album query];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

- (Picture *)createPictureForAlbum:(Album *)album imagePath:(NSString *)imagePath pageNumber:(NSUInteger)pageNumber rotationAngle:(NSNumber *)rotationAngle x:(NSNumber *)x y:(NSNumber *)y height:(NSNumber *)height width:(NSNumber *)width completion:(void (^)(BOOL, NSError *))completion
{
    Picture *picture = [Picture object];
    picture.album = album;
    picture.image = [PFFile fileWithName:[imagePath lastPathComponent] contentsAtPath:imagePath];
    picture.x = x;
    picture.y = y;
    picture.rotationAngle = rotationAngle;
    picture.height = height;
    picture.width = width;
    picture.pageNumber = [NSNumber numberWithUnsignedInteger:pageNumber];
    [picture saveInBackgroundWithBlock:completion];
    return picture;
}

- (void)picturesForAlbum:(Album *)album completion:(void (^)(NSArray *, NSError *))completion
{
    PFQuery *query = [Picture query];
    [query whereKey:@"album" equalTo:album];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

-(void)templates:(void (^)(NSArray *templates, NSError *error))completion
{
    PFQuery *query = [Template query];
    [query findObjectsInBackgroundWithBlock:completion];
}

@end
