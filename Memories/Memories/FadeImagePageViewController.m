//
//  FadeImagePageViewController.m
//  Memories
//
//  Created by Ruchi Varshney on 3/8/14.
//
//

#import "FadeImagePageViewController.h"

@interface FadeImagePageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation FadeImagePageViewController

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
    
    self.firstImageView.image = [self.images objectAtIndex:0];
    self.secondImageView.image = [self.images objectAtIndex:1];
    self.firstImageView.alpha = 1.0f;
    self.secondImageView.alpha = 0.0f;

    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;

    self.pageControl.numberOfPages = self.images.count;
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews
{
    CGRect tempFrame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    tempFrame.origin.x = 0;
    
    for (NSInteger i = 0; i < self.images.count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:tempFrame];
        tempFrame.origin.x = tempFrame.origin.x + tempFrame.size.width;
        UILabel *label = [[UILabel alloc] init];
        label.text = [self.messages objectAtIndex:i];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Avenir" size:20.0f];
        label.frame = CGRectMake(0, self.scrollView.frame.size.height - 260, self.scrollView.frame.size.width, 50);
        [view addSubview:label];
        [self.scrollView addSubview:view];
    }
    self.scrollView.contentSize = CGSizeMake(tempFrame.origin.x, tempFrame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat offset = self.scrollView.contentOffset.x;
    
    NSInteger page = floor(offset / width);
    CGFloat percent = (offset - page * width) / width;
    
    if (page < 0) {
        self.firstImageView.image = nil;
    } else {
        self.firstImageView.image = [self.images objectAtIndex:page];
    }
    
    if (page + 1 > self.images.count - 1) {
        self.secondImageView.image = nil;
    } else {
        self.secondImageView.image = [self.images objectAtIndex:page + 1];
    }

    self.firstImageView.alpha = 1 - percent;
    self.secondImageView.alpha = percent;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / self.scrollView.frame.size.width;
}

@end
