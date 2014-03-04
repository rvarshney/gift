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
#import "MBProgressHUD.h"
#import "Album.h"
#import "TemplateCell.h"
#import "Client.h"
#import "Album.h"
#import <Parse/Parse.h>

@interface TemplatesViewController ()

@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) Template *currentTemplate;
@property BOOL isFirstLoad;

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
    self.isFirstLoad = YES;

    // Start the display area from under the status bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    if (self.isFirstLoad) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

    [[Client instance] templates:^(NSArray *templates, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.templates = templates;
        [self.collectionView reloadData];
    }];
    
    [self.collectionView registerClass:[TemplateCell class] forCellWithReuseIdentifier:@"TemplateCell"];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view setUserInteractionEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.isFirstLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    [cell.templateImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    cell.templateImage.file = ((Template *)self.templates[indexPath.row]).themeCover;
    [cell.templateImage loadInBackground];
    
    return cell;
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
