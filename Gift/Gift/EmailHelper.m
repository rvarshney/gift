//
//  EmailHelper.m
//  Gift
//
//  Created by Upkar Lidder on 2014-02-08.
//
//

#import "EmailHelper.h"

@implementation EmailHelper

+ (BOOL)sendEmailWithNavigationController:(UINavigationController*)nvc subject:(NSString*)subject to:(NSArray*)toArray cc:(NSArray*)ccArray bcc:(NSArray*)bccArray body:(NSString*)body isHTML:(BOOL)isHTML delegate:(id<MFMailComposeViewControllerDelegate>)delegate files:(NSArray*)filesArray error:(NSError**)error {
    
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc]init];
        mailComposeVC.mailComposeDelegate = delegate;
        [mailComposeVC setSubject:subject];
        [mailComposeVC setMessageBody:body isHTML:isHTML];
        [mailComposeVC setToRecipients:toArray];
        
        for(NSString *file in filesArray){
            // Determine the file name and extension
            NSArray *filepart = [file componentsSeparatedByString:@"."];
            NSString *filename = [filepart objectAtIndex:0];
            NSString *extension = [filepart objectAtIndex:1];
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            NSString *mimeType = [EmailHelper MimeTypeWithExtension:extension];
            
            // Add attachment
            [mailComposeVC addAttachmentData:fileData mimeType:mimeType fileName:filename];
        }
        [nvc presentViewController:mailComposeVC animated:YES completion:Nil];
        return TRUE;
    }
    else{
        *error = [NSError errorWithDomain:@"Device not setup to send emails" code:200 userInfo:nil];
        return FALSE;
    }
}

+ (NSString*)MimeTypeWithExtension:(NSString*)extension{
    NSString *mimeType;
    if ([extension isEqualToString:@"jpg"]) {
        mimeType = @"image/jpeg";
    } else if ([extension isEqualToString:@"png"]) {
        mimeType = @"image/png";
    } else if ([extension isEqualToString:@"doc"]) {
        mimeType = @"application/msword";
    } else if ([extension isEqualToString:@"ppt"]) {
        mimeType = @"application/vnd.ms-powerpoint";
    } else if ([extension isEqualToString:@"html"]) {
        mimeType = @"text/html";
    } else if ([extension isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    }
    return mimeType;
}

@end
