//
//  AlbumViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumViewController.h"
#import "AlbumContentViewController.h"
#import "AlbumImageView.h"
#import "ShippingViewController.h"
#import "Client.h"
#import "MBProgressHUD.h"
#import "Picture.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface AlbumViewController ()

@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) NSMutableDictionary *picturesForPages;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIScrollView *pictureScrollView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIImageView *scrollViewToggleView;
@property (nonatomic, strong) NSLayoutConstraint *bottomBtnConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, assign) BOOL isScrollViewVisible;
@property (nonatomic, assign) CGRect moveStartFrame;
@property (nonatomic, assign) CGPoint movePreviousLocation;
@property (nonatomic, strong) UIImageView *moveImageView;
@property (nonatomic, strong) AlbumContentViewController *moveStartPage;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSString *albumFile;
@property CGFloat lastPictureLocation;

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
    
    // Set up editable title
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 24)];
    self.titleTextField.text = self.album.title;
    self.titleTextField.font = [UIFont boldSystemFontOfSize:17];
    self.titleTextField.textColor = [UIColor blackColor];
    self.titleTextField.textAlignment = NSTextAlignmentCenter;
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    self.titleTextField.delegate = self;
    self.navigationItem.titleView = self.titleTextField;

    // Add edit navigation bar button
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonHandler:)];

    // Add email navigation bar button
    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"email.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(emailButtonHandler:)];
    
    // Add print navigation bar button
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"print.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(printButtonHandler:)];
    
    // Add the email and print buttons to the right
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:printButton, emailButton, editButton, nil];
    
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
    
    // Set up 24 pages in the album
    for (NSUInteger i = 0; i < 24; i++) {
        NSNumber *pageNum = [NSNumber numberWithUnsignedInteger:i];
        if (!self.picturesForPages[pageNum]) {
            self.picturesForPages[pageNum] = [[NSMutableArray alloc] init];
        }
    }
    
    [self setupAlbumPageViewController];
    
    [self setupPictureScrollView];
    
    // Setup long press gesture recognizer
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    gestureRecognizer.minimumPressDuration = 0.3;
    [gestureRecognizer addTarget:self action:@selector(longPressHandler:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer: gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - Private methods

- (UIImage *)blackAndWhiteForImage:(UIImage *)image
{
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIImage *output = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:1.0], @"inputColor", [[CIColor alloc] initWithColor:[UIColor whiteColor]], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiImage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiImage];
    CGImageRelease(cgiImage);
    
    return newImage;
}

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
    albumContentViewController.album = self.album;
    albumContentViewController.pictures = self.picturesForPages[[NSNumber numberWithUnsignedInteger:pageNum]];
    return albumContentViewController;
}

- (void)editButtonHandler:(id)sender
{
    [self.titleTextField becomeFirstResponder];
}

- (void)emailButtonHandler:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Building your album...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self printAlbumToFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSError *error = nil;
            BOOL emailSent = [self sendEmailWithSubject:self.album.title to:[NSArray arrayWithObject:@""] cc:nil bcc:nil body:@"Check out my new album built on the Memories app!" isHTML:YES delegate:self files:[NSArray arrayWithObjects:self.albumFile, nil] error:&error];
            if (!emailSent) {
                NSLog(@"Failed with error: %@",error);
            }
        });
    });
}

- (void)printButtonHandler:(id)sender
{
    ShippingViewController *shippingViewController = [[ShippingViewController alloc] init];
    shippingViewController.album = self.album;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Building your album...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self printAlbumToFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            shippingViewController.albumFile = self.albumFile;
            [self.navigationController pushViewController:shippingViewController animated:YES];
        });
    });
}

- (void)printAlbumToFile
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

    self.albumFile = documentDirectoryFilename;
}

#pragma mark - UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Update the album title
    self.album.title = textField.text;
    [self.album saveInBackground];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

# pragma mark - Long press gesture

