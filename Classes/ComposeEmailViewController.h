//
//  ComposeEmailViewController.h
//  LifePath
//
//  Created by Justin on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ComposeEmailViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
	NSArray*						recipients;
	NSString*						subject;
	NSString*						body;
	BOOL							bodyIsHTML;
	
	NSMutableArray*					attachments;
}

@property (nonatomic, retain) NSArray* recipients;
@property (nonatomic, retain) NSString* subject;
@property (nonatomic, retain) NSString* body;
@property (nonatomic) BOOL bodyIsHTML;

- (void)addAttachment:(NSData*)data mimeType:(NSString*)type filename:(NSString*)filename;

@end
