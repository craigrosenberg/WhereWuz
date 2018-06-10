//
//  LifePathTracker.h
//  LifePath
//
//  Created by Justin on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class LifePathTracker;

@protocol LifePathTrackerDelegate

- (void)tracker:(LifePathTracker*)tracker locationChanged:(CLLocation*)location;
- (void)tracker:(LifePathTracker*)tracker accuracyIsGood:(BOOL)good;
- (void)tracker:(LifePathTracker*)tracker isEnabled:(BOOL)enabled;

@end


@interface LifePathTracker : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager*		locationManager;
	BOOL					enabled;
	
	CLLocation*				lastRecordedLocation;
	
	float					locationAccuracy;
	BOOL					goodAccuracy;
	
	BOOL					bypassUpload;
	
	id<LifePathTrackerDelegate> delegate;
}

@property (nonatomic, retain) CLLocationManager* locationManager;

@property (nonatomic) BOOL enabled;
@property (nonatomic, assign) id<LifePathTrackerDelegate> delegate;
@property (nonatomic, retain) CLLocation* lastRecordedLocation;

@property (nonatomic, readonly) CLLocation* currentPosition;

@property (nonatomic, readonly) BOOL goodAccuracy;
@property (nonatomic, readonly) float locationAccuracy;
@property (nonatomic) BOOL bypassUpload;

@end
