    //
//  WhenMapViewController.m
//  LifePath
//
//  Created by Justin on 6/29/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "WhenMapViewController.h"

#import "RectangleAnnotation.h"
#import "RectangleView.h"
#import "PathStatisticsViewController.h"

#import "CSImageAnnotationView.h"
#import "CSRoutePositionAnnotation.h"

#import "CJSONSerializer.h"

@implementation WhenMapViewController

- (id)initWithDate:(NSDate*)date selectOrigin:(CLLocationCoordinate2D)so selectExtent:(CLLocationCoordinate2D)se
{
	if(self = [super initWithRoute:nil])
	{
		self.title = @"When Wuz I?";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		
		selectOrigin = so;
		selectExtent = se;
		
		self.toolbarItems = [NSArray arrayWithObjects:
							 [self buttonWithImage:@"globe.png" action:@selector(cycleMapType:)],
							 [self buttonWithTitle:@"Statistics" action:@selector(statisticsPressed:) tag:0],
 							 [self buttonWithTitle:@"Share" action:@selector(sharePressed:) tag:0],
							 [self addFavoriteButton], nil];
		
		self.navigationItem.rightBarButtonItem = [self buttonWithTitle:@"New Search"
																action:@selector(newSearchPressed:)
																   tag:0];
		
		NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
		NSDateComponents* comps = [[NSCalendar currentCalendar] components:flags fromDate:date];
		
		self.startDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
		[comps setDay:[comps day] + 1];
		self.endDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Throw up our intermediary loading view
	[self.navigationController.view addSubview:self.loadingView];
	
	// Retrieve the data
	/*
	NSTimeInterval start = [startDate timeIntervalSince1970];
	NSTimeInterval end = [endDate timeIntervalSince1970];
	
	NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [[UIDevice currentDevice] uniqueIdentifier], @"deviceID",
						  [NSNumber numberWithDouble:start], @"start",
						  [NSNumber numberWithDouble:end], @"end", nil];
	[[LifePath apiClient] callAsync:@"where" args:args withReceiver:self];
	 */
	
	NSArray* points = [[LifePath data] whereWuzStart:startDate end:endDate];
	NSArray* locations = [[LifePath data] convertTrackingPointsToLocations:points];
	
	[loadingView removeFromSuperview];
	
	if(points.count > 0)
	{
		// Load the route
		self.routePoints = locations;
		self.trackingPoints = points;
		
		// Load the Rectangle annotation
		RectangleAnnotation* rectAnnotation = [[RectangleAnnotation alloc] initWithOrigin:selectOrigin extent:selectExtent];
		rectAnnotation.mapView = self.mapView;
		[self.mapView addAnnotation:rectAnnotation];
	}
	else
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"We could not load the points for this time period.\nPlease try again later."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark Target Invocations

- (void)cycleMapType:(id)sender
{
	switch (mapView.mapType)
	{
		case MKMapTypeStandard:
			mapView.mapType = MKMapTypeSatellite;
			break;
			
		case MKMapTypeSatellite:
			mapView.mapType = MKMapTypeHybrid;
			break;
			
		case MKMapTypeHybrid:
			mapView.mapType = MKMapTypeStandard;
			break;
	}
	
	// Reset the toolbar hiding timer
	[self resetToolbarTimer];
}

- (void)statisticsPressed:(id)sender
{
	if(trackingPoints.count > 0)
	{
		NSMutableArray* dicts = [NSMutableArray arrayWithCapacity:trackingPoints.count];
		for(TrackingPoint* point in trackingPoints)
			[dicts addObject:[point dictionary]];

		PathStatisticsViewController* stats = [[PathStatisticsViewController alloc] initWithPoints:dicts];
		[self.navigationController pushViewController:stats animated:YES];
		[stats release];
	}
}

- (void)addFavoritePressed:(UIBarButtonItem*)sender
{
	// Disable the button so the path can not be saved again
	sender.enabled = NO;
	
	// Push the add favorites view controller
	[[LifePath data] saveNewPath:self.trackingPoints];
	
	// Show the confirmation
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Path Saved" 
													message:@"This path has been saved to your favorites."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)sharePressed:(id)sender
{
	[self grabRouteImage];
	
	// Throw up the sharing action sheet
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Share"
													   delegate:self
											  cancelButtonTitle:@"Cancel"
										 destructiveButtonTitle:nil
											  otherButtonTitles:@"Facebook", @"E-Mail", nil];
//											  otherButtonTitles:@"Facebook", @"Twitter", @"E-Mail", nil];
//							                  otherButtonTitles:@"E-Mail", nil];
	
	[sheet showFromTabBar:self.navigationController.tabBarController.tabBar];
	[sheet release];
}

- (void)newSearchPressed:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark SolemnAPI Receiver

- (void)call:(NSString*)method finishedWithResult:(NSDictionary*)result
{
	if([method isEqualToString:@"where"])
	{
		[self.loadingView removeFromSuperview];
		NSArray* points = [result objectForKey:@"points"];
		NSUInteger totalPoints = [[result objectForKey:@"totalPoints"] unsignedIntValue];
		
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
			// Load the route
			self.routePoints = points;
			
			// Load the Rectangle annotation
			RectangleAnnotation* rectAnnotation = [[RectangleAnnotation alloc] initWithOrigin:selectOrigin extent:selectExtent];
			rectAnnotation.mapView = self.mapView;
			[self.mapView addAnnotation:rectAnnotation];
		}
		else
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
															message:@"We could not load the points for this time period.\nPlease try again later."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}		
	}
	else if([method isEqualToString:@"uploadRoute"])
	{
		// Dispatch the navigation controller
		[shareLoadingView removeFromSuperview];
		shareLoadingView = nil;
		
		// Share the route
		[[LifePath shared] shareRoute:sharingAction 
								  url:[result objectForKey:@"url"]
								image:self.routeImage 
				 navigationController:self.navigationController];
		
		// We're done with the image; release it
		self.routeImage = nil;
	}
}

