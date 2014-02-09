//
//  AlbumViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumViewController.h"
#import "EmailHelper.h"

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
    
    // Add email navigation bar button
    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStyleBordered target:self action:@selector(emailButtonHandler:)];
    self.navigationItem.rightBarButtonItem = emailButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)emailButtonHandler:(id)sender
{
    NSError *error = nil;
    BOOL isEmailSent = [EmailHelper sendEmailWithNavigationController:self.navigationController subject:@"My Cool Album" to:[NSArray arrayWithObject:@""] cc:nil bcc:nil body:@"My Cool Album!" isHTML:YES delegate:self files:[NSArray arrayWithObjects:@"ronnie-header-2.pdf",nil] error:&error];
    
    if(!isEmailSent)
        NSLog(@"Failed with error: %@",error);
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSLog(@"didFinishWithResult start");
    
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
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
