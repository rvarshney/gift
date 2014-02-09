//
//  EmailViewController.h
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface EmailViewController : UIViewController<UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sendEmailButton;
- (IBAction)sendEmail:(id)sender;

@end
