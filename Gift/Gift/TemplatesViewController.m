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

@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) Template *currentTemplate;

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

- (void)displayAlbumCoverForCell:(TemplateCell *)cell
{
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

    //    cell.templateImage.transform = CGAffineTransformMake(0.6, 0.6, 1, 0, 0, 0);
    //    cell.templateImage.transform = CGAffineTransformMakeScale(1, 1); //rotation in radians
    //    cell.templateImage.transform = CGAffineTransformScale(cell.templateImage.transform, 2, 2);
    //    cell.templateImage.transform = CGAffineTransformMakeRotation(-24*M_PI/180);
    //    cell.templateImage.transform = CGAffineTransformMake(1, 0, -0.2, 1, 0, 0);
    //    CGRectApplyAffineTransform(cell.templateImage.bounds, CGAffineTransformMakeRotation(-24*M_PI/180));
    //    [cell.templateImage setTransform:CGAffineTransformMakeScale (3, 1)];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentTemplate = self.templates[indexPath.row];
    
    // Show preview
    TemplatesPreviewViewController *previewViewController = [[TemplatesPreviewViewController alloc]init];
    previewViewController.template = self.currentTemplate;
    previewViewController.title = self.currentTemplate.title;

    // Embed in navigation controller
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:previewViewController];
    navigationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Add cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelPreview:)];
    previewViewController.navigationItem.leftBarButtonItem = cancelButton;
    
    // Add select button
    UIBarButtonItem *createAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(createAlbum:)];
    previewViewController.navigationItem.rightBarButtonItem = createAlbumButton;
    
    [self.navigationController presentViewController:navigationViewController animated:YES completion:nil];
}

-(void)createAlbum:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

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

- (void)cancelPreview:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
