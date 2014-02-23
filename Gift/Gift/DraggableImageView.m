//
//  DraggableImageView.m
//  Gift
//
//  Created by Ruchi Varshney on 2/18/14.
//
//

#import "DraggableImageView.h"

@interface DraggableImageView()

@property (nonatomic, strong) Picture *picture;
@property (nonatomic) CGPoint startLocation;

@end

@implementation DraggableImageView

- (id)initWithPicture:(Picture *)picture
{
    self = [super init];
    if (self) {
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        [self addGestureRecognizer:longPressGestureRecognizer];

        self.userInteractionEnabled = YES;

        self.picture = picture;
        self.file = picture.image;
        [self loadInBackground];

        self.bounds = CGRectMake(0, 0, [picture.width floatValue], [picture.height floatValue]);
        self.frame = CGRectMake([picture.x floatValue], [picture.y floatValue], [picture.width floatValue], [picture.height floatValue]);
    }
    return self;
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:self];
        self.startLocation = location;
        [self.superview bringSubviewToFront:self];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gesture locationInView:self];
        CGRect frame = [self frame];
        frame.origin.x += location.x - self.startLocation.x;
        frame.origin.y += location.y - self.startLocation.y;
        [self setFrame:frame];
        self.picture.x = [NSNumber numberWithFloat: frame.origin.x];
        self.picture.y = [NSNumber numberWithFloat: frame.origin.y];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.picture saveInBackground];
    }
}

@end
