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
#import "AlbumTitleReusableView.h"
#import "ProfileViewController.h"
#import "TemplatesViewController.h"
#import "AlbumViewController.h"
#import "Client.h"

@interface AlbumCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) NSMutableDictionary *picturesForAlbums;
@property (nonatomic, strong) ProfileViewController *profileViewController;

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

    // Start the display area from under the status bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Register for logout events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutButtonHandler:) name:@"logout" object:nil];

    // New album button
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(newButtonHandler:)];
    self.navigationItem.rightBarButtonItem = newButton;

    // Logout button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;

    // Initialize data
    self.picturesForAlbums = [[NSMutableDictionary alloc] init];

    [self setupProfileView];

    [self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        ((AlbumCollectionViewLayout *)self.collectionViewLayout).numColumns = 4;
    } else {
        ((AlbumCollectionViewLayout *)self.collectionViewLayout).numColumns = 3;
    }

    [self loadAlbums];
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
    AlbumCell *albumCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    Album *album = self.albums[indexPath.section];
    NSArray *pictures = self.picturesForAlbums[album.objectId];
    if (pictures && pictures.count != 0) {
        albumCell.coverPictureImageView.file = ((Picture *)pictures[0]).image;
        [albumCell.coverPictureImageView loadInBackground];
    }
    return albumCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
    AlbumTitleReusableView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"AlbumTitle" forIndexPath:indexPath];

    Album *album = self.albums[indexPath.section];
    titleView.titleLabel.text = album.title;

    return titleView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = self.albums[indexPath.section];
    NSLog(@"Selected album: %@", album);

    AlbumViewController *albumViewController = [[AlbumViewController alloc] init];
    albumViewController.album = album;
    albumViewController.picturesForAlbum = self.picturesForAlbums[album.objectId];
    [self.navigationController pushViewController:albumViewController animated:YES];
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
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.profileViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:300];

    [self.view addConstraints:@[topConstraint, leftConstraint, rightConstraint, heightConstraint]];
}

- (void)setupCollectionView
{
    self.collectionView.contentInset = UIEdgeInsetsMake(280.0f, 0.0f, 0.0f, 0.0f);
    [self.collectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    [self.collectionView registerClass:[AlbumTitleReusableView class] forSupplementaryViewOfKind:@"AlbumTitle"withReuseIdentifier:@"AlbumTitle"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)loadAlbums
{
    [[Client instance] albumsForUser:[PFUser currentUser] completion:^(NSArray *albums, NSError *error) {
        if (!error) {
            NSLog(@"Albums: %@", albums);
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
    [self.navigationController pushViewController:[[TemplatesViewController alloc] init] animated:YES];
}

- (void)logoutButtonHandler:(id)sender
{
    // Logout user, this automatically clears the cache
    [PFUser logOut];

    // Return to login view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
