//
//  TrackingViewController.m
//  LifePath
//
//  Created by Justin on 5/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TrackingViewController.h"
#import "MenuViewController.h"
#import "CSMapAnnotation.h"
#import "CSRouteAnnotation.h"
#import "CSImageAnnotationView.h"
#import "SocialViewController.h"

#import "PathStatisticsViewController.h"

CGImageRef UIGetScreenImage();

@interface TrackingViewController (Hidden)

- (void)updateMap;
- (void)hideToolbar;
- (void)changeMapType:(UIBarButtonItem*)button;

- (void)grabRouteImage;

@end

@implementation TrackingViewController

@synthesize lastLocation, hideToolbarTimer, routeImage;

- (UIBarButtonItem*)buttonWithTitle:(NSString*)title action:(SEL)action tag:(int)tag
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:title
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:action];
	button.tag = tag;
	return [button autorelease];
}

- (UIBarButtonItem*)buttonWithImage:(NSString*)image action:(SEL)action
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:image]
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:action];
	return [button autorelease];
}

// Inject next location if we're running on a simulator
- (void)injectLocation
{
	CLLocation* newLocation = [[LifePath tracker] lastRecordedLocation];
	
	if(newLocation)
	{
		CLLocationCoordinate2D coord = newLocation.coordinate;
		coord.latitude += 0.005 * ((double)rand() / RAND_MAX);
		coord.longitude += 0.005 * ((double)rand() / RAND_MAX);
		CLLocation* simLocation = [[[CLLocation alloc] initWithCoordinate:coord 
																 altitude:newLocation.altitude 
													   horizontalAccuracy:newLocation.horizontalAccuracy 
														 verticalAccuracy:newLocation.verticalAccuracy
																timestamp:[NSDate date]] autorelease];
		
		[[LifePath tracker] locationManager:nil
						didUpdateToLocation:simLocation
							   fromLocation:nil];
	}
}


- (id)init
{
	if(self = [super initWithNibName:@"Tracking2" bundle:nil])
	{
		self.title = @"Tracking";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"current_position_alpha_no_invert.png"];
		
		followMeButton = [self buttonWithImage:@"target.png" action:@selector(toggleFollowMe:)];
		
		self.toolbarItems = [NSArray arrayWithObjects:
							 [self buttonWithImage:@"globe.png" action:@selector(cycleMapType:)],
							 followMeButton,
							 [self buttonWithTitle:@"Statistics" action:@selector(statisticsPressed:) tag:0],
							 [self buttonWithTitle:@"Share" action:@selector(sharePressed:) tag:0],
							 //[self buttonWithTitle:@"Debug" action:@selector(injectLocation) tag:0],
							 nil];
		
//		self.navigationItem.leftBarButtonItem = [self buttonWithTitle:@"Login" action:@selector(loginPressed:) tag:1];		
		firstUpdate = YES;
		
		followMe = NO;
	}
	
	return self;
}

- (void)viewDidLoad
{
	self.navigationController.toolbarHidden = NO;
	
	routeAnnotation = [[CSRouteAnnotation alloc] initWithPoints:[NSArray array]];
	[mapView addAnnotation:routeAnnotation];
	
	statusBar = [[[StatusBar alloc] initWithFrame:statusContainer.bounds] autorelease];
	[statusContainer addSubview:statusBar];
	
	[LifePath tracker].delegate = self;
	
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateMap:) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSArray* points = [[LifePath data] retrieveRecentPoints];
	NSArray* locations = [[LifePath data] convertTrackingPointsToLocations:points];
	
	[routeAnnotation.points setArray:locations];
}

- (void)viewDidAppear:(BOOL)animated
{
	[routeView regionChanged];
}

- (void)updateMap:(NSTimer*)timer
{
	// Wait for a location from the map view
	if(mapView.userLocation.location)
	{
		// Move the map region
		MKCoordinateSpan span = MKCoordinateSpanMake(0.012523, 0.013733);
		MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.location.coordinate, span);
		[mapView setRegion:region animated:YES];
		
		[timer invalidate];
	}
}

- (void)hideToolbar
{
	[self.navigationController setToolbarHidden:YES animated:YES];
}

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
	[hideToolbarTimer invalidate];
	self.hideToolbarTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
															 target:self
														   selector:@selector(hideToolbar)
														   userInfo:nil repeats:NO];	
}

- (void)toggleFollowMe:(UIBarButtonItem*)sender
{
	if(followMe)
	{
		// Turn follow me off
		sender.style = UIBarButtonItemStyleBordered;
		followMe = NO;
	}
	else
	{
		sender.style = UIBarButtonItemStyleDone;
		followMe = YES;
		
		// Move the map to the current position
		MKCoordinateSpan span = MKCoordinateSpanMake(0.012523, 0.013733);
		MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.location.coordinate, span);
		
		automatedRegionChange = YES;
		[mapView setRegion:region animated:YES];
		[routeView regionChanged];
	}
}

