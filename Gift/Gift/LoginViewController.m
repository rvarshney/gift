//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import "AlbumCollectionViewLayout.h"
#import "AlbumCollectionViewController.h"
#import "MBProgressHUD.h"
#import "FadeImagePageViewController.h"
#import "UIImage+ImageEffects.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@property (strong, nonatomic) FadeImagePageViewController *fadeViewController;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end

@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];
    
    [self setupFadeViewController];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self presentAlbumCollection];
    }
}

- (void)setupFadeViewController
{
    self.fadeViewController = [[FadeImagePageViewController alloc] init];
    UIImage *image1 = [[UIImage imageNamed:@"1.jpg"] applyBlurWithRadius:1 tintColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:0.3f] saturationDeltaFactor:1.0f maskImage:nil];
    UIImage *image2 = [UIImage imageNamed:@"2.jpg"];
    UIImage *image3 = [[UIImage imageNamed:@"3.jpg"] applyBlurWithRadius:5 tintColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:0.3f] saturationDeltaFactor:1.0f maskImage:nil];
    UIImage *image4 = [[UIImage imageNamed:@"4.jpg"] applyBlurWithRadius:1 tintColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:0.3f] saturationDeltaFactor:1.0f maskImage:nil];
    UIImage *image5 = [[UIImage imageNamed:@"5.jpg"] applyBlurWithRadius:1 tintColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:0.3f] saturationDeltaFactor:1.0f maskImage:nil];
    self.fadeViewController.images = @[image1, image2, image3, image4, image5];
    
    self.fadeViewController.messages = @[@"Capture life moments in stunning photo albums.", @"Collate pictures from all your photo platforms.", @"Pick designs from a variety of templates", @"Work on your photo album from any device at your own pace.", @"Build the perfect gift. Printed on premium quality paper and shipped right to your doorstep."];
    [self addChildViewController:self.fadeViewController];
    [self.fadeViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.fadeViewController.view];
    [self.view sendSubviewToBack:self.fadeViewController.view];
    [self.fadeViewController didMoveToParentViewController:self];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.fadeViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.fadeViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.fadeViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.fadeViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];

    [self.view addConstraints:@[topConstraint, leftConstraint, rightConstraint, bottomConstraint]];
}

#pragma mark - Login methods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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
