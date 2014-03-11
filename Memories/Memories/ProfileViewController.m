//
//  ProfileViewController.m
//  Memories
//
//  Created by Ruchi Varshney on 2/3/14.
//
//

#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"
#import "AFHTTPRequestOperation.h"

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UIImageView *coverPicture;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

@end

@implementation ProfileViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Set title
    self.title = @"Profile";

    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
    if ([PFUser currentUser]) {
        [self updateProfile];
    }
    
    [self loadFacebookData];
}

- (void)loadFacebookData
{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            if (userData[@"id"]) {
                userProfile[@"facebookId"] = userData[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            if (userData[@"email"]) {
                userProfile[@"email"] = userData[@"email"];
            }
            if (userData[@"location"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            FBRequest *coverPictureRequest = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/?fields=cover&&return_ssl_resources=1", userProfile[@"facebookId"]]];
            [coverPictureRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error && ![userProfile[@"coverURL"] isEqualToString:result[@"cover"][@"source"]]) {
                    userProfile[@"coverURL"] = result[@"cover"][@"source"];
                    [self updateProfile];
                }
                [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                [[PFUser currentUser] saveInBackground];
                [self updateProfile];
            }];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

#pragma mark - Private methods

- (void)cancelButtonTouchHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateProfile
{
    NSDictionary *userProfile = [[PFUser currentUser] objectForKey:@"profile"];
    self.nameLabel.text = userProfile[@"name"];
    //self.nameLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    //self.nameLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);

    self.locationLabel.text = userProfile[@"location"];
    //self.locationLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    //self.locationLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);

    [self.profilePicture setImageWithURL:[NSURL URLWithString:userProfile[@"pictureURL"]] placeholderImage:nil];
    self.profilePicture.layer.cornerRadius = 50.0f;
    self.profilePicture.layer.masksToBounds = YES;
    
    AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:userProfile[@"coverURL"]]]];
    [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *blurredImage = [UIImage imageWithData:responseObject];
        blurredImage = [blurredImage applyBlurWithRadius:10 tintColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:0.4f] saturationDeltaFactor:1.0f maskImage:nil];
        self.coverPicture.image = blurredImage;
        //self.coverPicture.layer.cornerRadius = 5.0f;
        self.coverPicture.layer.masksToBounds = YES;
    } failure:nil];
    [postOperation start];
}

@end
