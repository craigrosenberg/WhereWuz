//
//  CSRoutePositionAnnotation.h
//  LifePath
//
//  Created by Justin on 7/6/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface CSRoutePositionAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D	coordinate;
	NSArray*				routePoints;
	
	NSDate*					targetDate;
	CLLocation*				previousPoint;
	CLLocation*				nextPoint;
}

- (id)initWithPoints:(NSArray*)points;

- (void)setPreviousPoint;
- (void)setNextPoint;

@property (nonatomic, retain) NSDate*	targetDate;
@property (nonatomic, retain) NSArray* 	routePoints;

@end
