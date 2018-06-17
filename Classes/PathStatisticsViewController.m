    //
//  PathStatisticsViewController.m
//  LifePath
//
//  Created by Justin on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PathStatisticsViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "MenuViewController.h"
#import "ComposeEmailViewController.h"
#import "LifePath.h"
#import "Analytics.h"


@implementation PathStatisticsViewController

- (void)calculateStats:(NSArray*)points
{	
	numRecordedPoints = points.count;
	distance = 0.0f;
	elapsedTime = 0.0f;
	avgSpeed = 0.0f;
	avgBearing = 0.0f;
	
	if(points.count == 0)
		return;
	
	CLLocation* lastPt = nil;
	
	for(NSDictionary* point in points)
	{
		float speed = [[point objectForKey:@"speed"] floatValue];
		float bearing = [[point objectForKey:@"bearing"] floatValue];
		float altitude = [[point objectForKey:@"altitude"] floatValue];
		
		if(speed != -1.0)
			avgSpeed += speed;
		if(bearing != -1.0)
			avgBearing += bearing;
		if(altitude != -1.0)
			avgAltitude += altitude;
		
		CLLocation* pt = [[CLLocation alloc] initWithLatitude:[[point objectForKey:@"latitude"] doubleValue]
												   longitude:[[point objectForKey:@"longitude"] doubleValue]];
		
		distance += [lastPt getDistanceFrom:pt];
		
		[lastPt release];
		lastPt = pt;
	}
	
	[lastPt release];
	
	avgSpeed /= numRecordedPoints;
	avgBearing /= numRecordedPoints;
	avgAltitude /= numRecordedPoints;
	
	double start = [[[points objectAtIndex:0] objectForKey:@"timestamp"] doubleValue];
	double end = [[[points lastObject] objectForKey:@"timestamp"] doubleValue];
	elapsedTime = end - start;
}

- (id)initWithPoints:(NSArray*)points
{
	if(self = [super init])
	{
		self.title = @"Path Statistics";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options"
																				  style:UIBarButtonItemStyleBordered
																				 target:self
																				 action:@selector(optionsPressed:)];
		
		[self calculateStats:points];
	}
	
	return self;
}

- (UILabel*)labelForText:(NSString*)text previousFrame:(CGRect)frame
{
	frame.origin.y += 5 + frame.size.height;
	frame.size = CGSizeZero;
	
	UILabel* label = [[UILabel alloc] initWithFrame:frame];
	label.font = [UIFont boldSystemFontOfSize:24.0f];
	label.text = text;
	[label sizeToFit];
	
	return [label autorelease];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	[super loadView];
	
	NSString* pts = [NSString stringWithFormat:@"Recorded Points: %d", numRecordedPoints];
	
	NSString* dist = @"Distance: ";
	dist = [dist stringByAppendingString:stringForDistance(distance)];
	
	NSString* spd = @"Mean Speed: ";
	spd = [spd stringByAppendingString:stringForSpeed(avgSpeed)];
	
	NSString* brg = @"Mean Bearing: ";
	brg = [brg stringByAppendingString:stringForCoordinate(avgBearing)];
	
	NSString* alt = @"Mean Altitude: ";
	alt = [alt stringByAppendingString:stringForDistance(avgAltitude)];
	
	NSString* et = @"Elapsed Time: ";
	et = [et stringByAppendingString:stringForTime(elapsedTime)];
	
	UILabel* nPointsLabel = [self labelForText:pts previousFrame:CGRectMake(10, 10, 0, 0)];
	UILabel* distLabel = [self labelForText:dist previousFrame:nPointsLabel.frame];
	UILabel* speedLabel = [self labelForText:spd previousFrame:distLabel.frame];
	UILabel* bearingLabel = [self labelForText:brg previousFrame:speedLabel.frame];
	UILabel* altitudeLabel = [self labelForText:alt previousFrame:bearingLabel.frame];
	UILabel* timeLabel = [self labelForText:et previousFrame:altitudeLabel.frame];
	
	[self.view addSubview:nPointsLabel];
	[self.view addSubview:distLabel];
	[self.view addSubview:speedLabel];
	[self.view addSubview:bearingLabel];
	[self.view addSubview:altitudeLabel];
	[self.view addSubview:timeLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//[Analytics sendAnalyticsTag:@"viewedStatistics" metadata:nil blocking:NO];
}

- (void)optionsPressed:(id)sender
{
	NSString* dist = @"Distance: ";
	dist = [dist stringByAppendingString:stringForDistance(distance)];
	NSString* spd = @"Mean Speed: ";
	spd = [spd stringByAppendingString:stringForSpeed(avgSpeed)];
	NSString* brg = @"Mean Bearing: ";
	brg = [brg stringByAppendingString:stringForCoordinate(avgBearing)];
	NSString* alt = @"Mean Altitude: ";
	alt = [alt stringByAppendingString:stringForDistance(avgAltitude)];
	NSString* et = @"Elapsed Time: ";
	et = [et stringByAppendingString:stringForTime(elapsedTime)];
	
	ComposeEmailViewController* mailComposer = [[ComposeEmailViewController alloc] init];
	mailComposer.body = [NSString stringWithFormat:@"Here are the statistics for my recent path.\n\n%@\n%@\n%@\n%@\n%@",
						 dist, spd, brg, alt, et];
	mailComposer.bodyIsHTML = NO;
	
	NSDictionary* menuItems = [NSDictionary dictionaryWithObjectsAndKeys:
							   
							   [NSDictionary dictionaryWithObjectsAndKeys:
								@"Email Statistics", @"title",
								[mailComposer autorelease], @"viewController",
								nil], @"email",
							   
							   nil];
	
	NSArray* arrangement = [NSArray arrayWithObjects:@"email", nil];
	
	MenuViewController* menu = [[MenuViewController alloc] initWithTitle:@"Options" items:menuItems arrangement:arrangement];
	[self.navigationController pushViewController:menu animated:YES];
	[menu release];
}


- (void)dealloc {
    [super dealloc];
}


@end