- (AlbumImageView *)albumImageViewForPage:(NSUInteger)pageNum withFrame:(CGRect)frame
{
    AlbumImageView *albumImageView;
 
    NSNumber *x = [NSNumber numberWithFloat:frame.origin.x];
    NSNumber *y = [NSNumber numberWithFloat:frame.origin.y];
    NSNumber *width = [NSNumber numberWithFloat:frame.size.width];
    NSNumber *height = [NSNumber numberWithFloat:frame.size.height];
    
    if ([self.moveImageView class] == [AlbumImageView class]) {
        // Update the location of the album image
        albumImageView = (AlbumImageView *)self.moveImageView;
        [((NSMutableArray *)self.picturesForPages[albumImageView.picture.pageNumber]) removeObject:albumImageView.picture];
        albumImageView.picture.x = x;
        albumImageView.picture.y = y;
        albumImageView.picture.width = width;
        albumImageView.picture.height = height;
        albumImageView.picture.pageNumber = [NSNumber numberWithUnsignedInteger:pageNum];
        [albumImageView.picture saveInBackground];
        [albumImageView updateFrame];
        
        [((NSMutableArray *)self.picturesForPages[albumImageView.picture.pageNumber]) addObject:albumImageView.picture];

    } else {
        NSString *filter = [[self.album.template objectForKey:@"themeData"] objectForKey:@"filter"];
        
        UIImage *saveImage = self.moveImageView.image;
        if ([filter isEqualToString:@"BW"]) {
            saveImage = [self blackAndWhiteForImage:self.moveImageView.image];
        }

        NSData *imageData = UIImageJPEGRepresentation(saveImage, 0);
        Picture *picture = [[Client instance] createPictureForAlbum:self.album imageData:imageData pageNumber:pageNum rotationAngle:[NSNumber numberWithFloat:0] x:x y:y height:height width:width completion:nil];
        
        [((NSMutableArray *)self.picturesForPages[[NSNumber numberWithUnsignedInteger:pageNum]]) addObject:picture];
        
        albumImageView = [[AlbumImageView alloc] initWithPicture:picture];
        albumImageView.image = [UIImage imageWithData:imageData];
    }
    return albumImageView;
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [gesture locationInView:self.view];
        CGPoint locationInScrollView = [gesture locationInView:self.pictureScrollView];
        
        AlbumContentViewController *firstPage = self.pageViewController.viewControllers[0];
        AlbumContentViewController *secondPage = self.pageViewController.viewControllers[1];
        
        CGPoint locationInFirstPage = [gesture locationInView:firstPage.view];
        CGPoint locationInSecondPage = [gesture locationInView:secondPage.view];
        
        if (CGRectContainsPoint(self.pictureScrollView.bounds, locationInScrollView)) {
            for (UIView *view in self.pictureScrollView.subviews) {
                if (CGRectContainsPoint(view.frame, locationInScrollView) && [view class] == [UIImageView class]) {
                    self.moveStartFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    view.frame = CGRectMake(locationInView.x - 200/2, locationInView.y - 200/2, 200, 200);
                    [view removeFromSuperview];
                    [self.view addSubview:view];
                    self.movePreviousLocation = locationInView;
                    self.moveImageView = (UIImageView *)view;
                    [self showPlacementViews];
                    NSLog(@"Long press detected in scroll view");
                    break;
                }
            }
        } else if (CGRectContainsPoint(firstPage.view.bounds, locationInFirstPage)) {
            for (UIView *view in firstPage.view.subviews) {
                if (CGRectContainsPoint(view.frame, locationInFirstPage) && [view class] == [AlbumImageView class]) {
                    self.moveStartFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    self.moveStartPage = firstPage;
                    view.frame = CGRectMake(locationInView.x - 200/2, locationInView.y - 200/2, 200, 200);
                    [view removeFromSuperview];
                    [self.view addSubview:view];
                    self.movePreviousLocation = locationInView;
                    self.moveImageView = (UIImageView *)view;
                    [self showPlacementViews];
                    NSLog(@"Long press detected in first page");
                    break;
                }
            }
        } else if (CGRectContainsPoint(secondPage.view.bounds, locationInSecondPage)) {
            for (UIView *view in secondPage.view.subviews) {
                if (CGRectContainsPoint(view.frame, locationInSecondPage) && [view class] == [AlbumImageView class]) {
                    self.moveStartFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    self.moveStartPage = secondPage;
                    view.frame = CGRectMake(locationInView.x - 200/2, locationInView.y - 200/2, 200, 200);
                    [view removeFromSuperview];
                    [self.view addSubview:view];
                    self.movePreviousLocation = locationInView;
                    self.moveImageView = (UIImageView *)view;
                    [self showPlacementViews];
                    NSLog(@"Long press detected in second page");
                    break;
                }
            }
        }
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.moveImageView) {
            CGPoint location = [gesture locationInView:self.view];
            
            AlbumContentViewController *firstPage = self.pageViewController.viewControllers[0];
            AlbumContentViewController *secondPage = self.pageViewController.viewControllers[1];
            
            CGPoint locationInFirstPage = [gesture locationInView:firstPage.view];
            CGPoint locationInSecondPage = [gesture locationInView:secondPage.view];
            
            CGRect placementFrame;
            if (CGRectContainsPoint(firstPage.view.bounds, locationInFirstPage)) {
                placementFrame = [firstPage placementRectForLocation:locationInFirstPage];
                if (!CGRectEqualToRect(placementFrame, CGRectZero)) {
                    placementFrame = [self.view convertRect:placementFrame fromView:firstPage.view];
                }
            } else if (CGRectContainsPoint(secondPage.view.bounds, locationInSecondPage)) {
                placementFrame = [secondPage placementRectForLocation:locationInSecondPage];
                if (!CGRectEqualToRect(placementFrame, CGRectZero)) {
                    placementFrame = [self.view convertRect:placementFrame fromView:secondPage.view];
                }
            }
            if (CGRectEqualToRect(placementFrame, CGRectZero)) {
                placementFrame = CGRectMake(location.x - 200/2, location.y - 200/2, 200, 200);
            }
            [self.moveImageView setFrame:placementFrame];
            self.movePreviousLocation = location;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self hidePlacementViews];

        if (self.moveImageView) {
            CGPoint locationInScrollView = [gesture locationInView:self.pictureScrollView];

            AlbumContentViewController *firstPage = self.pageViewController.viewControllers[0];
            AlbumContentViewController *secondPage = self.pageViewController.viewControllers[1];

            CGPoint locationInFirstPage = [gesture locationInView:firstPage.view];
            CGPoint locationInSecondPage = [gesture locationInView:secondPage.view];
            
            if (CGRectContainsPoint(self.pictureScrollView.bounds, locationInScrollView)) {
                if ([self.moveImageView class] == [AlbumImageView class]) {
                    // Snap back to original location
                    NSLog(@"Snapping to original location");
                    AlbumImageView *albumImageView = [self albumImageViewForPage:self.moveStartPage.pageNum withFrame:self.moveStartFrame];
                    [self.moveImageView removeFromSuperview];
                    [self.moveStartPage.view addSubview:albumImageView];
                } else {
                    // Snap back to the scroll view
                    NSLog(@"Snapping to scroll view");
                    [self.moveImageView removeFromSuperview];
                    self.moveImageView.frame = self.moveStartFrame;
                    [self.pictureScrollView addSubview:self.moveImageView];
                }
            } else if (CGRectContainsPoint(firstPage.view.bounds, locationInFirstPage)) {
                // Add to first page
                NSLog(@"Moving to first page");
                CGRect placementFrame = [firstPage.view convertRect:self.moveImageView.frame fromView:self.view];
                AlbumImageView *albumImageView = [self albumImageViewForPage:firstPage.pageNum withFrame:placementFrame];
                [self.moveImageView removeFromSuperview];
                [firstPage.view addSubview:albumImageView];
                
            } else if (CGRectContainsPoint(secondPage.view.bounds, locationInSecondPage)) {
                // Add to second page
                NSLog(@"Moving to second page");
                CGRect placementFrame = [secondPage.view convertRect:self.moveImageView.frame fromView:self.view];
                AlbumImageView *albumImageView = [self albumImageViewForPage:secondPage.pageNum withFrame:placementFrame];
                [self.moveImageView removeFromSuperview];
                [secondPage.view addSubview:albumImageView];
                
            } else {
                // It was dropped outside the bounds of both pages
                if ([self.moveImageView class] == [AlbumImageView class]) {
                    // Delete the picture
                    NSLog(@"Deleting");
                    AlbumImageView *albumImageView = (AlbumImageView *)self.moveImageView;
                    [(NSMutableArray *)self.picturesForPages[[NSNumber numberWithUnsignedInteger:self.moveStartPage.pageNum]] removeObject:albumImageView.picture];
                    [self.moveImageView removeFromSuperview];
                    [albumImageView.picture deleteInBackground];
                } else {
                    // Snap back to the scroll view
                    NSLog(@"Snapping to scroll view");
                    [self.moveImageView removeFromSuperview];
                    self.moveImageView.frame = self.moveStartFrame;
                    [self.pictureScrollView addSubview:self.moveImageView];
                }
            }
        }
        self.moveImageView = nil;
        
    } else if (gesture.state == UIGestureRecognizerStateCancelled) {
        [self hidePlacementViews];

        if (self.moveImageView) {
            if ([self.moveImageView class] == [AlbumImageView class]) {
                // Snap back to original location
                NSLog(@"Snapping to original location");
                AlbumImageView *albumImageView = [self albumImageViewForPage:self.moveStartPage.pageNum withFrame:self.moveStartFrame];
                [self.moveImageView removeFromSuperview];
                [self.moveStartPage.view addSubview:albumImageView];
            } else {
                // Snap back to the scroll view
                NSLog(@"Snapping to scroll view");
                [self.moveImageView removeFromSuperview];
                self.moveImageView.frame = self.moveStartFrame;
                [self.pictureScrollView addSubview:self.moveImageView];
            }
        }
        self.moveImageView = nil;
    }
}

