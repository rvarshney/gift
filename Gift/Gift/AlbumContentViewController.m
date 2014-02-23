//
//  AlbumContentViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/17/14.
//
//

#import "AlbumContentViewController.h"
#import "DraggableImageView.h"
#import "Picture.h"

@interface AlbumContentViewController ()

@end

@implementation AlbumContentViewController

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.album.template.themeLeft getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIGraphicsBeginImageContext(self.view.frame.size);
            [[UIImage imageWithData:data] drawInRect:self.view.bounds];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.view.backgroundColor = [UIColor colorWithPatternImage:image];
        }
    }];
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 3.0f;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.5f;

    self.labelText.text = [NSString stringWithFormat:@"%d", self.pageNum];
    for (Picture *picture in self.pictures)
    {
        DraggableImageView *imageView = [[DraggableImageView alloc] initWithPicture:picture];
        [self.view addSubview:imageView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
