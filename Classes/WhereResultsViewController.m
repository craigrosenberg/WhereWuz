//
//  WhereResultsViewController.m
//  LifePath
//
//  Created by Justin on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WhereResultsViewController.h"
#import <CoreLocation/CoreLocation.h>

#import "PathStatisticsViewController.h"
#import "CSImageAnnotationView.h"
#import "CJSONSerializer.h"
#import "LifePath.h"

#import "CSRouteAnnotation.h"
#import "CSRouteView.h"

@implementation WhereResultsViewController

- (void)accuracyUp:(id)sender
{
	float a = self.routeAnnotation.accuracy - 20.0f;
	self.routeAnnotation.accuracy = a;
	
	accuracyButton.title = [NSString stringWithFormat:@"%.1f", self.routeAnnotation.accuracy];
	[routeView regionChanged];
}

- (void)accuracyDown:(id)sender
{
	float a = self.routeAnnotation.accuracy + 20.0f;
	self.routeAnnotation.accuracy = a;
	
	accuracyButton.title = [NSString stringWithFormat:@"%.1f", self.routeAnnotation.accuracy];
	[routeView regionChanged];
}

- (void)robPressed:(id)sender
{
	[self.navigationController.view addSubview:self.loadingView];
	self.routePoints = nil;

	NSTimeInterval start = [[NSDate dateWithTimeIntervalSinceNow:-(60.0f * 60 * 24 * 30)] timeIntervalSince1970];
	NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
	NSString* deviceID = @"1b88829811e8d4d341c9a507697c6ac509e0a774";
	
	NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:
						  deviceID, @"deviceID",
						  [NSNumber numberWithDouble:start], @"start",
						  [NSNumber numberWithDouble:end], @"end",
						  nil];
	[[LifePath apiClient] callAsync:@"where" args:args withReceiver:self];
}

- (void)craigPressed:(id)sender
{
	[self.navigationController.view addSubview:self.loadingView];
	self.routePoints = nil;
	
	NSTimeInterval start = [[NSDate dateWithTimeIntervalSinceNow:-(60.0f * 60 * 24 * 30)] timeIntervalSince1970];
	NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
	NSString* deviceID = @"90a0fd4ef206edf443f64824991e210bf3a28d69";
	
	NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:
						  deviceID, @"deviceID",
						  [NSNumber numberWithDouble:start], @"start",
						  [NSNumber numberWithDouble:end], @"end",
						  nil];
	[[LifePath apiClient] callAsync:@"where" args:args withReceiver:self];
	
	
}

- (void)loadRoute
{
	[super loadRoute];
	
	
	
	accuracyButton.title = [NSString stringWithFormat:@"%.1f", self.routeAnnotation.accuracy];
}

- (id)initWithRoute:(NSArray*)points
{
	if(self = [super initWithRoute:points])
	{
		self.title = @"Where Wuz I?";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		
		accuracyButton = [self buttonWithTitle:@"" action:@selector(accuracyUp:) tag:0];
		accuracyButton.enabled = NO;
		accuracyButton.title = [NSString stringWithFormat:@"%.1f", self.routeAnnotation.accuracy];
		
		self.toolbarItems = [NSArray arrayWithObjects:
							 [self buttonWithImage:@"globe.png" action:@selector(cycleMapType:)],
							 [self buttonWithTitle:@"Statistics" action:@selector(statisticsPressed:) tag:0],
							 [self buttonWithTitle:@"Share" action:@selector(sharePressed:) tag:0],
							 [self addFavoriteButton],
//							 [self buttonWithTitle:@"Rob" action:@selector(robPressed:) tag:0],
//							 [self buttonWithTitle:@"Craig" action:@selector(craigPressed:) tag:0],
//							 [self buttonWithTitle:@"Acc+" action:@selector(accuracyUp:) tag:0],
//							 [self buttonWithTitle:@"Acc-" action:@selector(accuracyDown:) tag:0],
//							 accuracyButton,
							 nil];
		
		self.navigationItem.rightBarButtonItem = [self buttonWithTitle:@"New Search" 
																action:@selector(newSearchPressed:)
																   tag:0];
	}
	
	return self;
}



#pragma mark Button Events

- (void)newSearchPressed:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)cycleMapType:(id)sender
{
	switch (self.mapView.mapType)
	{
		case MKMapTypeStandard:
			self.mapView.mapType = MKMapTypeSatellite;
			break;
			
		case MKMapTypeSatellite:
			self.mapView.mapType = MKMapTypeHybrid;
			break;
			
		case MKMapTypeHybrid:
			self.mapView.mapType = MKMapTypeStandard;
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

#pragma mark SolemnAPIClient

- (void)call:(NSString*)method finishedWithResult:(NSDictionary*)result
{	
	if([method isEqualToString:@"where"])
	{
		[loadingView removeFromSuperview];
		self.routePoints = [result objectForKey:@"points"];
		accuracyButton.title = [NSString stringWithFormat:@"%.1f", self.routeAnnotation.accuracy];
		return;
	}

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

- (void)call:(NSString*)method finishedWithError:(NSError*)error
{	
	self.routeImage = nil;
	
	[shareLoadingView removeFromSuperview];
	shareLoadingView = nil;
	
	NSString* errorMsg = [NSString stringWithFormat:
						  @"An error occurred while trying to share your route.\nPlease try again later.\n(Code: %d)", [error code]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
													message:errorMsg
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	NSLog(@"Failed to upload route: %@", [[error userInfo] objectForKey:@"message"]);
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
