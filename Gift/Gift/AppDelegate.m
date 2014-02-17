//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "Client.h"

@implementation AppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Album registerSubclass];
    [Picture registerSubclass];
    
    [Parse setApplicationId:@"LoNqaUqU69t4r5F70vdWnigEWYce8Qe9dWyYYyKP" clientKey:@"biCM1eT3PUXjCw0UWMsWtsdBeRdKoL0GAYOqjVF9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    // Override point for customization after application launch.
    self.window.rootViewController = [[LoginViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //[self testClient];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

-(void)testClient
{
    Album *album = [[Client instance] createAlbumWithTitle:@"My New Cool Album" user:[PFUser currentUser] numPages: 1 completion:nil];
    
    NSString *fullFileName = @"Icon.png";
    NSString *fileName = [[fullFileName lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [fullFileName pathExtension];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    
    [[Client instance] createPictureForAlbum:album imagePath:fullPath pageNumber:1 rotationAngle:30 x:10 y:10 height:20 width:20 completion:nil];

    [[Client instance] albumsForUser:[PFUser currentUser] completion:^(NSArray *albums, NSError *error) {
        NSLog(@"Albums: %@", albums);
    }];

    [NSThread sleepForTimeInterval:5];
    NSLog(@"ID %@", album.objectId);

    [[Client instance] picturesForAlbum:album completion:^(NSArray *pictures, NSError *error) {
        NSLog(@"Pictures: %@", pictures);
    }];
}

@end
