//
//  LifePathPreferences.m
//  LifePath
//
//  Created by Justin on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LifePathPreferences.h"
#import "LifePath.h"

NSString* stringForLoggingFrequency(int loggingFrequency)
{
	switch(loggingFrequency)
	{
		case kLoggingFrequency5m:
			return [NSString stringWithString:@"5 meters"];
			
		case kLoggingFrequency10m:
			return [NSString stringWithString:@"10 meters"];
			
		case kLoggingFrequency25m:
			return [NSString stringWithString:@"25 meters"];
			
		case kLoggingFrequency50m:
			return [NSString stringWithString:@"50 meters"];
			
		case kLoggingFrequency100m:
			return [NSString stringWithString:@"100 meters"];
			
		case kLoggingFrequency500m:
			return [NSString stringWithString:@"500 meters"];
			
		case kLoggingFrequency1000m:
			return [NSString stringWithString:@"1000 meters"];
			
		case kLoggingFrequency2500m:
			return [NSString stringWithString:@"2500 meters"];
			
		case kLoggingFrequency5000m:
			return [NSString stringWithString:@"5000 meters"];
	}
	
	return nil;
}

float metersForLoggingFrequency(int loggingFrequency)
{
	switch(loggingFrequency)
	{
		case kLoggingFrequency5m:
			return 5.0f;
			
		case kLoggingFrequency10m:
			return 10.0f;
			
		case kLoggingFrequency25m:
			return 25.0f;
			
		case kLoggingFrequency50m:
			return 50.0f;
			
		case kLoggingFrequency100m:
			return 100.0f;
			
		case kLoggingFrequency500m:
			return 500.0f;
			
		case kLoggingFrequency1000m:
			return 1000.0f;
			
		case kLoggingFrequency2500m:
			return 2500.0f;
			
		case kLoggingFrequency5000m:
			return 5000.0f;
	}
	
	return 0.0f;
}

NSString* stringForDistanceUnit(int distanceUnit)
{
	switch(distanceUnit)
	{
		case kDistanceUnitMeters:
			return [NSString stringWithString:@"Meters"];
			
		case kDistanceUnitFeet:
			return [NSString stringWithString:@"Feet"];
	}
	
	return nil;
}

NSString* stringForDistance(float distance)
{
	NSString* suffix = nil;
	
	switch([LifePath preferences].distanceUnits)
	{
		case kDistanceUnitMeters:
		{
			if(distance > 1000)
			{
				distance /= 1000.0f;
				suffix = @"km";
			}
			else
				suffix = @"m";

			break;
		}
			
		case kDistanceUnitFeet:
		{
			// Convert to feet
			distance *= 3.2808399;
			
			if(distance > 5280)
			{
				distance /= 5280;
				suffix = @"mi";
			}
			else
				suffix = @"ft";
			
			break;
		}
	}
	
	return [NSString stringWithFormat:@"%.2f %@", distance, suffix];
}

NSString* stringForCoordinateUnit(int coordinateUnit)
{
	switch (coordinateUnit)
	{
		case kCoordinateUnitDegrees:
			return [NSString stringWithString:@"Degrees"];

		case kCoordinateUnitRadians:
			return [NSString stringWithString:@"Radians"];

		case kCoordinateUnitGrads:
			return [NSString stringWithString:@"Grads"];
	}
	
	return nil;
}

NSString* stringForCoordinate(float coordinate)
{
	NSString* suffix = nil;
	
	switch([LifePath preferences].coordinateUnits)
	{
		case kCoordinateUnitDegrees:
		{
			suffix = @"\u00B0";
			break;
		}
			
		case kCoordinateUnitRadians:
		{
			coordinate = (coordinate / 180.0) * M_PI;
			suffix = @" rad";
			break;
		}
			
		case kCoordinateUnitGrads:
		{
			coordinate = (coordinate / 180.0) * 200;
			suffix = @" gon";
			break;
		}
	}
	
	if(coordinate < 0)
		coordinate = 0;
	
	return [NSString stringWithFormat:@"%.2f%@", coordinate, suffix];
}

