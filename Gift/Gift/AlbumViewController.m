//
//  AlbumViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumViewController.h"
#import "AlbumContentViewController.h"
#import "EmailHelper.h"
#import "ShippingViewController.h"
#import "Client.h"

@interface AlbumViewController ()

@property (nonatomic, strong) NSMutableDictionary *picturesForPages;
@property (nonatomic, strong) UIPageViewController *pageViewController;

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

    // Group pictures by page number
    self.picturesForPages = [[NSMutableDictionary alloc] init];
    
    for (Picture *picture in self.picturesForAlbum) {
        NSMutableArray *array = self.picturesForPages[picture.pageNumber];
        if (array) {
            [((NSMutableArray *)self.picturesForPages[picture.pageNumber]) addObject:picture];
        } else {
            self.picturesForPages[picture.pageNumber] = [[NSMutableArray alloc] initWithObjects:picture, nil];
        }
    }
    
    NSUInteger maxPageNum = [[[self.picturesForPages allKeys] valueForKeyPath:@"@max.unsignedIntegerValue"]unsignedIntegerValue];
    
    if (maxPageNum % 2 == 0) {
        self.picturesForPages[[NSNumber numberWithUnsignedInteger:maxPageNum + 1]] = [[NSMutableArray alloc] init];
    }

    [self setupAlbumPageViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupAlbumPageViewController
{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    AlbumContentViewController *contentViewController = [[AlbumContentViewController alloc] initWithNibName:@"AlbumContentViewController" bundle:nil];
    contentViewController.pageNum = 0;
    
    NSArray *viewControllers = [NSArray arrayWithObject:contentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageViewController.view.frame = CGRectMake(20, 20, 500, 500);

    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
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
    shippingViewController.album = self.album;
    shippingViewController.albumPath = @"ronnie-header-2.pdf";
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

#pragma mark - UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = ((AlbumContentViewController *)viewController).pageNum;
    if (currentIndex == self.picturesForPages.count - 1)
    {
        return nil;
    }
    
    AlbumContentViewController *albumContentViewController = [[AlbumContentViewController alloc] init];
    albumContentViewController.pageNum = currentIndex + 1;
    return albumContentViewController;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = ((AlbumContentViewController *)viewController).pageNum;
    if (currentIndex == 0)
    {
        return nil;
    }
    
    AlbumContentViewController *albumContentViewController = [[AlbumContentViewController alloc] init];
    albumContentViewController.pageNum = currentIndex - 1;
    return albumContentViewController;
}

#pragma mark - UIPageViewControllerDelegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        AlbumContentViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    else
    {
        NSArray *viewControllers = nil;
        
        AlbumContentViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        
        NSUInteger currentIndex = currentViewController.pageNum;
        if (currentIndex % 2 == 0)
        {
            UIViewController *nextViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
            viewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
        } else {
            UIViewController *previousViewController = [self pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
            viewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
        }
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = YES;

        return UIPageViewControllerSpineLocationMid;
    }

}

@end
