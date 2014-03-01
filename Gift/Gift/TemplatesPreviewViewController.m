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

    self.leftView.layer.borderWidth = 1.0f;
    self.leftView.layer.borderColor = [UIColor blackColor].CGColor;
    self.leftView.layer.cornerRadius = 8;
    self.leftView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.leftView];
    //
    [self.leftView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.leftView.layer setShadowOpacity:0.8];
    [self.leftView.layer setShadowRadius:5.0];
    [self.leftView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    
    self.rightView = [[PFImageView alloc]initWithFrame:CGRectMake(self.leftView.frame.size.width+20, 100, self.view.frame.size.width/2 - 20, self.view.frame.size.height - 200)];
    
    self.rightView.layer.borderWidth = 1.0f;
    self.rightView.layer.borderColor = [UIColor blackColor].CGColor;
    self.rightView.layer.cornerRadius = 8;
    self.rightView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.rightView];
    //
    [self.rightView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.rightView.layer setShadowOpacity:0.8];
    [self.rightView.layer setShadowRadius:5.0];
    [self.rightView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    NSLog(@"");
    
    [self.leftView setFile:self.template.themeLeft];
    [self.leftView loadInBackground];
    [self.rightView setFile:self.template.themeRight];
    [self.rightView loadInBackground];
}
@end
