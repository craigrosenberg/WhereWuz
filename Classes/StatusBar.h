//
//  StatusBar.h
//  DangerZones
//
//  Created by Justin on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatusBar : UIView
{
@private
	UILabel*					statusLabel;
	UIActivityIndicatorView*	activityIndicator;
	
	CGRect						savedFrame;
	BOOL						offScreen;
	BOOL						autoHide;
	
	NSArray*					tickerMessages;
	int							tickerIndex;
	NSTimer*					tickerTimer;
	BOOL						tickerDisplayed;
}

@property (copy) NSString* status;
@property (nonatomic, readonly) UILabel* statusLabel;
@property (readonly) BOOL offScreen;
@property (nonatomic) BOOL showsBusy;
@property (nonatomic) BOOL autoHide;

@property (nonatomic, copy) NSArray* tickerMessages;
@property (nonatomic, retain) NSTimer* tickerTimer;

- (void)setStatus:(NSString*)status animated:(BOOL)animated;
- (void)hideBar;
- (void)unhideBar;

@end
