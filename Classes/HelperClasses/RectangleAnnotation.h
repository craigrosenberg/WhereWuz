//
//  RectangleAnnotation.h
//  LifePath
//
//  Created by Justin on 6/29/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface RectangleAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D		coordinate;

	CLLocationCoordinate2D		origin;
	CLLocationCoordinate2D		extent;
	
	MKMapView*					mapView;
}

@property (nonatomic) CLLocationCoordinate2D origin;
@property (nonatomic) CLLocationCoordinate2D extent;

@property (nonatomic, assign) MKMapView* mapView;

- (id)initWithOrigin:(CLLocationCoordinate2D)orig extent:(CLLocationCoordinate2D)ext;

@end
