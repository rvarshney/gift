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
#import "Picture.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import <QuartzCore/QuartzCore.h>

@interface AlbumViewController ()

@property (nonatomic, strong) NSMutableDictionary *picturesForPages;
@property (nonatomic, strong) UIPageViewController *pageViewController;


@property (nonatomic, strong) UIScrollView *subView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *pullUpButton;


@property (nonatomic, strong) NSLayoutConstraint *heightPullConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightBtnConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, copy) NSArray *chosenImages;
@property (nonatomic, assign) BOOL isSubViewVisible;

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
    
    // Start the display area from under the status bar
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
    
    [self addScrollView];
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
    
    AlbumContentViewController *contentViewController = [self createContentViewControllerWithPageNum:0];

    NSArray *viewControllers = [NSArray arrayWithObject:contentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.pageViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];

    [self.view addConstraints:@[bottomConstraint, topConstraint, leftConstraint, rightConstraint]];

    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (AlbumContentViewController *)createContentViewControllerWithPageNum:(NSUInteger)pageNum
{
    AlbumContentViewController *albumContentViewController = [[AlbumContentViewController alloc] init];
    albumContentViewController.pageNum = pageNum;
    albumContentViewController.pictures = self.picturesForPages[[NSNumber numberWithUnsignedInteger:pageNum]];
    return albumContentViewController;
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
    
    NSArray *pages = [[self.picturesForPages allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber *page in pages) {
        NSUInteger pageNum = [page unsignedIntegerValue];
        AlbumContentViewController *contentViewController = [self createContentViewControllerWithPageNum:pageNum];
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
    return [self createContentViewControllerWithPageNum:currentIndex + 1];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = ((AlbumContentViewController *)viewController).pageNum;
    if (currentIndex == 0)
    {
        return nil;
    }
    return [self createContentViewControllerWithPageNum:currentIndex - 1];
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

#pragma mark - Upkar added for Image ScrollView and ImagePicker

- (void)addScrollView
{
    self.subView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width-200, self.view.frame.size.height)];
    [self.subView setContentSize:CGSizeMake(20*200, 200)];
    self.subView.scrollEnabled = YES;
    self.subView.layer.borderColor = [UIColor grayColor].CGColor;
    self.subView.backgroundColor = [UIColor grayColor];
    self.subView.layer.borderWidth = 3.0f;
    [self.subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.subView];
    
    self.heightConstraint = [NSLayoutConstraint
                            constraintWithItem:self.subView
                            attribute:NSLayoutAttributeHeight
                            relatedBy:NSLayoutRelationEqual
                            toItem:nil
                            attribute:NSLayoutAttributeHeight
                            multiplier:1.0
                            constant:200];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint
                                         constraintWithItem:self.subView
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                         attribute:NSLayoutAttributeLeft
                                         multiplier:1.0
                                         constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint
                                          constraintWithItem:self.subView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeRight
                                          multiplier:1.0
                                          constant:-200];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.subView
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1.0
                                           constant:0];
    
    [self.view addConstraints:@[self.heightConstraint, leftConstraint, rightConstraint, bottomConstraint]];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addButton.frame = CGRectMake(self.subView.frame.size.width+10,  self.view.frame.size.height, self.view.frame.size.width - self.subView.frame.size.width, self.view.frame.size.height);
    [self.addButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.addButton addTarget:self action:@selector(addButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    self.heightBtnConstraint = [NSLayoutConstraint
                               constraintWithItem:self.addButton
                               attribute:NSLayoutAttributeHeight
                               relatedBy:NSLayoutRelationEqual
                               toItem:nil
                               attribute:NSLayoutAttributeHeight
                               multiplier:1.0
                               constant:200];
    
    NSLayoutConstraint *leftBtnConstraint = [NSLayoutConstraint
                                            constraintWithItem:self.addButton
                                            attribute:NSLayoutAttributeLeft
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.subView
                                            attribute:NSLayoutAttributeRight
                                            multiplier:1.0
                                            constant:0];
    
    NSLayoutConstraint *rightBtnConstraint = [NSLayoutConstraint
                                             constraintWithItem:self.addButton
                                             attribute:NSLayoutAttributeRight
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self.view
                                             attribute:NSLayoutAttributeRight
                                             multiplier:1.0
                                             constant:0];
    
    NSLayoutConstraint *bottomBtnConstraint = [NSLayoutConstraint
                                              constraintWithItem:self.addButton
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.view
                                              attribute:NSLayoutAttributeBottom
                                              multiplier:1.0
                                              constant:0];
    
    
    [self.view addConstraints:@[self.heightBtnConstraint, leftBtnConstraint, rightBtnConstraint, bottomBtnConstraint]];
    
    
    self.pullUpButton = [[UIButton alloc] initWithFrame:CGRectMake(self.subView.frame.size.width+10,  self.view.frame.size.height, self.view.frame.size.width - self.subView.frame.size.width, 45)];
    self.pullUpButton.layer.backgroundColor = [UIColor yellowColor].CGColor;
    self.pullUpButton.layer.borderWidth = 3.0f;
    [self.pullUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pullUpButton addTarget:self action:@selector(pushButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.pullUpButton];
    
    self.heightPullConstraint = [NSLayoutConstraint
                                constraintWithItem:self.pullUpButton
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:NSLayoutAttributeHeight
                                multiplier:1.0
                                constant:45];
    
    NSLayoutConstraint *leftPullConstraint = [NSLayoutConstraint
                                             constraintWithItem:self.pullUpButton
                                             attribute:NSLayoutAttributeLeft
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self.addButton
                                             attribute:NSLayoutAttributeLeft
                                             multiplier:1.0
                                             constant:0];
    
    NSLayoutConstraint *rightPullConstraint = [NSLayoutConstraint
                                              constraintWithItem:self.pullUpButton
                                              attribute:NSLayoutAttributeRight
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.view
                                              attribute:NSLayoutAttributeRight
                                              multiplier:1.0
                                              constant:0];
    
    NSLayoutConstraint *bottomPullConstraint = [NSLayoutConstraint
                                               constraintWithItem:self.pullUpButton
                                               attribute:NSLayoutAttributeBottom
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:self.addButton
                                               attribute:NSLayoutAttributeTop
                                               multiplier:1.0
                                               constant:0];
    
    [self.view addConstraints:@[self.heightPullConstraint, leftPullConstraint, rightPullConstraint, bottomPullConstraint]];
}

-(void)pullUp
{
    [UIView animateWithDuration:1.0 animations:^{
        self.heightConstraint.constant = 200;
        self.heightBtnConstraint.constant = 200;
        self.heightPullConstraint.constant = 45;
        
        [self.subView layoutIfNeeded];
        [self.addButton layoutIfNeeded];
        [self.pullUpButton layoutIfNeeded];
        
        self.isSubViewVisible = YES;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)pushDown
{
    [UIView animateWithDuration:1.0 animations:^{
        self.heightConstraint.constant = 0;
        self.heightBtnConstraint.constant = 0;
        self.heightPullConstraint.constant = 45;
        
        [self.subView layoutIfNeeded];
        [self.addButton layoutIfNeeded];
        [self.pullUpButton layoutIfNeeded];
        
        self.isSubViewVisible = NO;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)launchController:(id)sender
{
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 14;
    elcPicker.returnsOriginalImage = NO; // Only return the fullScreenImage, not the fullResolutionImage
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
	ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.imagePickerDelegate = self;
    elcPicker.returnsOriginalImage = NO; // Only return the fullScreenImage, not the fullResolutionImage
	tablePicker.parent = elcPicker;
    
    // Move me
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark - ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
	
    for (UIView *v in [self.subView subviews]) {
        [v removeFromSuperview];
    }
    
	CGRect workingFrame = CGRectMake(0, 0, 200, 200);
	workingFrame.origin.x = 0;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
	
	for (NSDictionary *dict in info) {
        
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        [images addObject:image];
        
		UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
		[imageview setContentMode:UIViewContentModeScaleAspectFit];
		imageview.frame = workingFrame;
        imageview.layer.borderColor = [UIColor blackColor].CGColor;
        imageview.layer.borderWidth = 3.0f;
        imageview.contentMode = UIViewContentModeScaleToFill;
        // imageview.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
		
		[self.subView addSubview:imageview];
		
		workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
	}
    
    self.chosenImages = images;
	
	[self.subView setPagingEnabled:YES];
	[self.subView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonHandler:(id)sender
{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 14;
    elcPicker.returnsOriginalImage = NO; // Only return the fullScreenImage, not the fullResolutionImage
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (IBAction)pushButtonHandler:(id)sender
{
    if(self.isSubViewVisible)
        [self pushDown];
    else
        [self pullUp];
}

@end
