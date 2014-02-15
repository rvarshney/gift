//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import "AlbumCollectionViewLayout.h"
#import "AlbumCollectionViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

- (IBAction)loginButtonTouchHandler:(id)sender;

@end

@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self presentAlbumCollection];
    }
}

#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self presentAlbumCollection];
        } else {
            NSLog(@"User with facebook logged in!");
            [self presentAlbumCollection];
        }
    }];
}

- (void)presentAlbumCollection
{
    AlbumCollectionViewLayout *albumCollectionViewLayout = [[AlbumCollectionViewLayout alloc] init];
    AlbumCollectionViewController *albumCollectionViewController = [[AlbumCollectionViewController alloc] initWithCollectionViewLayout:albumCollectionViewLayout];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumCollectionViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

@end
