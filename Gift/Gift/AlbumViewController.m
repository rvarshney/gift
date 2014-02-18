//
//  AlbumViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumViewController.h"
#import "AlbumContentViewController.h"
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

    // Add the email and print buttons to the right
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
    
    // Add a dummy page for albums with no pages
    if(!maxPageNum) {
        self.picturesForPages[[NSNumber numberWithUnsignedInteger:0]] = [[NSMutableArray alloc] init];
        maxPageNum = 0;
    }
    
    // Even out the number of pages we see in the album
    if (maxPageNum % 2 == 0) {
        self.picturesForPages[[NSNumber numberWithUnsignedInteger:maxPageNum + 1]] = [[NSMutableArray alloc] init];
    }

    [self setupAlbumPageViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - Private methods

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
    [self.pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSLayoutConstraint *bottomConstraint =[NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15];
    NSLayoutConstraint *topConstraint =[NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:15];
    NSLayoutConstraint *leftConstraint =[NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15];
    NSLayoutConstraint *rightConstraint =[NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];

    [self.view addConstraints:@[bottomConstraint, topConstraint, leftConstraint, rightConstraint]];

    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)emailButtonHandler:(id)sender
{
    NSString *albumPDFPath = [self printAlbumToPDF];
    
    NSError *error = nil;
    BOOL emailSent = [self sendEmailWithSubject:self.album.title to:[NSArray arrayWithObject:@""] cc:nil bcc:nil body:@"Check out my new album built on the Memories app!" isHTML:YES delegate:self files:[NSArray arrayWithObjects:albumPDFPath, nil] error:&error];
    
    if (!emailSent) {
        NSLog(@"Failed with error: %@",error);
    }
}

- (void)printButtonHandler:(id)sender
{
    NSString *albumPDFPath = [self printAlbumToPDF];
    
    ShippingViewController *shippingViewController = [[ShippingViewController alloc] init];
    shippingViewController.album = self.album;
    shippingViewController.albumPath = albumPDFPath;
    [self.navigationController pushViewController:shippingViewController animated:YES];
}

- (NSString *)printAlbumToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    NSArray *pages = [self.picturesForPages allKeys];
    for (NSNumber *page in pages) {
        NSUInteger pageNum = [page unsignedIntegerValue];
        AlbumContentViewController *contentViewController = [[AlbumContentViewController alloc] init];
        contentViewController.pageNum = pageNum;
        UIGraphicsBeginPDFPageWithInfo(contentViewController.view.bounds, nil);
        [contentViewController.view.layer renderInContext:pdfContext];
    }
    
    UIGraphicsEndPDFContext();
    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", self.album.title]];
    
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    NSLog(@"documentDirectoryFileName: %@", documentDirectoryFilename);
    
    return documentDirectoryFilename;
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (BOOL)sendEmailWithSubject:(NSString *)subject to:(NSArray *)toArray cc:(NSArray *)ccArray bcc:(NSArray *)bccArray body:(NSString *)body isHTML:(BOOL)isHTML delegate:(id<MFMailComposeViewControllerDelegate>)delegate files:(NSArray *)filesArray error:(NSError **)error {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = delegate;
        [mailComposeViewController setSubject:subject];
        [mailComposeViewController setMessageBody:body isHTML:isHTML];
        [mailComposeViewController setToRecipients:toArray];
        
        for (NSString *file in filesArray) {
            NSData *fileData = [NSData dataWithContentsOfFile:file];
            NSString *mimeType = @"application/pdf";
            
            // Add attachment
            [mailComposeViewController addAttachmentData:fileData mimeType:mimeType fileName:file];
        }
        [self.navigationController presentViewController:mailComposeViewController animated:YES completion:Nil];
        return YES;
    } else {
        *error = [NSError errorWithDomain:@"Device not setup to send emails" code:200 userInfo:nil];
        return NO;
    }
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