- (void)setupPictureScrollView
{
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tweed.png"]];
    self.pictureScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    self.pictureScrollView.contentSize = CGSizeMake(20 * 200, 150);
    self.pictureScrollView.scrollEnabled = YES;
    self.pictureScrollView.backgroundColor = background;
    self.pictureScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pictureScrollView showsHorizontalScrollIndicator];
    [self.view addSubview:self.pictureScrollView];

    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:150];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-150];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraints:@[heightConstraint, leftConstraint, rightConstraint, self.bottomConstraint]];
    
    UIImage *btnImage = [UIImage imageNamed:@"plus_image.png"];
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:btnImage forState:UIControlStateNormal];
    self.addButton.contentMode = UIViewContentModeCenter;
    self.addButton.backgroundColor = background;
    self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addButton addTarget:self action:@selector(addButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    NSLayoutConstraint *heightBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:150];
    NSLayoutConstraint *leftBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.pictureScrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *rightBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    self.bottomBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraints:@[heightBtnConstraint, leftBtnConstraint, rightBtnConstraint, self.bottomBtnConstraint]];
    
    self.scrollViewToggleView = [[UIImageView alloc]init];
    [self.scrollViewToggleView setUserInteractionEnabled:YES];
    self.scrollViewToggleView.image = [UIImage imageNamed:@"tweed.png"];
    [self.scrollViewToggleView setTranslatesAutoresizingMaskIntoConstraints:NO];

    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(scrollViewButtonSwipedDown:)];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    //[self.pictureScrollView addGestureRecognizer:swipeGestureDown];
    [self.scrollViewToggleView addGestureRecognizer:swipeGestureDown];
    
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(scrollViewButtonSwipedUp:)];
    [swipeGestureUp setDirection: UISwipeGestureRecognizerDirectionUp];
    //[self.pictureScrollView addGestureRecognizer:swipeGestureUp];
    [self.scrollViewToggleView addGestureRecognizer:swipeGestureUp];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushButtonHandler:)];
    //[self.pictureScrollView addGestureRecognizer:tapGesture];

    [self.scrollViewToggleView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.scrollViewToggleView];
    
    NSLayoutConstraint *heightPullConstraint = [NSLayoutConstraint constraintWithItem:self.scrollViewToggleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:65];
    NSLayoutConstraint *widthPullConstraint = [NSLayoutConstraint constraintWithItem:self.scrollViewToggleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:65];
    NSLayoutConstraint *rightPullConstraint = [NSLayoutConstraint constraintWithItem:self.scrollViewToggleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomPullConstraint = [NSLayoutConstraint constraintWithItem:self.scrollViewToggleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.addButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.view addConstraints:@[heightPullConstraint, widthPullConstraint, rightPullConstraint, bottomPullConstraint]];
    
    // Start in pull up state
    self.isScrollViewVisible = YES;
}

