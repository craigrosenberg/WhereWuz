//
//  SocialViewController.m
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//


#import "SocialViewController.h"
#import "SocialManager.h"
#import "Analytics.h"

/////////////////FaceBook App Credentials/////////////////////////
static NSString* kApiKey    = @"b536495bf114a39e0a73093ec0ef718c";
static NSString* kApiSecret = @"a4ec72b7ff03c35c2ff084838a433e6e";
////////////////FaceBook App Credentials/////////////////////////

@implementation SocialViewController

@synthesize session = _session, connectedFaceBookUserName = _connectedFaceBookUserName, hasFaceBookPermessionToPublishFeed = _hasFaceBookPermessionToPublishFeed;

- (id)init
{
	if (self = [super initWithNibName:@"SocialViewController" bundle:nil])
	{
		_facebookLoginButton.style = FBLoginButtonStyleNormal;
		_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
		self.title = @"Sharing";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"tweet.png"];		
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:@"SocialViewController" bundle:nil])
	{
		_facebookLoginButton.style = FBLoginButtonStyleNormal;
		_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
		self.title = @"Sharing";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"tweet.png"];
	}
	return self;
}

- (void) loadView
{
	[super loadView];
	
	UIImageView* headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
	self.navigationItem.titleView = headerImage;
	[headerImage release];
		
	[_session resume];	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	//[Analytics sendAnalyticsTag:@"FaceBookTwitterViewLoaded" metadata:nil blocking:NO];
}

