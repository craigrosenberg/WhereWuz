//
//  RouteViewController.h
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SearchBottomViewController.h"
#import "LoadingView.h"

@class CSRouteAnnotation;
@class CSRoutePositionAnnotation;
@class CSRouteView;
@class RectangleView;
@class LoadingView;

@interface RouteViewController : UIViewController <SearchBottomViewDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate>
{
	NSArray*						routePoints;
	NSArray*						trackingPoints;
	
	IBOutlet MKMapView*				mapView;
	LoadingView*					loadingView;
	SearchBottomViewController*		searchBottomVC;
	
	NSDate*							startDate;
	NSDate*							endDate;
	
	CSRouteAnnotation*				routeAnnotation;
	CSRoutePositionAnnotation*		routePositionAnnotation;
	CSRouteView*					routeView;
	
	RectangleView*					rectangleView;
	
	NSTimer*						hideToolbarTimer;
	
	UIImage*						routeImage;
	
	NSDateFormatter*				dateFormatter;
}

@property (nonatomic, retain) NSArray* routePoints;
@property (nonatomic, retain) NSArray* trackingPoints;

@property (nonatomic, retain) UIImage* routeImage;
@property (nonatomic, readonly) CSRouteAnnotation* routeAnnotation;

@property (nonatomic, retain) NSTimer* hideToolbarTimer;
@property (nonatomic, retain) IBOutlet SearchBottomViewController* searchBottomVC;

@property (nonatomic, readonly) MKMapView* mapView;

@property (nonatomic, retain) NSDate* startDate;
@property (nonatomic, retain) NSDate* endDate;

@property (nonatomic, readonly) LoadingView* loadingView;

- (id)initWithRoute:(NSArray*)route;

- (void)hideToolbar;
- (void)resetToolbarTimer;

- (void)grabRouteImage;

- (void)loadRoute;

- (UIBarButtonItem*)buttonWithImage:(NSString*)image action:(SEL)action;
- (UIBarButtonItem*)buttonWithTitle:(NSString*)title action:(SEL)action tag:(int)tag;
- (UIBarButtonItem*)addFavoriteButton;

@end
