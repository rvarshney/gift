//
//  AlbumCollectionViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumCollectionViewController.h"
#import "ProfileViewController.h"
#import "TemplatesViewController.h"

@interface AlbumCollectionViewController ()

@end

@implementation AlbumCollectionViewController

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

    self.title = @"My Albums";

    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStyleBordered target:self action:@selector(profileButtonHandler:)];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(newButtonHandler:)];
    self.navigationItem.rightBarButtonItem = newButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)profileButtonHandler:(id)sender
{
    // Return to login view controller
    [self.navigationController pushViewController:[[ProfileViewController alloc] init] animated:YES];
}

- (void)newButtonHandler:(id)sender
{
    // Push templates view controller
    [self.navigationController pushViewController:[[TemplatesViewController alloc] init] animated:YES];
}
@end
