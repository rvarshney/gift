//
//  AlbumCollectionViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "AlbumCollectionViewController.h"
#import "AlbumCollectionViewLayout.h"
#import "AlbumCell.h"
#import "ProfileViewController.h"
#import "AlbumViewController.h"
#import "MBProgressHUD.h"
#import "Client.h"
#import "TemplateQuiltViewController.h"

@interface AlbumCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) NSMutableDictionary *picturesForAlbums;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property BOOL isFirstLoad;

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

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:203.0f/255 blue:209.0f/255 alpha:1];
    
    self.title = @"My Albums";
    self.isFirstLoad = YES;
    
    // Register for logout events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutButtonHandler:) name:@"logout" object:nil];

    // Logout button
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = -14.0f;

    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonHandler:)];
    self.navigationItem.leftBarButtonItems = @[spacer, logoutButton];

    // Initialize data
    self.picturesForAlbums = [[NSMutableDictionary alloc] init];

    [self setupProfileView];

    [self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        ((AlbumCollectionViewLayout *)self.collectionViewLayout).numColumns = 4;
    } else {
        ((AlbumCollectionViewLayout *)self.collectionViewLayout).numColumns = 3;
    }

    [self loadAlbums];
    [self loadTemplates];

    self.isFirstLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = self.albums[indexPath.section];
    AlbumCell *albumCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    albumCell.titleLabel.text = album.title;

    // Special case the create new album
    if (indexPath.section != 0) {
        NSArray *pictures = self.picturesForAlbums[album.objectId];
        if (pictures && pictures.count != 0) {
            // Load the first image of the album as the cover page
            albumCell.coverPictureImageView.file = ((Picture *)pictures[0]).image;
            albumCell.coverPictureImageView.alpha = 1.0f;
            [albumCell.coverPictureImageView loadInBackground];
        } else {
            albumCell.coverPictureImageView.image = nil;
        }
    }
    return albumCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = self.albums[indexPath.section];

    // First album is create new album
    if (indexPath.section == 0) {
        [self newButtonHandler:nil];
    } else {
        AlbumViewController *albumViewController = [[AlbumViewController alloc] init];
        albumViewController.album = album;
        albumViewController.picturesForAlbum = self.picturesForAlbums[album.objectId];
        [self.navigationController pushViewController:albumViewController animated:YES];
    }
}

#pragma mark - View Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        ((AlbumCollectionViewLayout *)self.collectionViewLayout).numColumns = 4;
    } else {
        ((AlbumCollectionViewLayout *)self.collectionViewLayout).numColumns = 3;
    }
}

#pragma mark - Private methods

- (void)setupProfileView
{
    self.profileViewController = [[ProfileViewController alloc] init];
    [self addChildViewController:self.profileViewController];
    [self.profileViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.profileViewController.view];
    [self.profileViewController didMoveToParentViewController:self];

    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.profileViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.profileViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.profileViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.profileViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:280];

    [self.view addConstraints:@[topConstraint, leftConstraint, rightConstraint, heightConstraint]];
}

- (void)setupCollectionView
{
    self.collectionView.contentInset = UIEdgeInsetsMake(220.0f, 0.0f, 0.0f, 0.0f);
    [self.collectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    self.collectionView.backgroundColor = [UIColor colorWithRed:231/255.0f green:230/255.0f blue:226/255.0f alpha:1.0f];
}

- (void)loadTemplates
{
    [[Client instance] templates:^(NSArray *templates, NSError *error) {
        self.templates = templates;
        for (Template *template in templates) {
            // Optimistically load theme files
            [template.themeCover getDataInBackgroundWithBlock:nil];
            [template.themeLeft getDataInBackgroundWithBlock:nil];
            [template.themeRight getDataInBackgroundWithBlock:nil];
        }
    }];
}

- (void)loadAlbums
{
    if (self.isFirstLoad) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

    [[Client instance] albumsForUser:[PFUser currentUser] completion:^(NSArray *albums, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            self.albums = [albums mutableCopy];

            // Get the pictures for each album
            for (Album *album in albums) {
                [[Client instance] picturesForAlbum:album completion:^(NSArray *pictures, NSError *error) {
                    if (!error) {
                        [self.picturesForAlbums setObject:pictures forKey:album.objectId];
                        [self.collectionView reloadData];
                    } else {
                        NSLog(@"No cover picture for album %@", album);
                    }
                }];
            }
            
            Album *createNew = [Album object];
            createNew.title = @"Create New Album";
            [self.albums insertObject:createNew atIndex:0];

        } else {
            NSLog(@"Error %@", [error localizedDescription]);
        }
    }];
}

- (void)profileButtonHandler:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] init]];
    [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)newButtonHandler:(id)sender
{
    // Push templates view controller
    TemplateQuiltViewController *templatesVC = [[TemplateQuiltViewController alloc] init];
    templatesVC.templates = self.templates;
    [self.navigationController pushViewController:templatesVC animated:YES];
}

- (void)logoutButtonHandler:(id)sender
{
    // Logout user, this automatically clears the cache
    [PFUser logOut];

    // Return to login view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
