    //
//  WhereEndViewController.m
//  LifePath
//
//  Created by Justin on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WhereEndViewController.h"
#import "WhereResultsViewController.h"
#import "LifePath.h"
#import "Analytics.h"

@implementation WhereEndViewController

@synthesize startDate;

- (id)initWithStartDate:(NSDate*)date
{
	if(self = [super initWithNibName:@"WhereEnd" bundle:nil])
	{
		self.startDate = date;
		
		self.title = @"Where Wuz I?";
		self.navigationItem.title = self.title;
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"End Time" style:UIBarButtonItemStylePlain target:nil action:nil];
		self.tabBarItem.title = self.title;
	}
	
	return self;
}

- (IBAction)searchPressed:(UIButton*)button
{
	// Toss up loading screen
	[self.navigationController.view addSubview:loadingView];
	
	/*
	// Push results controller
	NSTimeInterval start = [startDate timeIntervalSince1970];
	NSTimeInterval end = [endTimePicker.date timeIntervalSince1970];

	NSString* deviceID = [[UIDevice currentDevice] uniqueIdentifier];
//	NSString* deviceID = @"1b88829811e8d4d341c9a507697c6ac509e0a774";
	
	NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:
						  deviceID, @"deviceID",
						  [NSNumber numberWithDouble:start], @"start",
						  [NSNumber numberWithDouble:end], @"end",
						  nil];
	[[LifePath apiClient] callAsync:@"where" args:args withReceiver:self];
	 */
	
	// Get the results from the data controller
	NSArray* routePoints = [[LifePath data] whereWuzStart:startDate end:endTimePicker.date];
	NSArray* locations = [[LifePath data] convertTrackingPointsToLocations:routePoints];
	
	[Analytics sendAnalyticsTag:@"whereWuzQuery" metadata:nil blocking:NO];
	
	// Remove loading screen
	[loadingView removeFromSuperview];
	
	// Load the results
	if([routePoints count] > 0)
	{
		WhereResultsViewController* resultsVC = [[WhereResultsViewController alloc] initWithRoute:locations];
		resultsVC.trackingPoints = routePoints;
		[self.navigationController pushViewController:resultsVC animated:YES];
		[resultsVC release];
	}
	else
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"There are no recorded data points for that time frame."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	loadingView = [[LoadingView alloc] initWithFrame:self.navigationController.view.bounds];
	
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.timeStyle = NSDateFormatterShortStyle;
	formatter.dateStyle = NSDateFormatterMediumStyle;
	startTimeLabel.text = [NSString stringWithFormat:@"Starting %@",[formatter stringFromDate:startDate]];
	
	endTimePicker.minimumDate = startDate;
	endTimePicker.date = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	endTimePicker.maximumDate = [NSDate date];
	[super viewWillAppear:animated];
}

- (void)dealloc
{
	[loadingView release];
	self.startDate = nil;
    [super dealloc];
}

#pragma mark SolemnAPIClient

- (void)call:(NSString*)method finishedWithResult:(NSDictionary*)result
{	
	NSArray* points = [result objectForKey:@"points"];
	NSInteger totalPoints = [[result objectForKey:@"totalPoints"] intValue];
	
	if(totalPoints > [points count])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"Too much data."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	if(points.count > 0)
	{
		[loadingView removeFromSuperview];
		
		WhereResultsViewController* resultsVC = [[WhereResultsViewController alloc] initWithRoute:points];
		[self.navigationController pushViewController:resultsVC animated:YES];
		[resultsVC release];
	}
	else
	{
		[loadingView removeFromSuperview];
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"There are no recorded data points for that time frame."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)call:(NSString*)method finishedWithError:(NSError*)error
{
	[loadingView removeFromSuperview];
	
	NSString* errorMsg = [NSString stringWithFormat:
						  @"An error occurred while trying to retrieve your records.\nPlease try again later.\n(Code: %d)", [error code]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
													message:errorMsg
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	NSLog(@"Failed to load points: %@", [[error userInfo] objectForKey:@"message"]);
}



@end
