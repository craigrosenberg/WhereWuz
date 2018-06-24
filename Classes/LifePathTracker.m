//
//  LifePathTracker.m
//  LifePath
//
//  Created by Justin on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LifePathTracker.h"
#import "LifePath.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

#define ACCURACY_THRESHOLD 100.0f

@implementation LifePathTracker

@synthesize locationManager, locationAccuracy, bypassUpload;

- (void)setDelegate:(id<LifePathTrackerDelegate>)d
{
	delegate = d;
	[delegate tracker:self isEnabled:self.enabled];
	[delegate tracker:self accuracyIsGood:self.goodAccuracy];
}

- (id<LifePathTrackerDelegate>)delegate
{
	return delegate;
}

- (BOOL)goodAccuracy
{
	return (locationAccuracy < ACCURACY_THRESHOLD);
}

- (CLLocation*)currentPosition
{
	return locationManager.location;
}

- (CLLocation*)lastRecordedLocation
{
	// Fill with the last recorded location from the db if we don't have it
	if(!lastRecordedLocation)
	{
		TrackingPoint* point = [[LifePath data] retrieveMostRecentPoint];
		if(point)
			self.lastRecordedLocation = [[LifePath data] convertTrackingPointToLocation:point];
	}
	
	return lastRecordedLocation;
}

- (void)setLastRecordedLocation:(CLLocation*)location
{
	if(location != lastRecordedLocation)
	{
		[lastRecordedLocation release];
		lastRecordedLocation = [location retain];
	}
}

- (id)init
{
	if(self = [super init])
	{
#if TARGET_IPHONE_SIMULATOR
		[[LifePath data] clearAllPoints];
#endif
	
		// Set up the location manager
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = 10.0f;
        [locationManager requestAlwaysAuthorization];
        
		// Enable the tracker
		self.enabled = [LifePath preferences].trackerEnabled;
		self.bypassUpload = NO;
		
		// Start the upload thread
		[NSThread detachNewThreadSelector:@selector(uploadThread) toTarget:self withObject:nil];
	}
	
	return self;
}

- (void)dealloc
{
	self.locationManager = nil;
	[super dealloc];
}

- (BOOL)enabled
{
	return enabled;
}

- (void)setEnabled:(BOOL)en
{
	enabled = en;
	[delegate tracker:self isEnabled:en];
	
	if(en)
		[locationManager startUpdatingLocation];
	else
		[locationManager stopUpdatingLocation];
}



- (BOOL)uploadPoints:(NSArray*)points
{
	NSString* serializedPoints = [[CJSONSerializer serializer] serializeArray:points];
	
	NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [[UIDevice currentDevice] uniqueIdentifier], @"deviceID",
						  serializedPoints, @"points",
						  nil];
	
	NSError* error = nil;
	[[LifePath apiClient] call:@"upload" args:args error:&error];
	if(error)
	{
		NSLog(@"Unable to upload points: %@", error);
		return NO;
	}

	return YES;
}

- (void)uploadThread
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Starting upload thread...");
	
	@try
	{
		for(;;)
		{
			NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
			
			if(bypassUpload)
			{
				[NSThread sleepForTimeInterval:60.0f];
				continue;
			}
			
			// Select any update events that haven't been uploaded
			NSArray* unsynched = [[LifePath data] retrieveUnsynchronizedPoints];

			if(unsynched.count > 0)
			{
				NSMutableArray* dicts = [NSMutableArray arrayWithCapacity:unsynched.count];
				for(TrackingPoint* tp in unsynched)
					[dicts addObject:[tp dictionary]];
				
				// Upload these events
				if([self uploadPoints:dicts])
				{
					NSLog(@"Uploaded %d points.", dicts.count);
					
					// Mark the events as synched
					for(TrackingPoint* point in unsynched)
						point.synchronized = [NSNumber numberWithBool:YES];
					
					// Save the updated points
					[[LifePath data] save];
				}
			}
			
			// Perform database maintenance
			[[LifePath data] performMaintenance];
			
			[innerPool drain];
			
			// Upon completion, sleep for a minute
			[NSThread sleepForTimeInterval:60.0f];
		}
	}
	@catch(NSException* e)
	{
		NSLog(@"Caught an exception in the upload thread: %@", e);
		[NSThread detachNewThreadSelector:@selector(uploadThread) toTarget:self withObject:nil];
	}
	
	[pool drain];
}

#pragma mark LocationManager

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if([error code] == kCLErrorDenied)
	{
		self.enabled = NO;
		[LifePath preferences].trackerEnabled = NO;
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"WhereWuz cannot function properly unless Location Services are enabled." 
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation
{
	locationAccuracy = newLocation.horizontalAccuracy;
	
	// Discard any location less accurate than 50m
	if(newLocation.horizontalAccuracy > ACCURACY_THRESHOLD)
	{
		NSLog(@"Discarded location; accuracy: %.1fm", newLocation.horizontalAccuracy);
		[delegate tracker:self accuracyIsGood:NO];
		return;
	}
	else
		[delegate tracker:self accuracyIsGood:YES];
	
	// Check that the new update distance is sufficiently far from the last recorded
	
	// SDK4.0 only:
//	float distance = [self.lastRecordedLocation distanceFromLocation:newLocation];
	// < SDK4.0:
	float distance = [self.lastRecordedLocation getDistanceFrom:newLocation];
	
	float distanceThreshold = metersForLoggingFrequency([LifePath preferences].loggingFrequency);
	
	if(!lastRecordedLocation || distance >= distanceThreshold)
	{
		NSLog(@"Recorded location; delta: %.1fm; accuracy: %.1fm)", distance, newLocation.horizontalAccuracy);
		
		// Record the location into the local DB
		[[LifePath data] insertNewPoint:newLocation];
		[[LifePath data] save];
		
		self.lastRecordedLocation = newLocation;
	}
	else
		NSLog(@"Discarded location; delta: %.1fm", distance);
	
	[delegate tracker:self locationChanged:newLocation];
}

- (void)injectLocation:(NSTimer*)timer
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if([LifePath preferences].trackerEnabled)
	{
		[self locationManager:locationManager
		  didUpdateToLocation:[timer userInfo]
				 fromLocation:lastRecordedLocation];		
	}
	
	[pool drain];
}

@end
