//
//  TemplatesViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import "TemplatesViewController.h"
#import "AlbumViewController.h"
#import "TemplateCell.h"
#import "Client.h"
#import "Album.h"
#import <Parse/Parse.h>



@interface TemplatesViewController ()
@property (nonatomic, strong)NSArray *templates;
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
    
    [[Client instance] templates:^(NSArray *templates, NSError *error) {
        self.templates = templates;
        [self.collectionView reloadData];
    }];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TemplateCell" bundle:nil] forCellWithReuseIdentifier:@"TemplateCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.title = @"Templates";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    
    cell.templateImage.file = ((Template*)self.templates[indexPath.row]).themeCover;
    [cell.templateImage loadInBackground];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    AlbumViewController *albumVC = [[AlbumViewController alloc]init];
    
    Album *album = [[Client instance] createAlbumWithTitle:@"Untitled Album" user:[PFUser currentUser] numPages:1 template:self.templates[indexPath.row] completion:^(BOOL succeeded, NSError *error) {
    }];
    
    albumVC.album = album;
    albumVC.picturesForAlbum = [[NSMutableArray alloc]init];
    [self.navigationController pushViewController:albumVC animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.templates count];
}
@end