- (void)call:(NSString*)method finishedWithError:(NSError*)error
{
	[self.loadingView removeFromSuperview];
	[shareLoadingView removeFromSuperview];
	shareLoadingView = nil;
	
	NSString* errorMsg = [NSString stringWithFormat:
						  @"An error occurred while trying to retrieve your records.\nPlease try again later.\n(Code: %d)", [error code]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
													message:errorMsg
												   delegate:([method isEqualToString:@"when"] ? self : nil)
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	NSLog(@"Failed to load points: %@", [[error userInfo] objectForKey:@"message"]);
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{	
	switch(buttonIndex)
	{
			// Facebook
			 case 0:
			 sharingAction = kFacebookAction;
			 break;
			/*
			 
			 // Twitter
			 case 1:
			 sharingAction = kTwitterAction;
			 break;
			 
			 // E-Mail
			 */
			case 1:
				sharingAction = kEmailAction;
				break;
			
			// Cancel
			default:
				sharingAction = kNoAction;
				break;
	}
	
	if(sharingAction != kNoAction)
	{
		// Throw up a loading view while uploading image
		shareLoadingView = [[[LoadingView alloc] initWithFrame:self.navigationController.view.frame] autorelease];
		shareLoadingView.loadingLabel.text = @"Retrieving Share URL";
		shareLoadingView.loadingLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:16.0];
		[self.navigationController.view addSubview:shareLoadingView];
		
		// Upload image
		// Convert image to png
		NSData* pngData = UIImagePNGRepresentation(self.routeImage);
		
		// Create a dictionary for the file
		NSDictionary* route = [NSDictionary dictionaryWithObjectsAndKeys:
							   @"route.png", @"filename",
							   @"image/png", @"content-type",
							   pngData, @"data", nil];
		
		// Upload the route
		NSDictionary* args = [NSDictionary dictionaryWithObject:[[UIDevice currentDevice] uniqueIdentifier]
														 forKey:@"deviceID"];
		NSDictionary* files = [NSDictionary dictionaryWithObject:route forKey:@"routeImage"];
		[[LifePath apiClient] callAsync:@"uploadRoute" args:args files:files withReceiver:self];
	}
	else
		self.routeImage = nil;
}

@end