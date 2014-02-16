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



@interface TemplatesViewController (){
    NSArray *imagesArray;
}

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
    imagesArray = [[NSArray alloc]initWithObjects:@"hearts.png", @"happybirthday.jpg", @"birthday.png", @"winter.png", @"graduation.png", @"baby.png", nil];
    [super viewDidLoad];
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
    
    [cell.templateImage setImage:[UIImage imageNamed:imagesArray[indexPath.row]]];
    
    //set the tag of the image so that we know which template was clicked. Can also add other properties here. Change UICollectionViewCell+Tag
    [cell.contentView setTag:indexPath.row];

    //only add if cell does not already have a uitaprecognizer as cells are recycled
    bool alreadyContainsUITapGesureRecognizer = false;
    NSArray *gestureRecognizers = cell.contentView.gestureRecognizers;
    for(UIGestureRecognizer *recog in gestureRecognizers){
        if([recog isMemberOfClass:[UITapGestureRecognizer class]]){
            alreadyContainsUITapGesureRecognizer = true;
            break;
        }
    }
    
    if(!alreadyContainsUITapGesureRecognizer){
        [cell.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelect:)]];
    }
    return cell;
}

-(void)handleSelect:(UITapGestureRecognizer*) tapGestureRecog{
    NSLog(@"%s", object_getClassName([[tapGestureRecog view] class]));
    NSLog(@"%d clicked", [tapGestureRecog view].tag);
    [self.navigationController pushViewController:[[AlbumViewController alloc] init] animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [imagesArray count];
}
@end
