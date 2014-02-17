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
@property (nonatomic, strong) NSMutableDictionary *coverPictures;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOutHandler:) name:@"logout" object:nil];

    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStyleBordered target:self action:@selector(profileButtonHandler:)];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(newButtonHandler:)];
    self.navigationItem.rightBarButtonItem = newButton;

    [self.collectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    [self.collectionView registerClass:[AlbumTitleReusableView class] forSupplementaryViewOfKind:@"AlbumTitle"withReuseIdentifier:@"AlbumTitle"];

    // Load the data
    self.coverPictures = [[NSMutableDictionary alloc] init];
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
    albumCell.coverPictureImageView.file = ((Picture *)self.coverPictures[album.objectId]).image;
    [albumCell.coverPictureImageView loadInBackground];

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

- (void)loadAlbums
{
    [[Client instance] albumsForUser:[PFUser currentUser] completion:^(NSArray *albums, NSError *error) {
        if (!error) {
            NSLog(@"Albums: %@", albums);
            self.albums = [albums mutableCopy];
            // Get the cover picture for each album
            for (NSUInteger i = 0; i < albums.count; i++) {
                Album *album = albums[i];
                [[Client instance] coverPictureForAlbum:album completion:^(NSArray *pictures, NSError *error) {
                    if (!error) {
                        [self.coverPictures setObject:pictures[0] forKey:album.objectId];
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

- (void)loggedOutHandler:(id)sender
{
    // Dismiss to login view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