- (void)statisticsPressed:(UIBarButtonItem*)button
{
	[self hideToolbar];
	
	NSArray* last24 = [[LifePath data] retrievePointsFromLast24h];
	if(last24.count > 0)
	{
		NSMutableArray* last24_dicts = [NSMutableArray arrayWithCapacity:last24.count];
		for(TrackingPoint* point in last24)
			[last24_dicts addObject:[point dictionary]];
		
		PathStatisticsViewController* stats = [[PathStatisticsViewController alloc] initWithPoints:last24_dicts];
		[self.navigationController pushViewController:stats animated:YES];
		[stats release];
	}
	else
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"There were no points recorded in the last 24 hours."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)loginPressed:(UIBarButtonItem*)button
{
	[self hideToolbar];
	
	SocialViewController* share = [[SocialViewController alloc] init];
	[self.navigationController pushViewController:share animated:YES];
	[share release];
}

- (void)sharePressed:(UIBarButtonItem *)button
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

#pragma mark MapView Delegate Methods

- (void)mapView:(MKMapView *)mv regionWillChangeAnimated:(BOOL)animated
{
	[self.navigationController setToolbarHidden:NO animated:YES];
	
	[hideToolbarTimer invalidate];
	self.hideToolbarTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
															 target:self
														   selector:@selector(hideToolbar)
														   userInfo:nil repeats:NO];

	if(!automatedRegionChange)
	{
		followMe = NO;
		followMeButton.style = UIBarButtonItemStyleBordered;
	}
	else
		automatedRegionChange = NO;
}

- (void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated
{
	[routeView regionChanged];
}

- (MKAnnotationView*)mapView:(MKMapView*)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView* annotationView = nil;
	
	if([annotation isKindOfClass:[CSMapAnnotation class]])
	{
		// determine the type of annotation, and produce the correct type of annotation view for it.
		CSMapAnnotation* csAnnotation = (CSMapAnnotation*)annotation;
		switch(csAnnotation.annotationType)
		{
			case CSMapAnnotationTypeStart:
			case CSMapAnnotationTypeEnd:
			{
				NSString* identifier = @"Pin";
				MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

				if(!pin)
					pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation reuseIdentifier:identifier] autorelease];
				
				[pin setPinColor:(csAnnotation.annotationType == CSMapAnnotationTypeEnd) ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen];
				
				annotationView = pin;
				break;
			}
				
			case CSMapAnnotationTypeImage:
			{
				NSString* identifier = @"Image";
				
				CSImageAnnotationView* imageAnnotationView = (CSImageAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
				if(!imageAnnotationView)
				{
					imageAnnotationView = [[[CSImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];	
					imageAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
				}
				
				annotationView = imageAnnotationView;
				break;
			}
		}
		
		[annotationView setEnabled:YES];
		[annotationView setCanShowCallout:YES];
	}
	else if([annotation isKindOfClass:[CSRouteAnnotation class]])
	{
		if(!routeView)
		{
			routeView = [[[CSRouteView alloc] initWithFrame:mapView.bounds] autorelease];
			
			routeView.annotation = routeAnnotation;
			routeView.mapView = mapView;
			[routeView regionChanged];
		}
		
		annotationView = routeView;
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView*)v calloutAccessoryControlTapped:(UIControl*)control
{

}

- (void)dealloc
{
	self.hideToolbarTimer = nil;
	self.lastLocation = nil;
	[routeAnnotation release];
    [super dealloc];
}

#pragma mark LifePathTrackerDelegate

- (void)tracker:(LifePathTracker*)tracker locationChanged:(CLLocation*)location
{
	NSString* status = [NSString stringWithFormat:@"Tracking Accuracy: %.0fm", location.horizontalAccuracy];
	[statusBar setStatus:status animated:YES];
	statusBar.showsBusy = YES;
	
	NSMutableArray* routePoints = routeAnnotation.points;

	// Remove the oldest point on the route
	if(routePoints.count > 1000)
		[routePoints removeObjectAtIndex:0];
	// Add the point to the end of the array
	[routePoints addObject:location];
	// Update the route's view
	[routeView regionChanged];
	
	// Center the map on the user's location
	if(followMe)
	{
		MKCoordinateSpan span = MKCoordinateSpanMake(0.012523, 0.013733);
		MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
		
		automatedRegionChange = YES;
		[mapView setRegion:region animated:YES];

		self.lastLocation = location;
	}	
}

- (void)tracker:(LifePathTracker*)tracker accuracyIsGood:(BOOL)good
{
	if(!good)
	{
		statusBar.showsBusy = YES;
		statusBar.status = [NSString stringWithFormat:@"Waiting for sufficient GPS accuracy... (%.0fm)", tracker.locationAccuracy];
	}
}

- (void)tracker:(LifePathTracker*)tracker isEnabled:(BOOL)enabled
{
	if(!enabled)
	{
		statusBar.showsBusy = NO;
		statusBar.status = @"Tracking is disabled (see preferences).";
	}
}

#pragma mark -
#pragma mark Sharing

- (void)grabRouteImage
{
	UIGraphicsBeginImageContext(self.view.bounds.size);
	
	[mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
	self.routeImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
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

@end
