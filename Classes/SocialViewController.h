//
//  SocialViewController.h
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FBConnect/FBConnect.h"

@interface SocialViewController : UIViewController <UITextFieldDelegate,FBSessionDelegate, FBDialogDelegate, FBRequestDelegate>
{
	IBOutlet UIButton*	    _twitterLoginButton;
	IBOutlet UIView*		_twitterLoginView;
	IBOutlet UILabel*		_twitterLoginTitle;
	IBOutlet UITextField*   _twitterUsername;
	IBOutlet UITextField*   _twitterPassword;
	IBOutlet UISwitch*		_twitterRememberCredentials;
	IBOutlet UIButton*		_twitterLoginSubmit;
	IBOutlet UIActivityIndicatorView* _twitterLoginAnimating;
	
	IBOutlet UIButton*		_shareTwitter;
	IBOutlet UISwitch*      _publishTwitter;
	
	IBOutlet FBLoginButton* _facebookLoginButton;
	IBOutlet UILabel*       _faceBookUserName;
	
	IBOutlet UIButton*		_shareFacebook;
	IBOutlet UISwitch*      _publishFacebook;
	
	FBSession*				_session;
	NSString*				_connectedFaceBookUserName;
	BOOL					_hasFaceBookPermessionToPublishFeed;
	BOOL					_isLogingOut;
	
	IBOutlet UIView*		_twitterShareDialogView;
	IBOutlet UIView*		_twitterShareDialogRounderView;
	IBOutlet UITextView*	_twitterShareDialogTextView;
}

- (IBAction) showLogin;
- (IBAction) doLogin;
- (IBAction) shareAppthroughTwitter:(UIButton*)shareTwitterButton;

@property(nonatomic,readonly) FBSession* session;
@property(nonatomic,readonly) NSString*	 connectedFaceBookUserName;
@property                      BOOL		 hasFaceBookPermessionToPublishFeed;
- (void) publishFavorite;
- (IBAction) shareAppthroughFaceBook:(UIButton*)shareFaceBookButton;										 

- (IBAction) updateTwitterShare;
- (IBAction) cancelTwitterShare;

@end