-(void)pullUp
{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomConstraint.constant = 0;
        self.bottomBtnConstraint.constant = 0;
        [self.pictureScrollView layoutIfNeeded];
        [self.addButton layoutIfNeeded];
        [self.scrollViewToggleView layoutIfNeeded];
        self.isScrollViewVisible = YES;
    } completion:nil];
}

-(void)pushDown
{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomConstraint.constant = 150;
        self.bottomBtnConstraint.constant = 150;
        [self.pictureScrollView layoutIfNeeded];
        [self.addButton layoutIfNeeded];
        [self.scrollViewToggleView layoutIfNeeded];
        self.isScrollViewVisible = NO;
    } completion:nil];
}

- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    CGRect workingFrame = CGRectMake(0, 0, 150, 150);
    workingFrame.origin.x = self.lastPictureLocation;

    for (NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.frame = workingFrame;
        imageView.bounds = CGRectInset(imageView.frame, 12.0f, 12.0f);
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        [self.pictureScrollView addSubview:imageView];
        workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
        self.lastPictureLocation = workingFrame.origin.x;
	}
    
    [self.pictureScrollView setPagingEnabled:YES];
    [self.pictureScrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void)imagePickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonHandler:(id)sender
{
    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc ] initWithTitle:@"Import Photos"];
    [picker setDelegate:self];
    [picker setIsMultipleSelectionEnabled:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)pushButtonHandler:(id)sender
{
    if (self.isScrollViewVisible) {
        [self pushDown];
    } else {
        [self pullUp];
    }
}

- (void)scrollViewButtonSwipedDown:(UISwipeGestureRecognizer *)recognizer
{
    if (self.isScrollViewVisible) {
        [self pushDown];
    }
}

- (void)scrollViewButtonSwipedUp:(UISwipeGestureRecognizer *)recognizer
{
    if (!self.isScrollViewVisible) {
        [self pullUp];
    }
}

- (void)showPlacementViews
{
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0.3f;
    [self.view addSubview:self.overlayView];
    
    [(AlbumContentViewController *)self.pageViewController.viewControllers[0] showPlacementViews];
    [(AlbumContentViewController *)self.pageViewController.viewControllers[1] showPlacementViews];
}

- (void)hidePlacementViews
{
    [self.overlayView removeFromSuperview];
    [(AlbumContentViewController *)self.pageViewController.viewControllers[0] hidePlacementViews];
    [(AlbumContentViewController *)self.pageViewController.viewControllers[1] hidePlacementViews];
}

@end
