// 
//  PathPoint.m
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PathPoint.h"

#import "Path.h"
#import "TrackingPoint.h"
#import <CoreLocation/CoreLocation.h>

@implementation PathPoint 

@dynamic speed;
@dynamic longitude;
@dynamic bearing;
@dynamic latitude;
@dynamic timestamp;
@dynamic altitude;
@dynamic path;

- (void)setFromDictionary:(NSDictionary*)dictionary
{
	self.latitude = [NSNumber numberWithDouble:[[dictionary objectForKey:@"latitude"] doubleValue]];
	self.longitude = [NSNumber numberWithDouble:[[dictionary objectForKey:@"longitude"] doubleValue]];
	self.speed = [NSNumber numberWithFloat:[[dictionary objectForKey:@"speed"] floatValue]];
	self.bearing = [NSNumber numberWithFloat:[[dictionary objectForKey:@"bearing"] floatValue]];
	self.altitude = [NSNumber numberWithFloat:[[dictionary objectForKey:@"altitude"] floatValue]];
	self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"timestamp"] doubleValue]];	
}

- (void)setFromTrackingPoint:(TrackingPoint*)point
{
	self.latitude = point.latitude;
	self.longitude = point.longitude;
	self.speed = point.speed;
	self.bearing = point.bearing;
	self.altitude = point.altitude;
	self.timestamp = point.timestamp;
}

- (CLLocation*)location
{
	CLLocationCoordinate2D coord;
	coord.latitude = [self.latitude doubleValue];
	coord.longitude = [self.longitude doubleValue];
	
	CLLocation* loc = [[[CLLocation alloc] initWithCoordinate:coord
													 altitude:[self.altitude floatValue]
										   horizontalAccuracy:0
											 verticalAccuracy:0
													timestamp:self.timestamp] autorelease];
	return loc;
}

- (void)setFromLocation:(CLLocation*)location
{
	self.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
	self.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
	self.speed = [NSNumber numberWithFloat:location.speed];
	self.bearing = [NSNumber numberWithFloat:location.course];
	self.altitude = [NSNumber numberWithFloat:location.altitude];
	self.timestamp = location.timestamp;
}

- (NSDictionary*)dictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.latitude, @"latitude",
			self.longitude, @"longitude",
			self.speed, @"speed",
			self.altitude, @"altitude",
			self.bearing, @"bearing",
			[NSNumber numberWithDouble:[self.timestamp timeIntervalSince1970]], @"timestamp", nil];
}	

- (NSComparisonResult)compare:(PathPoint*)pt
{
	return [self.timestamp compare:pt.timestamp];
}

@end
