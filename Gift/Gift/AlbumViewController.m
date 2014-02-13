//
//  AlbumViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumViewController.h"
#import "EmailHelper.h"
#import "ShippingViewController.h"

@interface AlbumViewController ()

@end

@implementation AlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    // Add email navigation bar button
    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStyleBordered target:self action:@selector(emailButtonHandler:)];

    // Add print navigation bar button
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStyleBordered target:self action:@selector(printButtonHandler:)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:emailButton, printButton, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)emailButtonHandler:(id)sender
{
    NSError *error = nil;
    BOOL isEmailSent = [EmailHelper sendEmailWithNavigationController:self.navigationController subject:@"My Cool Album" to:[NSArray arrayWithObject:@""] cc:nil bcc:nil body:@"My Cool Album!" isHTML:YES delegate:self files:[NSArray arrayWithObjects:@"ronnie-header-2.pdf",nil] error:&error];
    
    if (!isEmailSent) {
        NSLog(@"Failed with error: %@",error);
    }
}

- (void)printButtonHandler:(id)sender
{
    ShippingViewController *shippingViewController = [[ShippingViewController alloc] init];
    [self.navigationController pushViewController:shippingViewController animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"MFMailComposeResultCancelled");
            break;

        case MFMailComposeResultSaved:
            NSLog(@"MFMailComposeResultSaved");
            break;

        case MFMailComposeResultFailed:
            NSLog(@"MFMailComposeResultFailed");
            break;

        case MFMailComposeResultSent:
            NSLog(@"MFMailComposeResultSent");
            break;

        default:
            break;
    }
    
    // Close the mail interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
