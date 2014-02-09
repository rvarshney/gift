//
//  EmailViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "EmailViewController.h"
#import "EmailHelper.h"

@interface EmailViewController ()

@end

@implementation EmailViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendEmail:(id)sender {
    NSError *error = nil;
    BOOL isEmailSent = [EmailHelper sendEmailWithNavigationController:self.navigationController subject:@"Subject" to:[NSArray arrayWithObject:@"lidderupk@gmail.com"] cc:nil bcc:nil body:@"Hello World !" isHTML:YES delegate:self files:[NSArray arrayWithObjects:@"ronnie-header-2.pdf",@"icon.png", nil] error:&error];
    
    if(!isEmailSent)
        NSLog(@"Failed with error: %@",error);
}

#pragma mail delegate methods
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
