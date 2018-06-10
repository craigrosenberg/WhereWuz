    //
//  WhenViewController.m
//  LifePath
//
//  Created by Justin on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WhenViewController.h"

#import "MenuViewController.h"
#import "WhenMapViewController.h"
#import "Analytics.h"

enum WhenViewControllerModes
{
	kModeMapView,
	kModeDrawRect
};

@interface WhenViewController ()

- (void)retrieveResults;
- (MenuViewController*)menuForDates:(NSArray*)dates;

@end


@implementation WhenViewController

- (NSThread*)apiCall
{
	return apiCall;
}

- (void)setApiCall:(NSThread*)api
{
	if(api != apiCall)
	{
		[apiCall cancel];
		[apiCall release];
		apiCall = [api retain];
	}
}

- (UIBarButtonItem*)buttonWithImage:(NSString*)image action:(SEL)action
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:image]
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:action];
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

- (id)init
{
	if(self = [super initWithNibName:@"WhenWasI" bundle:nil])
	{
		self.title = @"When Wuz";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"when_was_i_query_alpha_no_invert.png"];
		
		rectButton = [self buttonWithImage:@"area-select.png" action:@selector(rectButtonPressed:)];
		
		self.toolbarItems = [NSArray arrayWithObjects:
 							 rectButton,
							 [self buttonWithImage:@"globe.png" action:@selector(changeMapType:)],
							 [self buttonWithTitle:@"When Wuz I Here?" action:@selector(whenPressed:) tag:0],
							 nil];
	}
	
	return self;
}

- (void)viewDidLoad
{	
	drawRectView.rectangle = CGRectInset(self.view.bounds, 10, 10);
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateMap:) userInfo:nil repeats:YES];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:YES animated:YES];
	[super viewWillDisappear:animated];
}

- (void)whenPressed:(id)sender
{
	[Analytics sendAnalyticsTag:@"whenWuzQuery" metadata:nil blocking:NO];
	[self retrieveResults];
}

- (void)changeMapType:(id)sender
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
}

- (void)rectButtonPressed:(UIBarButtonItem*)button
{
	if(mode == kModeMapView)
	{
		mode = kModeDrawRect;
		button.style = UIBarButtonItemStyleDone;
		
		drawRectView.userInteractionEnabled = YES;
	}
	else
	{
		mode = kModeMapView;
		button.style = UIBarButtonItemStyleBordered;
		
		drawRectView.userInteractionEnabled = NO;
	}
}

