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
#import "Picture.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface AlbumViewController ()

@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) NSMutableDictionary *picturesForPages;
@property (nonatomic, strong) UIPageViewController *pageViewController;


@property (nonatomic, strong) UIScrollView *pictureScrollView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *pullUpButton;


@property (nonatomic, strong) NSLayoutConstraint *heightPullConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightBtnConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@property (nonatomic, assign) BOOL isScrollViewVisible;

@property (nonatomic, assign) CGRect moveStartFrame;
@property (nonatomic, assign) CGPoint movePreviousLocation;
@property (nonatomic, strong) UIImageView *moveImageView;
@property (nonatomic, strong) AlbumContentViewController *moveStartPage;

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
    UITextField *titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 22)];
    titleTextField.text = self.album.title;
    titleTextField.font = [UIFont boldSystemFontOfSize:19];
    titleTextField.textColor = [UIColor blackColor];
    titleTextField.textAlignment = NSTextAlignmentCenter;
    titleTextField.returnKeyType = UIReturnKeyDone;
    titleTextField.delegate = self;
    self.navigationItem.titleView = titleTextField;

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
    
    // Check if this is a brand new album
    if (self.picturesForPages.count == 0) {
        self.picturesForPages[[NSNumber numberWithUnsignedInteger:0]] = [[NSMutableArray alloc] init];
    }
    
    // Even out the number of pages we see in the album
    NSUInteger maxPageNum = [[[self.picturesForPages allKeys] valueForKeyPath:@"@max.unsignedIntegerValue"]unsignedIntegerValue];
    if (maxPageNum % 2 == 0) {
        self.picturesForPages[[NSNumber numberWithUnsignedInteger:maxPageNum + 1]] = [[NSMutableArray alloc] init];
    }
    
    [self setupAlbumPageViewController];
    
    [self setupPictureScrollView];

    // Setup long press gesture recognizer
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [gestureRecognizer addTarget:self action:@selector(longPressHandler:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer: gestureRecognizer];
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
    albumContentViewController.album = self.album;
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

- (AlbumImageView *)albumImageViewForPage:(NSUInteger)pageNum atLocation:(CGPoint)atLocation
{
    AlbumImageView *albumImageView;
    
    NSNumber *xLocation = [NSNumber numberWithFloat:(atLocation.x - self.moveImageView.bounds.size.width / 2)];
    NSNumber *yLocation = [NSNumber numberWithFloat:(atLocation.y - self.moveImageView.bounds.size.height / 2)];
    
    if ([self.moveImageView class] == [AlbumImageView class]) {
        // Update the location of the album image
        albumImageView = (AlbumImageView *)self.moveImageView;
        [((NSMutableArray *)self.picturesForPages[albumImageView.picture.pageNumber]) removeObject:albumImageView.picture];
        albumImageView.picture.x = xLocation;
        albumImageView.picture.y = yLocation;
        albumImageView.picture.pageNumber = [NSNumber numberWithUnsignedInteger:pageNum];
        [albumImageView.picture saveInBackground];
        [albumImageView updateFrame];
        
        [((NSMutableArray *)self.picturesForPages[albumImageView.picture.pageNumber]) addObject:albumImageView.picture];

    } else {
        NSString *imageName = objc_getAssociatedObject(self.moveImageView, "imageName");
        NSData *imageData = UIImageJPEGRepresentation(self.moveImageView.image, 0);
        Picture *picture = [[Client instance] createPictureForAlbum:self.album imageName:imageName imageData:imageData pageNumber:pageNum rotationAngle:[NSNumber numberWithFloat:0] x:xLocation y:yLocation height:[NSNumber numberWithFloat:200] width:[NSNumber numberWithFloat:200] completion:nil];
        
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
                    view.frame = CGRectMake(locationInView.x - 150/2, locationInView.y - 150/2, 150, 150);
                    [view removeFromSuperview];
                    [self.view addSubview:view];
                    self.movePreviousLocation = locationInView;
                    self.moveImageView = (UIImageView *)view;
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
                    NSLog(@"Long press detected in second page");
                    break;
                }
            }
        }
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.moveImageView) {
            CGPoint location = [gesture locationInView:self.view];
            CGRect frame = self.moveImageView.frame;
            frame.origin.x += location.x - self.movePreviousLocation.x;
            frame.origin.y += location.y - self.movePreviousLocation.y;
            [self.moveImageView setFrame:frame];
            self.movePreviousLocation = location;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
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
                    CGFloat centerX = self.moveStartFrame.origin.x + self.moveStartFrame.size.width / 2;
                    CGFloat centerY = self.moveStartFrame.origin.y + self.moveStartFrame.size.height / 2;
                    AlbumImageView *albumImageView = [self albumImageViewForPage:self.moveStartPage.pageNum atLocation:CGPointMake(centerX, centerY)];
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
                AlbumImageView *albumImageView = [self albumImageViewForPage:firstPage.pageNum atLocation:locationInFirstPage];
                [self.moveImageView removeFromSuperview];
                [firstPage.view addSubview:albumImageView];
                
            } else if (CGRectContainsPoint(secondPage.view.bounds, locationInSecondPage)) {
                // Add to second page
                NSLog(@"Moving to second page");
                AlbumImageView *albumImageView = [self albumImageViewForPage:secondPage.pageNum atLocation:locationInSecondPage];
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
        if (self.moveImageView) {
            if ([self.moveImageView class] == [AlbumImageView class]) {
                // Snap back to original location
                NSLog(@"Snapping to original location");
                CGFloat centerX = self.moveStartFrame.origin.x + self.moveStartFrame.size.width / 2;
                CGFloat centerY = self.moveStartFrame.origin.y + self.moveStartFrame.size.height / 2;
                AlbumImageView *albumImageView = [self albumImageViewForPage:self.moveStartPage.pageNum atLocation:CGPointMake(centerX, centerY)];
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
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    self.pictureScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width - 150, self.view.frame.size.height)];
    [self.pictureScrollView setContentSize:CGSizeMake(20 * 200, 150)];
    self.pictureScrollView.scrollEnabled = YES;
    //self.pictureScrollView.layer.borderColor = [UIColor grayColor].CGColor;
    self.pictureScrollView.backgroundColor = background;
    //self.pictureScrollView.layer.borderWidth = 3.0f;
    [self.pictureScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.pictureScrollView];

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:150];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-150];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.pictureScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[self.heightConstraint, leftConstraint, rightConstraint, bottomConstraint]];
    
    UIImage *btnImage = [UIImage imageNamed:@"plus_white.png"];
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:btnImage forState:UIControlStateNormal];
    self.addButton.frame = CGRectMake(self.pictureScrollView.frame.size.width + 10, self.view.frame.size.height, self.view.frame.size.width - self.pictureScrollView.frame.size.width, self.view.frame.size.height);
    [self.addButton setBackgroundColor:background];
    [self.addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.addButton addTarget:self action:@selector(addButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    self.heightBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:150];
    NSLayoutConstraint *leftBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.pictureScrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *rightBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomBtnConstraint = [NSLayoutConstraint constraintWithItem:self.addButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[self.heightBtnConstraint, leftBtnConstraint, rightBtnConstraint, bottomBtnConstraint]];
    
    // Pull up button
    self.pullUpButton = [[UIButton alloc] initWithFrame:CGRectMake(self.pictureScrollView.frame.size.width + 10,  self.view.frame.size.height, self.view.frame.size.width - self.pictureScrollView.frame.size.width, 45)];
    self.pullUpButton.layer.backgroundColor = [UIColor yellowColor].CGColor;
    self.pullUpButton.layer.borderWidth = 3.0f;
    [self.pullUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pullUpButton addTarget:self action:@selector(pushButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.pullUpButton];
    
    self.heightPullConstraint = [NSLayoutConstraint constraintWithItem:self.pullUpButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:45];
    
    NSLayoutConstraint *leftPullConstraint = [NSLayoutConstraint constraintWithItem:self.pullUpButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.addButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightPullConstraint = [NSLayoutConstraint constraintWithItem:self.pullUpButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomPullConstraint = [NSLayoutConstraint constraintWithItem:self.pullUpButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.addButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[self.heightPullConstraint, leftPullConstraint, rightPullConstraint, bottomPullConstraint]];
    
    // Start in pull up state
    self.isScrollViewVisible = YES;
}

-(void)pullUp
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect pictureFrame = self.pictureScrollView.frame;
        pictureFrame.origin.y -= pictureFrame.size.height;
        self.pictureScrollView.frame = pictureFrame;
        
        CGRect frame = self.addButton.frame;
        frame.origin.y -= pictureFrame.size.height;
        self.addButton.frame = frame;
        
        frame = self.pullUpButton.frame;
        frame.origin.y -= pictureFrame.size.height;
        self.pullUpButton.frame = frame;

        self.isScrollViewVisible = YES;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)pushDown
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect pictureFrame = self.pictureScrollView.frame;
        pictureFrame.origin.y += pictureFrame.size.height;
        self.pictureScrollView.frame = pictureFrame;

        CGRect frame = self.addButton.frame;
        frame.origin.y += pictureFrame.size.height;
        self.addButton.frame = frame;
        
        frame = self.pullUpButton.frame;
        frame.origin.y += pictureFrame.size.height;
        self.pullUpButton.frame = frame;

        self.isScrollViewVisible = NO;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
	
    for (UIView *v in [self.pictureScrollView subviews]) {
        [v removeFromSuperview];
    }
    
    CGRect workingFrame = CGRectMake(0, 0, 150, 150);
    workingFrame.origin.x = 0;
    
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
        
        NSString *assetURL = [dict objectForKey:UIImagePickerControllerReferenceURL];
        objc_setAssociatedObject(imageView, "imageName", [assetURL lastPathComponent], OBJC_ASSOCIATION_RETAIN);
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
    PhotoPickerViewController *picker = [[PhotoPickerViewController alloc ] initWithTitle:@"Select Photo"];
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

@end
