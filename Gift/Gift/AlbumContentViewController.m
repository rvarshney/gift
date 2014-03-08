//
//  AlbumContentViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/17/14.
//
//

#import "AlbumContentViewController.h"
#import "AlbumImageView.h"
#import "Picture.h"

@interface AlbumContentViewController ()

@property (nonatomic, strong) UIView *placementView;

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

    for (Picture *picture in self.pictures)
    {
        AlbumImageView *imageView = [[AlbumImageView alloc] initWithPicture:picture];
        [self.view addSubview:imageView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView *)getPlacementView
{
    NSDictionary *positionData = [self.album.template objectForKey:@"themeData"];
    NSNumber *templateWidth = [positionData objectForKey:@"w"];
    NSNumber *templateHeight = [positionData objectForKey:@"h"];
    NSArray *leftData = [positionData objectForKey:@"leftData"];
    NSArray *rightData = [positionData objectForKey:@"rightData"];

    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CGFloat widthRatio = viewWidth / [templateWidth floatValue];
    CGFloat heightRatio = viewHeight / [templateHeight floatValue];
    
    self.placementView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSArray *positionInfo;
    if (self.pageNum % 2 == 0) {
        positionInfo = leftData;
    } else {
        positionInfo = rightData;
    }
    
    for (NSDictionary *placement in positionInfo) {
        CGFloat x = [[placement objectForKey:@"x"] floatValue];
        CGFloat y = [[placement objectForKey:@"y"] floatValue];
        CGFloat w = [[placement objectForKey:@"w"] floatValue];
        CGFloat h = [[placement objectForKey:@"h"] floatValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x * widthRatio, y * heightRatio, w * widthRatio, h * heightRatio)];
        view.alpha = 1;
        //view.layer.borderColor = [UIColor greenColor].CGColor;
        //view.layer.borderWidth = 2.0f;
        
        CAShapeLayer *border = [CAShapeLayer layer];
        border.strokeColor = [UIColor whiteColor].CGColor;
        border.fillColor = nil;
        border.lineWidth = 2.0f;
        border.lineDashPattern = @[@8, @4];
        [view.layer addSublayer:border];
        border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
        border.frame = view.bounds;

        [self.placementView addSubview:view];
    }

    return self.placementView;
    //[self.view addSubview:self.placementView];
}

- (void)hidePlacementViews
{
    [self.placementView removeFromSuperview];
}

- (CGRect)placementRectForLocation:(CGPoint)location
{
    for (UIView *placementView in [self.placementView subviews]) {
        if (CGRectContainsPoint(placementView.frame, location)) {
            return placementView.frame;
        }
    }
    return CGRectZero;
}

@end
