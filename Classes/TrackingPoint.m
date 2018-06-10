// 
//  TrackingPoint.m
//  LifePath
//
//  Created by Justin on 6/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrackingPoint.h"


@implementation TrackingPoint 

@dynamic speed;
@dynamic longitude;
@dynamic bearing;
@dynamic latitude;
@dynamic synchronized;
@dynamic timestamp;
@dynamic altitude;

- (void)setFromDictionary:(NSDictionary*)dictionary
{
	self.latitude = [NSNumber numberWithDouble:[[dictionary objectForKey:@"latitude"] doubleValue]];
	self.longitude = [NSNumber numberWithDouble:[[dictionary objectForKey:@"longitude"] doubleValue]];
	self.speed = [NSNumber numberWithFloat:[[dictionary objectForKey:@"speed"] floatValue]];
	self.bearing = [NSNumber numberWithFloat:[[dictionary objectForKey:@"bearing"] floatValue]];
	self.altitude = [NSNumber numberWithFloat:[[dictionary objectForKey:@"altitude"] floatValue]];
	self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"timestamp"] doubleValue]];
	self.synchronized = [NSNumber numberWithBool:YES];
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

@end
