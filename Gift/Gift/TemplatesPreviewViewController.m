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
    @property(strong, nonatomic) PFImageView *leftView;
    @property(strong, nonatomic) PFImageView *rightView;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.leftView = [[PFImageView alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width/2 - 20, self.view.frame.size.height - 200)];

    self.leftView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.leftView.layer.shadowRadius = 3.0f;
    self.leftView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.leftView.layer.shadowOpacity = 0.5f;
    
    [self.view addSubview:self.leftView];

    self.rightView = [[PFImageView alloc]initWithFrame:CGRectMake(self.leftView.frame.size.width+20, 100, self.view.frame.size.width/2 - 20, self.view.frame.size.height - 200)];

    self.rightView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.rightView.layer.shadowRadius = 3.0f;
    self.rightView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.rightView.layer.shadowOpacity = 0.5f;
    
    [self.view addSubview:self.rightView];
    
    [self.leftView setFile:self.template.themeLeft];
    [self.leftView loadInBackground];
    [self.rightView setFile:self.template.themeRight];
    [self.rightView loadInBackground];
}
@end
