//
//  LifePathPreferences.h
//  LifePath
//
//  Created by Justin on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

enum LoggingFrequencyOptions
{
	kLoggingFrequency5m,
	kLoggingFrequency10m,
	kLoggingFrequency25m,
	kLoggingFrequency50m,
	kLoggingFrequency100m,
	kLoggingFrequency500m,
	kLoggingFrequency1000m,
	kLoggingFrequency2500m,
	kLoggingFrequency5000m
};

NSString* stringForLoggingFrequency(int loggingFrequency);
float metersForLoggingFrequency(int loggingFrequency);

enum CoordinateUnits
{
	kCoordinateUnitDegrees,
	kCoordinateUnitRadians,
	kCoordinateUnitGrads
};

NSString* stringForCoordinate(float coord);
NSString* stringForCoordinateUnit(int coordUnit);

enum DistanceUnits
{
	kDistanceUnitMeters,
	kDistanceUnitFeet
};

NSString* stringForDistance(float distance);
NSString* stringForDistanceUnit(int distanceUnit);

enum SpeedUnits
{
	kSpeedUnitKilometersPerHour,
	kSpeedUnitMetersPerSecond,
	kSpeedUnitMilesPerHour,
	kSpeedUnitFeetPerSecond
};

NSString* stringForSpeed(float speed);
NSString* stringForSpeedUnit(int speedUnit);

NSString* stringForTime(NSTimeInterval time);

@interface LifePathPreferences : NSObject
{

}

@property (nonatomic) BOOL	firstRunCompleted;
@property (nonatomic) BOOL	trackerEnabled;
@property (nonatomic) int	loggingFrequency;
@property (nonatomic) int	coordinateUnits;
@property (nonatomic) int	altitudeUnits;
@property (nonatomic) int	speedUnits;
@property (nonatomic) int	distanceUnits;
@property (nonatomic) int	timeUnits;

@end
