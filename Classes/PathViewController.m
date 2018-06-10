    //
//  PathViewController.m
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "PathViewController.h"
#import "PathStatisticsViewController.h"
#import "CJSONSerializer.h"
#import "LifePath.h"

#import "LoadingView.h"
#import "ComposeEmailViewController.h"

@implementation PathViewController

- (UIBarButtonItem*)buttonWithImage:(NSString*)image action:(SEL)action
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:image]
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:action];
	return [button autorelease];
}

- (UIBarButtonItem*)addFavoriteButton
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self
																			action:@selector(addFavoritePressed:)];
	button.style = UIBarButtonItemStyleBordered;
	return [button autorelease];
}

- (UIBarButtonItem*)buttonWithTitle:(NSString*)title action:(SEL)action tag:(int)tag
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:title
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:action];
	button.tag = tag;
	return [button autorelease];
}

- (id)initWithRoute:(NSArray*)route
{
	if(self = [super initWithRoute:route])
	{
		self.title = @"Path";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		
		self.toolbarItems = [NSArray arrayWithObjects:
							 [self buttonWithImage:@"globe.png" action:@selector(cycleMapType:)],
							 [self buttonWithTitle:@"Statistics" action:@selector(statisticsPressed:) tag:0],
							 [self buttonWithTitle:@"Share" action:@selector(sharePressed:) tag:0], nil];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Actions

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
		for(PathPoint* point in trackingPoints)
			[dicts addObject:[point dictionary]];
		
		PathStatisticsViewController* stats = [[PathStatisticsViewController alloc] initWithPoints:dicts];
		[self.navigationController pushViewController:stats animated:YES];
		[stats release];
	}
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
	[shareLoadingView removeFromSuperview];
	shareLoadingView = nil;
	
	NSString* errorMsg = [NSString stringWithFormat:
						  @"An error occurred when trying to retrieve the sharing URL.\nPlease try again later.\n(Code: %d)",
						  [error code]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
													message:errorMsg
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	NSLog(@"Failed to load points: %@", [[error userInfo] objectForKey:@"message"]);
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