- (void)drawRectangleView:(DrawRectangleView*)drv finishedRect:(CGRect)rect
{
	mode = kModeMapView;
	rectButton.style = UIBarButtonItemStyleBordered;
	drawRectView.userInteractionEnabled = NO;
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

- (void)dealloc
{
	self.apiCall = nil;
    [super dealloc];
}

#pragma mark Retrieve and Handle Results

- (void)newSearchPressed:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)retrieveResults
{
	loadingView = [[[LoadingView alloc] initWithFrame:self.navigationController.view.bounds] autorelease];
	[self.navigationController.view addSubview:loadingView];
	
	// Convert the selection rectangle to latitude/longitude coordinates to send to the server
	CGRect selectRect = drawRectView.rectangle;
	CGPoint origin = CGPointMake(CGRectGetMinX(selectRect), CGRectGetMinY(selectRect));
	CGPoint extent = CGPointMake(CGRectGetMaxX(selectRect), CGRectGetMaxY(selectRect));
	
	CLLocationCoordinate2D originCoord = [mapView convertPoint:origin toCoordinateFromView:drawRectView];
	CLLocationCoordinate2D extentCoord = [mapView convertPoint:extent toCoordinateFromView:drawRectView];
	
	/*
	NSDictionary* args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [UIDevice currentDevice].uniqueIdentifier, @"deviceID",
						  [NSNumber numberWithDouble:originCoord.latitude], @"o_lat",
						  [NSNumber numberWithDouble:originCoord.longitude], @"o_long",
						  [NSNumber numberWithDouble:extentCoord.latitude], @"e_lat",
						  [NSNumber numberWithDouble:extentCoord.longitude], @"e_long",
						  nil];
	self.apiCall = [[LifePath apiClient] callAsync:@"when" args:args withReceiver:self];
	 */
	
	NSArray* tpoints = [[LifePath data] whenWuzOrigin:originCoord extent:extentCoord];
	
	[loadingView removeFromSuperview];
	
	if([tpoints count] > 0)
	{
		NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:@"dd"];
		
		NSString* currentDay = nil;
		NSDate* currentDayStart = nil;
		NSDate* lastDate = nil;
		
		NSMutableArray* dates = [NSMutableArray array];
		
		for(TrackingPoint* tpoint in tpoints)
		{
			NSDate* date = tpoint.timestamp;
			NSString* day = [formatter stringFromDate:date];
			
			if([currentDay isEqualToString:day] == NO)
			{
				if(currentDayStart)
				{
					// Add the date to the recorded days
					[dates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									  currentDayStart, @"date",
									  currentDayStart, @"start",
									  lastDate, @"end",
									  nil]];
				}
				
				// Set a new current day
			 	currentDay = day;
				
				// Set the current day's start time
				currentDayStart = date;
			}
			
			lastDate = date;
		}
		
		// Add the date to the recorded days
		[dates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						  currentDayStart, @"date",
						  currentDayStart, @"start",
						  lastDate, @"end",
						  nil]];		
		
		MenuViewController* resultsMenu = [self menuForDates:dates];
		[loadingView removeFromSuperview];
		
		[self.navigationController pushViewController:resultsMenu animated:YES];		
	}
	else
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"There is no record of you being in this area."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)call:(NSString*)method finishedWithResult:(NSDictionary*)result
{
	// Check for a results list containing > 0 points.
	NSArray* resultDates = [result objectForKey:@"dates"];
	if([resultDates count] > 0)
	{
		NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:@"dd"];
		
		NSString* currentDay = nil;
		NSMutableArray* dates = [NSMutableArray array];
		
		for(NSString* timestamp in resultDates)
		{
			NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp floatValue]];
			NSString* day = [formatter stringFromDate:date];
			
			if([currentDay isEqualToString:day] == NO)
			{
				// Add the date to the recorded days
				[dates addObject:date];

				// Set a new current day
				currentDay = day;
			}
		}
		
		[dates sortUsingSelector:@selector(compare:)];
		MenuViewController* resultsMenu = [self menuForDates:dates];
		[loadingView removeFromSuperview];
		
		[self.navigationController pushViewController:resultsMenu animated:YES];
	}
	// The user hasn't ever recorded points in this area
	else
	{
		[loadingView removeFromSuperview];
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
														message:@"There is no record of you being in this area."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		NSLog(@"No points to load for this area.");
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
	
	NSLog(@"API 'when' call failure: %@", [[error userInfo] objectForKey:@"message"]);
}

- (MenuViewController*)menuForDates:(NSArray*)dates
{
	NSMutableArray* arrangement = [NSMutableArray arrayWithCapacity:[dates count]];
	
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];

	NSDateFormatter* timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[timeFormatter setDateStyle:NSDateFormatterNoStyle];
	[timeFormatter setTimeStyle:NSDateFormatterShortStyle];	
	
	NSMutableDictionary* menuItems = [NSMutableDictionary dictionary];
	
	CGRect selectRect = drawRectView.rectangle;
	CGPoint origin = CGPointMake(CGRectGetMinX(selectRect), CGRectGetMinY(selectRect));
	CGPoint extent = CGPointMake(CGRectGetMaxX(selectRect), CGRectGetMaxY(selectRect));
	
	CLLocationCoordinate2D originCoord = [mapView convertPoint:origin toCoordinateFromView:drawRectView];
	CLLocationCoordinate2D extentCoord = [mapView convertPoint:extent toCoordinateFromView:drawRectView];
	
	for(NSDictionary* dateInfo in dates)
	{
		NSDate* date = [dateInfo objectForKey:@"date"];
		[arrangement addObject:[date description]];
		
		NSString* subtitle = [NSString stringWithFormat:@"First Seen: %@ Last Seen: %@",
							  [timeFormatter stringFromDate:[dateInfo objectForKey:@"start"]],
							  [timeFormatter stringFromDate:[dateInfo objectForKey:@"end"]]];
		
		NSDictionary* item = [NSDictionary dictionaryWithObjectsAndKeys:
							  [dateFormatter stringFromDate:date], @"title",
							  subtitle, @"subtitle",
							  [[[WhenMapViewController alloc] initWithDate:date
															  selectOrigin:originCoord
															  selectExtent:extentCoord] autorelease], @"viewController",
							  nil];
		
		[menuItems setObject:item forKey:[date description]];
	}

	MenuViewController* menu = [[[MenuViewController alloc] initWithTitle:@"WhenWuz"
																	items:menuItems
															  arrangement:arrangement] autorelease];
	
	menu.navigationItem.rightBarButtonItem = [self buttonWithTitle:@"New Search"
															action:@selector(newSearchPressed:)
															   tag:0];
	return menu;
}

@end