- (IBAction) showLogin
{
	if(_twitterLoginView.hidden)
	{	
		if(!_twitterUsername.text || ![_twitterUsername.text length])
		{
			_twitterUsername.text = [MGTwitterEngine username];
		}
		
		if(!_twitterUsername.text || ![_twitterUsername.text length])
		{
			[_twitterUsername becomeFirstResponder];
		}
		else 
		{
			[_twitterPassword becomeFirstResponder];
		}

		_twitterLoginView.hidden = NO;
		
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin_sharp.png"] forState:UIControlStateNormal];
	}
	else 
	{
		[_twitterUsername resignFirstResponder];
		[_twitterPassword resignFirstResponder];
		_twitterLoginView.hidden = YES;
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin.png"] forState:UIControlStateNormal];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin_highlighted.png"] forState:UIControlStateHighlighted];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)_string
{
	if([_string isEqualToString:@" "])
	{
		return NO;
	}
	
	//NSLog(@"Range Location: %d Length: %d and string: %@ actual string: %@",range.location,range.length,_string,textField.text);
	
	if(textField == _twitterUsername)
	{
		NSString* trimmedPassword = [_twitterPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(trimmedPassword && [trimmedPassword length] >= 6)
		{
			if([_string length] || [textField.text length] > 1)
			{
				_twitterLoginSubmit.enabled = YES;
			}
			else 
			{
				_twitterLoginSubmit.enabled = NO;
			}
		}
		else 
		{
			_twitterLoginSubmit.enabled = NO;
		}
	}
	else
	{
		NSString* trimmedUsername = [_twitterUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(trimmedUsername && [trimmedUsername length] > 0)
		{
			if(([_string length] && [textField.text length] >= 5) || [textField.text length] > 6)
			{
				_twitterLoginSubmit.enabled = YES;
			}
			else 
			{
				_twitterLoginSubmit.enabled = NO;
			}
		}
		else 
		{
			_twitterLoginSubmit.enabled = NO;
		}
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField == _twitterUsername)
	{
		NSString* trimmedUsername = [_twitterUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(trimmedUsername && [trimmedUsername length] > 0)
		{
			[_twitterPassword becomeFirstResponder];
		}
	}
	else 
	{
		NSString* trimmedUsername = [_twitterUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString* trimmedPassword = [_twitterPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if((trimmedUsername && [trimmedUsername length] > 0) && (trimmedPassword && [trimmedPassword length] >= 6))
		{
			[self doLogin];
			[_twitterPassword resignFirstResponder];
//			[self updateTwitterShare];
		}
	}
	return YES;
}

//static SocialViewController* socialViewController;
//static MGTwitterEngine*	sharedTwitterEngine;

- (IBAction) doLogin
{
	[_twitterUsername resignFirstResponder];
	[_twitterPassword resignFirstResponder];
	[_twitterLoginAnimating startAnimating];
	
	NSString* trimmedUsername = [_twitterUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* trimmedPassword = [_twitterPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if((trimmedUsername && [trimmedUsername length] > 0) && (trimmedPassword && [trimmedPassword length] >= 6))
	{
		_twitterLoginSubmit.enabled = NO;
		[MGTwitterEngine setUsername:trimmedUsername password:trimmedPassword remember:_twitterRememberCredentials.on];
		//[Analytics sendAnalyticsTag:@"TwitterLogin" metadata:nil blocking:NO];
//		sharedTwitterEngine = [[MGTwitterEngine alloc] initWithDelegate:socialViewController];
//		[sharedTwitterEngine checkUserCredentials];
//Rob		[[SocialManager getSharedTwitterEngine] checkUserCredentials];
//		NSLog(@"%@",sharedTwitterEngine);
	}
}

- (IBAction) doLogOut
{
	_twitterLoginButton.selected = YES;
	_shareTwitter.hidden = YES;
	[_twitterLoginAnimating startAnimating];
	_isLogingOut = YES;
//Rob	[[SocialManager getSharedTwitterEngine]  endUserSession];
}

- (IBAction) shareAppthroughTwitter:(UIButton*)shareTwitterButton
{
	CALayer* layer = [_twitterShareDialogRounderView layer];
	[layer setMasksToBounds:YES];
	[layer setCornerRadius:8.0];
	[layer setBorderWidth:2.0];
	[layer setBorderColor:[[UIColor grayColor] CGColor]];
	
	_twitterShareDialogTextView.font = [UIFont boldSystemFontOfSize:16];
	
	[self.view addSubview:_twitterShareDialogView];
}

- (IBAction) updateTwitterShare
{
	//[Analytics sendAnalyticsTag:@"TwitterUpdated" metadata:nil blocking:NO];
	[[SocialManager getSharedTwitterEngine] sendUpdate:@"WhereWuz: Know Where You Were, at Any Time. http://bit.ly/wherewuz"];
	[_twitterShareDialogView removeFromSuperview];
}

- (IBAction) cancelTwitterShare
{
	[_twitterShareDialogView removeFromSuperview];
}

#pragma mark MGTwitterEngineDelegate

// These delegate methods are called after a connection has been established
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	if(!_isLogingOut)
	{
		//[Analytics sendAnalyticsTag:@"TwitterLoggedIn" metadata:nil blocking:NO];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signout.png"] forState:UIControlStateNormal];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signout_highlighted.png"] forState:UIControlStateHighlighted];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signout_highlighted.png"] forState:UIControlStateSelected];
		[_twitterLoginButton removeTarget:self action:@selector(showLogin) forControlEvents:UIControlEventTouchUpInside];
		[_twitterLoginButton addTarget:self    action:@selector(doLogOut) forControlEvents:UIControlEventTouchUpInside];
		
		[_twitterLoginAnimating stopAnimating];
		_twitterPassword.text = nil;
		_shareTwitter.hidden = NO;
		_twitterLoginView.hidden = YES;
		
		[SocialManager setTwitterLogedIn:YES];
		_publishTwitter.on = [SocialManager getPublishFavoritesToTwitter];
		_publishTwitter.enabled = YES;
		
		[SocialManager PublishTwitterQueue];
		
		if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"logedIntoTwitterBefore"] boolValue])
		{
			//[Analytics sendAnalyticsTag:@"FirstTwitterPost" metadata:nil blocking:NO];
			[[SocialManager getSharedTwitterEngine] sendUpdate:@"is checking out WhereWuz. http://bit.ly/wherewuz"];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logedIntoTwitterBefore"];
		}
	}
	else 
	{
		_twitterLoginButton.selected = NO;
		[_twitterLoginAnimating stopAnimating];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin.png"] forState:UIControlStateNormal];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin_highlighted.png"] forState:UIControlStateHighlighted];
		[_twitterLoginButton removeTarget:self action:@selector(doLogOut) forControlEvents:UIControlEventTouchUpInside];
		[_twitterLoginButton addTarget:self	   action:@selector(showLogin) forControlEvents:UIControlEventTouchUpInside];
		
		_publishTwitter.enabled = NO;
		_publishTwitter.on = NO;
		_isLogingOut = NO;
		[SocialManager setTwitterLogedIn:NO];
		
		_twitterLoginTitle.backgroundColor = [UIColor clearColor];
		_twitterLoginTitle.textColor       = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
		
		CALayer * layer = [_twitterLoginTitle layer];
		[layer setBorderColor:[[UIColor clearColor] CGColor]];
		[layer setMasksToBounds:YES];
		[layer setCornerRadius:5.0];
		[layer setBorderWidth:1.0];
		
		_twitterLoginTitle.text   = @"Sign in to Twitter";
	}
}
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Error (%d) : %@",error.code,error.description);
	if([_twitterLoginAnimating isAnimating]&&!_isLogingOut)
	{
		_twitterLoginTitle.backgroundColor = [UIColor colorWithRed:0.75 green:0.63 blue:0.63 alpha:1.0];
		_twitterLoginTitle.textColor       = [UIColor colorWithRed:0.19 green:0.06 blue:0.06 alpha:1.0];
		
		CALayer * layer = [_twitterLoginTitle layer];
		[layer setBorderColor:[[UIColor grayColor] CGColor]];
		[layer setMasksToBounds:YES];
		[layer setCornerRadius:5.0];
		[layer setBorderWidth:1.0];
		
		_twitterLoginTitle.text   = @"Invalid Username or password";
		_twitterPassword.text = nil;
		[_twitterLoginAnimating stopAnimating];
		[_twitterUsername becomeFirstResponder];
	}
	else 
	{
		_twitterLoginButton.selected = NO;
		[_twitterLoginAnimating stopAnimating];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin.png"] forState:UIControlStateNormal];
		[_twitterLoginButton setImage:[UIImage imageNamed:@"twitter_signin_highlighted.png"] forState:UIControlStateHighlighted];
		[_twitterLoginButton removeTarget:self action:@selector(doLogOut) forControlEvents:UIControlEventTouchUpInside];
		[_twitterLoginButton addTarget:self	   action:@selector(showLogin) forControlEvents:UIControlEventTouchUpInside];
		
		_publishTwitter.enabled = NO;
		_publishTwitter.on = NO;
		_isLogingOut = NO;
		[SocialManager setTwitterLogedIn:NO];
		
		_twitterLoginTitle.backgroundColor = [UIColor clearColor];
		_twitterLoginTitle.textColor       = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
		
		CALayer * layer = [_twitterLoginTitle layer];
		[layer setBorderColor:[[UIColor clearColor] CGColor]];
		[layer setMasksToBounds:YES];
		[layer setCornerRadius:5.0];
		[layer setBorderWidth:1.0];
		
		_twitterLoginTitle.text   = @"Sign in to Twitter";
	}

}

