//
//  EmailHelper.h
//  Gift
//
//  Created by Upkar Lidder on 2014-02-09.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface EmailHelper : NSObject

+ (BOOL)sendEmailWithNavigationController:(UINavigationController*)nvc subject:(NSString*)subject to:(NSArray*)toArray cc:(NSArray*)ccArray bcc:(NSArray*)bccArray body:(NSString*)body isHTML:(BOOL)isHTML delegate:(id<MFMailComposeViewControllerDelegate>)delegate files:(NSArray*)filesArray error:(NSError**)error;

+ (NSString*)MimeTypeWithExtension:(NSString*)extension;

@end