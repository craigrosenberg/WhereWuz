    //
//  ComposeEmailViewController.m
//  LifePath
//
//  Created by Justin on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeEmailViewController.h"


@implementation ComposeEmailViewController

@synthesize recipients, subject, body, bodyIsHTML;

- (id)init
{
	if(self = [super init])
	{
		attachments = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addAttachment:(NSData*)data mimeType:(NSString*)type filename:(NSString*)filename
{
	[attachments addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							data, @"data",
							type, @"mimeType",
							filename, @"filename", nil]];
}

- (void)viewWillAppear:(BOOL)animated
{
	if([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController* composer = [[MFMailComposeViewController alloc] init];
		composer.mailComposeDelegate = self;
		
		[composer setToRecipients:recipients];
		[composer setSubject:subject];
		[composer setMessageBody:body isHTML:bodyIsHTML];

		for(NSDictionary* attachment in attachments)
			[composer addAttachmentData:[attachment objectForKey:@"data"]
							   mimeType:[attachment objectForKey:@"mimeType"]
							   fileName:[attachment objectForKey:@"filename"]];
		
		[self presentModalViewController:composer animated:YES];
		[composer release];		
	}
	else
	{
		NSString* email = [NSString stringWithFormat:@"mailto:?body=%@", body];
		email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
	}
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	NSString* message = nil;
	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			[self dismissModalViewControllerAnimated:YES];
			[self.navigationController popViewControllerAnimated:YES];
			break;
			
		case MFMailComposeResultSaved:
			message = @"Your email was saved.";
			break;
			
		case MFMailComposeResultSent:
			message = @"Your email was sent.";
			break;
			
		case MFMailComposeResultFailed:
			message = @"Your email could not be sent.\nPlease try again later.";
			break;
	}
	
	if(message)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil 
														message:message
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc
{
	self.recipients = nil;
	self.subject = nil;
	self.body = nil;
    [super dealloc];
}


@end
