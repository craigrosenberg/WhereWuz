//
//  WhenMapViewController.h
//  LifePath
//
//  Created by Justin on 6/29/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "LifePath.h"
#import "RectangleView.h"
#import "RouteViewController.h"

@interface WhenMapViewController : RouteViewController <SolemnAPIReceiver, UIActionSheetDelegate>
{
	CLLocationCoordinate2D	selectOrigin;
	CLLocationCoordinate2D	selectExtent;
	
	LoadingView*			shareLoadingView;
	int						sharingAction;
}

- (id)initWithDate:(NSDate*)date selectOrigin:(CLLocationCoordinate2D)so selectExtent:(CLLocationCoordinate2D)se;

@end
