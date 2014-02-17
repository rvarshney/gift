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

- (Album *)createAlbumWithTitle:(NSString *)title user:(PFUser *)user numPages:(NSUInteger)numPages completion:(void (^)(BOOL succeeded, NSError *error))completion
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

- (Picture *)createPictureForAlbum:(Album *)album imagePath:(NSString *)imagePath pageNumber:(NSUInteger)pageNumber rotationAngle:(CGFloat)rotationAngle x:(NSUInteger)x y:(NSUInteger)y height:(NSUInteger)height width:(NSUInteger)width completion:(void (^)(BOOL, NSError *))completion
{
    Picture *picture = [Picture object];
    picture.album = album;
    picture.image = [PFFile fileWithName:[imagePath lastPathComponent] contentsAtPath:imagePath];
    picture.x = [NSNumber numberWithInteger:x];
    picture.y = [NSNumber numberWithInteger:y];
    picture.rotationAngle = [NSNumber numberWithFloat:rotationAngle];
    picture.height = [NSNumber numberWithInt:height];
    picture.width = [NSNumber numberWithInt:width];
    picture.pageNumber = [NSNumber numberWithInt:pageNumber];
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

@end
