//
//  TemplateQuiltViewController
//
//  Created by Ruchi Varshney on 3/08/14.
//
//

#import "Template.h"
#import "Client.h"
#import "TemplateQuiltViewController.h"
#import "TMQuiltView.h"
#import "TemplatePreviewViewController.h"
#import "TemplateQuiltViewCell.h"
#import "Album.h"
#import "AlbumViewController.h"

@interface TemplateQuiltViewController ()

@property (nonatomic, strong) Template *currentTemplate;

@end

@implementation TemplateQuiltViewController

@synthesize templates = _templates;

- (void)dealloc
{
    [_templates release], _templates = nil;
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Select Template";
    
    self.quiltView.backgroundColor = [UIColor colorWithRed:231/255.0f green:230/255.0f blue:226/255.0f alpha:1.0f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView
{
    return self.templates.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TemplateQuiltViewCell *cell = (TemplateQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[[TemplateQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"] autorelease];
    }
    
    Template *template = self.templates[indexPath.row];
    cell.photoView.file = template.themeCover;
    [cell.photoView loadInBackground];

    cell.titleLabel.text = template.title;

    return cell;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentTemplate = self.templates[indexPath.row];
    
    // Show preview
    TemplatePreviewViewController *previewViewController = [[TemplatePreviewViewController alloc]init];
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

- (void)createAlbum:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    Album *album = [[Client instance] createAlbumForUser:[PFUser currentUser] title:@"Untitled Album" template:self.currentTemplate completion:nil];
    
    AlbumViewController *albumViewController = [[AlbumViewController alloc]init];
    albumViewController.album = album;
    albumViewController.picturesForAlbum = [[NSMutableArray alloc]init];
    
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (void)cancelPreview:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 4;
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        return 300;
    }
    return 400;
}

@end