/*
#if YAJL_AVAILABLE
// This delegate method is called each time a new result is parsed from the connection and
// the deliveryOption is configured for MGTwitterEngineDeliveryIndividualResults.
- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier;
#endif

// These delegate methods are called after all results are parsed from the connection. If 
// the deliveryOption is configured for MGTwitterEngineDeliveryAllResults (the default), a
// collection of all results is also returned.
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier;
- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier;
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier;
#if YAJL_AVAILABLE
- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier;
#endif

#if TARGET_OS_IPHONE
- (void)imageReceived:(UIImage *)image forRequest:(NSString *)connectionIdentifier;
#else
- (void)imageReceived:(NSImage *)image forRequest:(NSString *)connectionIdentifier;
#endif
 */

// This delegate method is called whenever a connection has finished.
- (void)connectionFinished
{
	NSLog(@"Connection Finished");
}

- (void) getPermissionToPublishStream
{
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.permission = @"publish_stream"; //publish_stream&offline_access
	dialog.delegate = self;
	[dialog show];
}

- (IBAction) shareAppthroughFaceBook:(UIButton*)shareFaceBookButton
{
	 FBStreamDialog* dialog = [[[FBStreamDialog alloc] init] autorelease];
	 dialog.delegate = self;
	 dialog.userMessagePrompt = @"Sharing WhereWuz Application";
	 dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"WhereWuz iPhone Application\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"Real-time and historical information on your location.\",\"description\":\"Turn your iPhone into a powerful tool for viewing real-time and historical data related to where you've been. Get WhereWuz.\",\"media\":[{\"type\":\"image\",\"src\":\"http://184.72.254.21/images/icon.png\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"iTunes Url\":{\"text\":\"Other WhereWuz iPhone Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}}}", _connectedFaceBookUserName ];
	 dialog.actionLinks = @"[{\"text\":\"Get WhereWuz\",\"href\":\"ttp://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"},{\"text\":\"Visit the site\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}]";
	 [dialog show];
}

