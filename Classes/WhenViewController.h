//
//  WhenViewController.h
//  LifePath
//
//  Created by Justin on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DrawRectangleView.h"
#import "LifePath.h"
#import "LoadingView.h"

@interface WhenViewController : UIViewController <DrawRectangleDelegate, SolemnAPIReceiver>
{
	IBOutlet MKMapView*			mapView;
	int							mode;
	
	IBOutlet DrawRectangleView*	drawRectView;
	UIBarButtonItem*			rectButton;
	
	NSThread*					apiCall;
	LoadingView*				loadingView;
}

@property (nonatomic, retain) NSThread* apiCall;

@end
