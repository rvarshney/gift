//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "Album.h"
#import "Picture.h"

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
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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

-(void)createDummyData{
    Album *album = [[Album alloc]init];
    album.title = @"My cool album";
    album.user = [PFUser currentUser];
    [album saveInBackground];
    
    Picture *pic = [[Picture alloc]init];
    UIImage *img = [UIImage imageNamed:@"icon.png"];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(img)];
    pic.album = album;
    pic.image = [PFFile fileWithName:@"icon.png" data:data];
    pic.x = [NSNumber numberWithInt:10];
    pic.y = [NSNumber numberWithInt:10];
    pic.height = [NSNumber numberWithInt:220];
    pic.width = [NSNumber numberWithInt:220];
    pic.rotationAngle = [NSNumber numberWithInt:10];
    [pic saveInBackground];
}

@end