NSString* stringForSpeedUnit(int speedUnit)
{
	switch(speedUnit)
	{
		case kSpeedUnitKilometersPerHour:
			return [NSString stringWithString:@"Kilometers per Hour"];
			
		case kSpeedUnitMetersPerSecond:
			return [NSString stringWithString:@"Meters per Second"];
			
		case kSpeedUnitMilesPerHour:
			return [NSString stringWithString:@"Miles per Hour"];
			
		case kSpeedUnitFeetPerSecond:
			return [NSString stringWithString:@"Feet per Second"];
	}
	
	return nil;
}

NSString* stringForSpeed(float speed)
{
	NSString* suffix = nil;
	
	switch([LifePath preferences].speedUnits)
	{
		case kSpeedUnitMilesPerHour:
		{
			suffix = @"mph";
			speed = ((speed * 3.2808399) / 5280) * 60 * 60;
			break;	
		}
			
		case kSpeedUnitKilometersPerHour:
		{
			suffix = @"kph";
			speed = (speed / 1000.0) * 60 * 60;
			break;
		}
			
		case kSpeedUnitMetersPerSecond:
		{
			suffix = @"m/s";
			break;
		}
			
		case kSpeedUnitFeetPerSecond:
		{
			suffix = @"fps";
			speed *= 3.2808399;
			break;
		}
	}
	
	if(speed < 0)
		speed = 0;
	
	return [NSString stringWithFormat:@"%.2f %@", speed, suffix];
}

NSString* stringForTime(NSTimeInterval time)
{
	NSString* suffix = nil;
	
	if(time > 3600.0)
	{
		time /= 3600.0;
		suffix = @" hr";
	}
	else if(time > 60.0)
	{
		time /= 60.0;
		suffix = @" min";
	}
	else
		suffix = @" sec";
	
	return [NSString stringWithFormat:@"%.2f %@", time, suffix];
}

@implementation LifePathPreferences

- (id)init
{
	if(self = [super init])
	{
		// Set up user preferences on first run
		if(self.firstRunCompleted == NO)
		{
			self.trackerEnabled = YES;
			self.loggingFrequency = kLoggingFrequency25m;
			
			self.coordinateUnits = kCoordinateUnitDegrees;
			self.altitudeUnits = kDistanceUnitFeet;
			self.distanceUnits = kDistanceUnitFeet;
			self.speedUnits = kSpeedUnitMilesPerHour;
			self.timeUnits = 0;
		}
	}
	
	return self;
}

- (BOOL)firstRunCompleted
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunCompleted"];
}

- (void)setFirstRunCompleted:(BOOL)completed
{
	[[NSUserDefaults standardUserDefaults] setBool:completed forKey:@"firstRunCompleted"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)trackerEnabled
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"trackerEnabled"];
}

- (void)setTrackerEnabled:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"trackerEnabled"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)loggingFrequency
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"loggingFrequency"];
}

- (void)setLoggingFrequency:(int)frequency
{
	[[NSUserDefaults standardUserDefaults] setInteger:frequency forKey:@"loggingFrequency"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)coordinateUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"coordinateUnits"];
}

- (void)setCoordinateUnits:(int)units
{
	[[NSUserDefaults standardUserDefaults] setInteger:units forKey:@"coordinateUnits"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)altitudeUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"altitudeUnits"];
}

- (void)setAltitudeUnits:(int)units
{
	[[NSUserDefaults standardUserDefaults] setInteger:units forKey:@"altitudeUnits"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)speedUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"speedUnits"];
}

- (void)setSpeedUnits:(int)units
{
	[[NSUserDefaults standardUserDefaults] setInteger:units forKey:@"speedUnits"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)distanceUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"distanceUnits"];
}

- (void)setDistanceUnits:(int)units
{
	[[NSUserDefaults standardUserDefaults] setInteger:units forKey:@"distanceUnits"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)timeUnits
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"timeUnits"];
}

- (void)setTimeUnits:(int)units
{
	[[NSUserDefaults standardUserDefaults] setInteger:units forKey:@"timeUnits"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


@end
