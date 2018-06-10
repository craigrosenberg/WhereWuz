//
//  TrackingPoint.h
//  LifePath
//
//  Created by Justin on 6/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface TrackingPoint :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * bearing;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * synchronized;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * altitude;

@property (nonatomic, readonly) NSDictionary* dictionary;

- (void)setFromDictionary:(NSDictionary*)dict;

@end



