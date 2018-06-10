//
//  TrackingViewController.h
//  LifePath
//
//  Created by Justin on 5/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "LifePath.h"
#import "StatusBar.h"
#import "CSRouteAnnotation.h"
#import "CSRouteView.h"
#import "LoadingView.h"

@interface TrackingViewController : UIViewController <MKMapViewDelegate, LifePathTrackerDelegate, UIActionSheetDelegate, SolemnAPIReceiver>
{
	IBOutlet MKMapView*		mapView;
	
	CLLocation*				lastLocation;
	BOOL					firstUpdate;
	
	NSTimer*				hideToolbarTimer;
	IBOutlet UIView*		statusContainer;
	StatusBar*				statusBar;
	
	CSRouteAnnotation*		routeAnnotation;
	CSRouteView*			routeView;
	
	BOOL					followMe;
	UIBarButtonItem*		followMeButton;
	BOOL					automatedRegionChange;
	
	LoadingView*			shareLoadingView;
	int						sharingAction;
	
	CGImageRef				unprocessedScreenGrab;
	UIImage*				routeImage;
}

@property (nonatomic, retain) CLLocation*	lastLocation;
@property (nonatomic, retain) NSTimer*		hideToolbarTimer;

@property (nonatomic, retain) UIImage*		routeImage;

@end

