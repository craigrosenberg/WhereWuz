//
//  PathStatisticsViewController.h
//  LifePath
//
//  Created by Justin on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PathStatisticsViewController : UIViewController
{
	// Meters
	float	distance;
	// Seconds
	float	elapsedTime;
	// Meters per Second
	float	avgSpeed;
	// Degrees
	float	avgBearing;
	// Meters
	float	avgAltitude;
	// Recorded Points
	int		numRecordedPoints;
}

- (id)initWithPoints:(NSArray*)points;

@end
