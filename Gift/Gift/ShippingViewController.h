//
//  ShippingViewController.h
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import <UIKit/UIKit.h>
#import "STPView.h"
#import "Album.h"

@interface ShippingViewController : UIViewController <STPViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) Album *album;
@property (nonatomic, strong) NSString *albumFile;

@end
