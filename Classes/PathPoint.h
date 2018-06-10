//
//  PathPoint.h
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Path;
@class TrackingPoint;
@class CLLocation;

@interface PathPoint :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * bearing;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) Path * path;

- (NSDictionary*)dictionary;
- (CLLocation*)location;
- (void)setFromDictionary:(NSDictionary*)dictionary;
- (void)setFromTrackingPoint:(TrackingPoint*)point;
- (void)setFromLocation:(CLLocation*)location;

@end