- (void) publishFavorite
{
	//[Analytics sendAnalyticsTag:@"FaceBookPost" metadata:nil blocking:NO];
	NSString *message = @"test message here";
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:message forKey:@"message"];
	NSString *attachment = @"{\"name\":\"WhereWuz iPhone Application\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"Real-time and historical information on your location.\",\"description\":\"Turn your iPhone into a powerful tool for viewing real-time and historical data related to where you've been. Get WhereWuz.\",\"media\":[{\"type\":\"image\",\"src\":\"http://184.72.254.21/images/icon.png\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"iTunes Url\":{\"text\":\"Other WhereWuz iPhone Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}}}";
	[params setObject:attachment forKey:@"attachment"];
	NSString *action_links = @"[{\"text\":\"Get WhereWuz\",\"href\":\"ttp://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"},{\"text\":\"Visit the site\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}]";
	[params setObject:action_links forKey:@"action_links"];
	// [params setObject:toID forKey:@"target_id"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.Stream.publish" params:params];
}

- (void) publishFavorites:(UISwitch*)publishSwitch
{
	if(publishSwitch == _publishTwitter)
	{
		if(_publishTwitter.enabled)
		{
			[SocialManager setPublishFavoritesToTwitter:publishSwitch.on];
		}
	}
	else 
	{
		if(_hasFaceBookPermessionToPublishFeed)
		{
			[SocialManager setPublishFavoritesToFaceBook:publishSwitch.on];
		}
		else 
		{
			publishSwitch.on = NO;
		}
	}
}

#pragma mark FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid 
{
	NSString* fql = [NSString stringWithFormat:@"{\"permission\":\"select publish_stream from permissions where uid == %lld\",\"name\":\"select name from user where uid == %lld\"}", session.uid,session.uid]; 
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"queries"]; 
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.multiquery" params:params];
	
	_shareFacebook.hidden = NO;
	_faceBookUserName.text = @"Connecting";
}

- (void)sessionDidNotLogin:(FBSession*)session
{
	_faceBookUserName.text = @"Canceled Login";
}

- (void)sessionDidLogout:(FBSession*)session
{
	[_connectedFaceBookUserName release];_connectedFaceBookUserName = nil;
	_faceBookUserName.text = @"Disconnected";
	_shareFacebook.hidden = YES;
	
	_hasFaceBookPermessionToPublishFeed = NO;
	_publishFacebook.enabled	= NO;
	_publishFacebook.on			= NO;
	[SocialManager setPublishFavoritesToFaceBook:YES];
}

