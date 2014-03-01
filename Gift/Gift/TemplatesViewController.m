//
//  TemplatesViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "TemplatesViewController.h"
#import "TemplatesPreviewViewController.h"
#import "AlbumViewController.h"
#import "Album.h"
#import "TemplateCell.h"
#import "Client.h"
#import "Album.h"
#import <Parse/Parse.h>

@interface TemplatesViewController ()

@property (nonatomic, strong)NSArray *templates;
@property (nonatomic, strong)Template *currentTemplate;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@end

@implementation TemplatesViewController

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
    
    self.title = @"Templates";

    [[Client instance] templates:^(NSArray *templates, NSError *error) {
        self.templates = templates;
        [self.collectionView reloadData];
    }];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TemplateCell" bundle:nil] forCellWithReuseIdentifier:@"TemplateCell"];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view setUserInteractionEnabled:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //add tap gesture on main template view to detect the tap outside the modal. This should cancel the modal
    if(!self.tapGesture)
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(templateTapHandler:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.tapGesture];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(self.tapGesture)
       [self.view.window removeGestureRecognizer:self.tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    [cell.templateImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self displayAlbumCoverForCell:cell];
    
    cell.templateImage.file = ((Template *)self.templates[indexPath.row]).themeCover;
    [cell.templateImage loadInBackground];
    
    return cell;
}

-(void)displayAlbumCoverForCell:(TemplateCell*)cell{
    //    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 600, 600);
    
    //    cell.templateImage.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    //    cell.templateImage.transform = CGAffineTransformMakeScale(2, 2);
    
    //    cell.templateImage.layer.borderColor = [UIColor blackColor].CGColor;
    //    cell.templateImage.layer.borderWidth = 2.0f;
    
    
    //    CALayer *layer = cell.templateImage.layer;
    //    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    //    rotationAndPerspectiveTransform.m34 = 1.0 / -500;
    //    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
    //    layer.transform = rotationAndPerspectiveTransform;
    
    
    
    //0.6
    //    cell.templateImage.transform = CGAffineTransformMake(0.6, 0.6, 1, 0, 0, 0);
    //        cell.templateImage.transform = CGAffineTransformMakeScale(1, 1); //rotation in radians
    //    cell.templateImage.transform = CGAffineTransformScale(cell.templateImage.transform, 2, 2);
    
    //    cell.templateImage.transform = CGAffineTransformMakeRotation(-24*M_PI/180);
    
    
    //does not work
    //    cell.templateImage.transform = CGAffineTransformMake(1, 0, -0.2, 1, 0, 0);
    //    CGRectApplyAffineTransform(cell.templateImage.bounds, CGAffineTransformMakeRotation(-24*M_PI/180));
    //    [cell.templateImage setTransform:CGAffineTransformMakeScale (3, 1)];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //show preview
    TemplatesPreviewViewController *previewVC = [[TemplatesPreviewViewController alloc]init];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:previewVC];
    nvc.modalPresentationStyle = UIModalPresentationFormSheet;
    nvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.currentTemplate = self.templates[indexPath.row];
    previewVC.template = self.currentTemplate;
    
    //add cancel button to the nvc
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelPreview:)];
    previewVC.navigationItem.leftBarButtonItem = cancelButton;
    
//    //add select button to the nvc
    UIBarButtonItem *createAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(createAlbum:)];
    previewVC.navigationItem.rightBarButtonItem = createAlbumButton;
    
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

-(void)createAlbum:(UIBarButtonItem *)sender{
    NSLog(@"createAlbum");
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    //TODO: how to get the correct template index here?
    Album *album = [[Client instance] createAlbumForUser:[PFUser currentUser] title:@"Untitled Album" template:self.currentTemplate completion:nil];
    
    AlbumViewController *albumViewController = [[AlbumViewController alloc]init];
    albumViewController.album = album;
    albumViewController.picturesForAlbum = [[NSMutableArray alloc]init];
    
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.templates count];
}

-(void)cancelPreview:(UIBarButtonItem *)sender{
    NSLog(@"cancelPreview");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)templateTapHandler:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //Passing nil gives us coordinates in the window
        CGPoint location = [recognizer locationInView:nil];
        
        //Convert tap location into the local view's coordinate system. If outside, dismiss the view.
        if (![self.presentedViewController.view pointInside:[self.presentedViewController.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

@end
