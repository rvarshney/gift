//
//  TemplatesPreviewViewController.m
//  Gift
//
//  Created by Upkar Lidder on 2014-02-24.
//
//

#import "TemplatesPreviewViewController.h"
#import "AlbumViewController.h"
#import "Client.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface TemplatesPreviewViewController ()

@property(weak, nonatomic) IBOutlet PFImageView *leftView;
@property(weak, nonatomic) IBOutlet PFImageView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *description;

@end

@implementation TemplatesPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start the display area from under the status bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.description.text = self.template.details;

    self.leftView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.leftView.layer.shadowRadius = 3.0f;
    self.leftView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.leftView.layer.shadowOpacity = 0.5f;
    self.leftView.backgroundColor = [UIColor whiteColor];
    self.leftView.file = self.template.themeLeft;
    [self.leftView loadInBackground];
    
    [self.view addSubview:self.leftView];

    self.rightView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.rightView.layer.shadowRadius = 3.0f;
    self.rightView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.rightView.layer.shadowOpacity = 0.5f;
    self.rightView.backgroundColor = [UIColor whiteColor];
    self.rightView.file = self.template.themeRight;
    [self.rightView loadInBackground];
    
    [self.view addSubview:self.rightView];
}
@end
