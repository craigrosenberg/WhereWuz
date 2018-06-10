//
//  CSRoutePositionAnnotation.m
//  LifePath
//
//  Created by Justin on 7/6/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "CSRoutePositionAnnotation.h"

@implementation CSRoutePositionAnnotation

@synthesize routePoints, coordinate;

- (NSString*)title
{
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	
	return [formatter stringFromDate:targetDate];
}

- (NSDate*)targetDate
{
	return targetDate;
}

- (void)setTargetDate:(NSDate*)t
{	
	if(t != targetDate)
	{
		[targetDate release];
		targetDate = [t retain];
	}
	
	CLLocationCoordinate2D previousCoord, finalCoord;
	NSDate* previousDate = nil;
	NSDate* finalDate = nil;
	
	for(CLLocation* point in routePoints)
	{		
		if([targetDate compare:point.timestamp] != NSOrderedDescending)
		{
			finalCoord = point.coordinate;
			finalDate = point.timestamp;
			
			previousPoint = point;
			NSUInteger idx = [routePoints indexOfObject:point];
			if(idx < routePoints.count - 1)
				nextPoint = [routePoints objectAtIndex:[routePoints indexOfObject:point] + 1];
			else
				nextPoint = nil;
			break;
		}
		
		previousCoord = point.coordinate;
		previousDate = point.timestamp;
	}
	
	CLLocationCoordinate2D position;
	
	if(previousDate)
	{
		NSTimeInterval dateDiff = [finalDate timeIntervalSinceDate:previousDate];
		NSTimeInterval targetDiff = [targetDate timeIntervalSinceDate:previousDate];
		float diff = targetDiff / dateDiff;
		
		position.latitude = previousCoord.latitude + (finalCoord.latitude - previousCoord.latitude) * diff;
		position.longitude = previousCoord.longitude + (finalCoord.longitude - previousCoord.longitude) * diff;
	}
	else
		position = finalCoord;
	
	self.coordinate = position;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coord
{
	coordinate = coord;
}

- (void)setPreviousPoint
{
	if(previousPoint)
	{
		// Set the coordinate to the previous point
		NSUInteger idx = [routePoints indexOfObject:previousPoint];
		self.coordinate = previousPoint.coordinate;
		
		[targetDate release];
		targetDate = [previousPoint.timestamp retain];
		
		// Reset the points
		if(idx > 0)
			previousPoint = [routePoints objectAtIndex:--idx];
		else
			previousPoint = nil;
		
		nextPoint = [routePoints objectAtIndex:idx+1];
	}
}

- (void)setNextPoint
{
	if(nextPoint)
	{
		// Set the coordinate to the previous point
		NSUInteger idx = [routePoints indexOfObject:nextPoint];
		self.coordinate = nextPoint.coordinate;
		
		[targetDate release];
		targetDate = [nextPoint.timestamp retain];
		
		// Reset the points
		if(idx < (routePoints.count - 1))
			nextPoint = [routePoints objectAtIndex:++idx];
		else
			nextPoint = nil;
		
		previousPoint = [routePoints objectAtIndex:idx-1];		
	}
}

- (id)initWithPoints:(NSArray*)points
{
	if(self = [super init])
	{
		self.routePoints = points;
		
		CLLocation* startLocation = [points objectAtIndex:0];
		[self setTargetDate:startLocation.timestamp];
	}
	
	return self;
}

- (void)dealloc
{
	self.routePoints = nil;
	[super dealloc];
}

@end