#pragma mark FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result
{
	if ([request.method isEqualToString:@"facebook.fql.multiquery"])
	{
		NSArray* NameAndPermissions = result;
		
		NSDictionary* Name = [NameAndPermissions objectAtIndex:0];
		_connectedFaceBookUserName = [[[[Name objectForKey:@"fql_result_set"] objectAtIndex:0] objectForKey:@"name"] retain];
		_faceBookUserName.text = _connectedFaceBookUserName;
		
		NSDictionary* permissions = [NameAndPermissions objectAtIndex:1];
		_hasFaceBookPermessionToPublishFeed = [[[[[permissions objectForKey:@"fql_result_set"] objectAtIndex:0] objectAtIndex:0]  objectForKey:@"fql_result_set_elt_elt"] boolValue];
		_publishFacebook.enabled = YES;
		
		if(_hasFaceBookPermessionToPublishFeed)
		{
			_publishFacebook.on = [SocialManager getPublishFavoritesToFaceBook];
			[_publishFacebook addTarget:self action:@selector(publishFavorites:) forControlEvents:UIControlEventValueChanged];
			
			[SocialManager PublishFaceBookQueue];
			
			if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"logedIntoFaceBookBefore"] boolValue])
			{

				//[Analytics sendAnalyticsTag:@"FirstPostFacebook" metadata:nil blocking:NO];
				NSMutableDictionary* params = [NSMutableDictionary dictionary];
				NSString* attachment = [NSString stringWithFormat:@"{\"name\":\"WhereWuz iPhone Application\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"Real-time and historical information on your location.\",\"description\":\"Turn your iPhone into a powerful tool for viewing real-time and historical data related to where you've been. Get WhereWuz.\",\"media\":[{\"type\":\"image\",\"src\":\"http://184.72.254.21/images/icon.png\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"iTunes Url\":{\"text\":\"Other WhereWuz iPhone Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}}}", _connectedFaceBookUserName ];
				[params setObject:attachment forKey:@"attachment"];
				[[FBRequest requestWithDelegate:self] call:@"facebook.Stream.publish" params:params];
				
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logedIntoFaceBookBefore"];
			}

		}
		else 
		{
			[_publishFacebook addTarget:self action:@selector(publishFavorites:) forControlEvents:UIControlEventValueChanged];
			[_publishFacebook addTarget:self action:@selector(getPermissionToPublishStream) forControlEvents:UIControlEventTouchUpInside];
		}
	} 
	else if ([request.method isEqualToString:@"facebook.Stream.publish"])
	{
		NSLog(@"Result is: %@",result);
		NSLog(@"Feed Successfully Published"); 
	} 
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	NSLog(@"Error (%d) : %@",error.code,error.localizedDescription);
	if(error.code == 102)
	{
		[_session logout];
	}
}

#pragma mark FBDialogDelegate

- (void)dialogDidSucceed:(FBDialog*)dialog
{
	if([@"Extended Permission" isEqualToString:dialog.title])
	{
		_hasFaceBookPermessionToPublishFeed = YES;
		_publishFacebook.on = YES;
		[_publishFacebook removeTarget:self action:@selector(getPermissionToPublishStream) forControlEvents:UIControlEventTouchUpInside];
		
		[SocialManager PublishFaceBookQueue];

/*		
		if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"logedIntoFaceBookBefore"] boolValue])
		{
*/
			//[Analytics sendAnalyticsTag:@"FacebookLoginPost" metadata:nil blocking:NO];
			NSMutableDictionary* params = [NSMutableDictionary dictionary];
			NSString* attachment =   [NSString stringWithFormat:@"{\"name\":\"WhereWuz iPhone Application\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"Real-time and historical information on your location.\",\"description\":\"Turn your iPhone into a powerful tool for viewing real-time and historical data related to where you've been. Get WhereWuz.\",\"media\":[{\"type\":\"image\",\"src\":\"http://184.72.254.21/images/icon.png\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"iTunes Url\":{\"text\":\"Other WhereWuz iPhone Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}}}", _connectedFaceBookUserName ];
			NSString* actionLinks = @"[{\"text\":\"Get WhereWuz\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"},{\"text\":\"Other WhereWuz iPhone Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}]";
			
			[params setObject:attachment forKey:@"attachment"];
			[params setObject:actionLinks forKey:@"actionLinks"];
			[[FBRequest requestWithDelegate:self] call:@"facebook.Stream.publish" params:params];
			
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logedIntoFaceBookBefore"];
/*
	}
*/
	}
}

- (void)dialogDidCancel:(FBDialog*)dialog
{
	NSLog(@"Dialog Title: %@",dialog.title);
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error
{
	NSLog(@"Error(%d) : %@",error.code,error.localizedDescription);
}

- (void)dealloc
{
	[_twitterLoginButton release];
	[_twitterLoginView release];
	[_twitterLoginTitle release];
	[_twitterUsername release];
	[_twitterPassword release];
	[_twitterRememberCredentials release];
	[_twitterLoginSubmit release];
	[_twitterLoginAnimating release];
	
	[_shareTwitter release];
	[_publishTwitter release];
	
	[_faceBookUserName release];
	
	[_shareFacebook release];
	[_publishFacebook release];
	
	
	[_session release];
	[_connectedFaceBookUserName release];
	
	[_twitterShareDialogView release];
	[_twitterShareDialogRounderView release];
	[_twitterShareDialogTextView release];
	
    [super dealloc];
}


@end
