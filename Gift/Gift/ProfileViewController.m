//
//  ProfileViewController.m
//  Gift
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
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UIImageView *coverPicture;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberSinceLabel;

- (void)logoutButtonTouchHandler:(id)sender;

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
    
    // Add logout navigation bar button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    
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
            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            userProfile[@"facebookId"] = facebookID;
            userProfile[@"name"] = userData[@"name"];
            userProfile[@"email"] = userData[@"email"];
            userProfile[@"location"] = userData[@"location"][@"name"];
            userProfile[@"gender"] = userData[@"gender"];
            userProfile[@"birthday"] = userData[@"birthday"];
            userProfile[@"relationship"] = userData[@"relationship_status"];
            userProfile[@"pictureURL"] = [pictureURL absoluteString];
            
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
            [self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

#pragma mark - ()

- (void)logoutButtonTouchHandler:(id)sender
{
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)updateProfile
{
    NSDictionary *userProfile = [[PFUser currentUser] objectForKey:@"profile"];
    self.nameLabel.text = userProfile[@"name"];
    self.locationLabel.text = userProfile[@"location"];
    self.emailLabel.text = userProfile[@"email"];

    NSDate *memberSinceDate = [PFUser currentUser].createdAt;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    self.memberSinceLabel.text = [NSString stringWithFormat:@"Member since %@", [df stringFromDate:memberSinceDate]];

    [self.profilePicture setImageWithURL:[NSURL URLWithString:userProfile[@"pictureURL"]] placeholderImage:nil];
    self.profilePicture.layer.cornerRadius = 50.0f;
    self.profilePicture.layer.masksToBounds = YES;

    AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:userProfile[@"coverURL"]]]];
    postOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *blurredImage = [responseObject applyBlurWithRadius:10 tintColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:0.4f] saturationDeltaFactor:1.0f maskImage:nil];
        self.coverPicture.image = blurredImage;
    } failure:nil];
    [postOperation start];
}

@end