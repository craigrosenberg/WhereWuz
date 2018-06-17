//
//  PreferencesViewController.m
//  LifePath
//
//  Created by Justin on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferencesViewController.h"
#import "LifePath.h"
#import "MenuViewController.h"
#import "Analytics.h"
#import "LoadingView.h"

#define kButtonWidth 75.0f

@implementation PreferencesViewController

#pragma mark Helper Methods

- (UIButton*)buttonWithTitle:(NSString*)title action:(SEL)action tag:(int)tag
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	button.tag = tag;
	[button sizeToFit];
	
	CGRect buttonFrame = button.frame;
	buttonFrame.size.width = kButtonWidth;
	button.frame = buttonFrame;
	
	return button;
}

- (SelectionViewController*)selectionVCForCoordinates
{
	NSArray* items = [NSArray arrayWithObjects:
					  stringForCoordinateUnit(kCoordinateUnitDegrees),
					  stringForCoordinateUnit(kCoordinateUnitRadians),
					  stringForCoordinateUnit(kCoordinateUnitGrads),
					  nil];
	
	SelectionViewController* selectionVC = [[SelectionViewController alloc] initWithTitle:@"Coordinates" items:items];
	selectionVC.selectedItem = [LifePath preferences].coordinateUnits;
	selectionVC.delegate = self;
	return [selectionVC autorelease];
}

- (SelectionViewController*)selectionVCForAltitude
{
	NSArray* items = [NSArray arrayWithObjects:
					  stringForDistanceUnit(kDistanceUnitMeters),
					  stringForDistanceUnit(kDistanceUnitFeet),
					  nil];
	
	SelectionViewController* selectionVC = [[SelectionViewController alloc] initWithTitle:@"Altitude" items:items];
	selectionVC.selectedItem = [LifePath preferences].altitudeUnits;
	selectionVC.delegate = self;
	return [selectionVC autorelease];
}

- (SelectionViewController*)selectionVCForDistance
{
	NSArray* items = [NSArray arrayWithObjects:
					  stringForDistanceUnit(kDistanceUnitMeters),
					  stringForDistanceUnit(kDistanceUnitFeet),
					  nil];
	
	SelectionViewController* selectionVC = [[SelectionViewController alloc] initWithTitle:@"Distance" items:items];
	selectionVC.selectedItem = [LifePath preferences].distanceUnits;
	selectionVC.delegate = self;
	return [selectionVC autorelease];
}

- (SelectionViewController*)selectionVCForTime
{
	NSArray* items = [NSArray arrayWithObjects:
					  @"Minutes",
					  nil];
	
	SelectionViewController* selectionVC = [[SelectionViewController alloc] initWithTitle:@"Elapsed Time" items:items];
	selectionVC.selectedItem = [LifePath preferences].timeUnits;
	selectionVC.delegate = self;
	return [selectionVC autorelease];
}

- (SelectionViewController*)selectionVCForSpeed
{
	NSArray* items = [NSArray arrayWithObjects:
					  stringForSpeedUnit(kSpeedUnitKilometersPerHour),
					  stringForSpeedUnit(kSpeedUnitMetersPerSecond),
					  stringForSpeedUnit(kSpeedUnitMilesPerHour),
					  stringForSpeedUnit(kSpeedUnitFeetPerSecond),
					  nil];
	
	SelectionViewController* selectionVC = [[SelectionViewController alloc] initWithTitle:@"Speed" items:items];
	selectionVC.selectedItem = [LifePath preferences].speedUnits;
	selectionVC.delegate = self;
	return [selectionVC autorelease];
}


#pragma mark -
#pragma mark Initialization


- (id)init
{
    if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = @"Preferences";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"preferences_alpha_no_invert.png"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = nil;
	
	switch(indexPath.row)
	{
			// Toggle Tracking
		case 0:
		{
			static NSString* CellIdentifier = @"lifetrackerCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"WhereWuz Tracking";
				
				UISwitch* trackerSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
				[trackerSwitch addTarget:self action:@selector(lifetrackerChanged:) forControlEvents:UIControlEventValueChanged];
				cell.accessoryView = trackerSwitch;
			}
			
			UISwitch* tSwitch = (UISwitch*)cell.accessoryView;
			tSwitch.on = [LifePath preferences].trackerEnabled;
			break;
		}
		
			// Change Logging Frequency
		case 1:
		{
			static NSString* CellIdentifier = @"frequencyCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											   reuseIdentifier:CellIdentifier] autorelease];
				cell.accessoryView = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.textLabel.text = @"Logging Frequency";
			}

			cell.detailTextLabel.text = stringForLoggingFrequency([LifePath preferences].loggingFrequency);
			break;
		}
		
			// Change Units
		case 2:
		{
			static NSString* CellIdentifier = @"unitsCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:CellIdentifier] autorelease];
				cell.accessoryView = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.textLabel.text = @"Change Units";
			}
			break;
		}
			
			// Clear Local Database
		case 3:
		{
			static NSString* CellIdentifier = @"clearCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryView = [self buttonWithTitle:@"Clear" action:@selector(clearPressed:) tag:0];
//				cell.textLabel.text = @"Clear Tracking Screen";
				cell.textLabel.text = @"Clear All Points";
			}

			break;
		}
			
			// Clear All Stored Points
		case 4:
		{
			static NSString* CellIdentifier = @"clearCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryView = [self buttonWithTitle:@"Import" action:@selector(importPressed:) tag:0];
				cell.textLabel.text = @"Import All – Patience";
			}
			
			break;
		}
	}	
	
	return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch(indexPath.row)
	{
			// Logging Frequency
		case 1:
		{
			NSArray* loggingOptions = [NSArray arrayWithObjects:
									   stringForLoggingFrequency(kLoggingFrequency5m),
									   stringForLoggingFrequency(kLoggingFrequency10m),
									   stringForLoggingFrequency(kLoggingFrequency25m),
									   stringForLoggingFrequency(kLoggingFrequency50m),
									   stringForLoggingFrequency(kLoggingFrequency100m),
									   stringForLoggingFrequency(kLoggingFrequency500m),
									   stringForLoggingFrequency(kLoggingFrequency1000m),
									   stringForLoggingFrequency(kLoggingFrequency2500m),
									   stringForLoggingFrequency(kLoggingFrequency5000m),
									   nil];
			
			SelectionViewController* selVC = [[SelectionViewController alloc] initWithTitle:@"Logging Frequency"
																					  items:loggingOptions];
			selVC.delegate = self;
			selVC.selectedItem = [LifePath preferences].loggingFrequency;
			
			[self.navigationController pushViewController:selVC animated:YES];
			[selVC release];
			break;
		}
			
			// Change Units
		case 2:
		{
			NSDictionary* menuItems = [NSDictionary dictionaryWithObjectsAndKeys:
									   
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Coordinates", @"title",
										[self selectionVCForCoordinates], @"viewController",
										nil], @"coords",

									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Altitude", @"title",
										[self selectionVCForAltitude], @"viewController",
										nil], @"alt",
									   
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Speed", @"title",
										[self selectionVCForSpeed], @"viewController",
										nil], @"speed",
									   
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Distance", @"title",
										[self selectionVCForDistance], @"viewController",
										nil], @"dist",
									   
									   [NSDictionary dictionaryWithObjectsAndKeys:
										@"Time", @"title",
										[self selectionVCForTime], @"viewController",
										nil], @"time",
									   
									   nil];
			
			NSArray* arrangement = [NSArray arrayWithObjects:@"coords", @"alt", @"speed", @"dist", @"time", nil];
			
			MenuViewController* menu = [[MenuViewController alloc] initWithTitle:@"Change Units" items:menuItems arrangement:arrangement];
			[self.navigationController pushViewController:menu animated:YES];
			[menu release];
			break;
		}
	}
}


- (void)clearPressed:(id)sender
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Are you sure you want to\nclear the tracking screen?" 
												   delegate:self
										  cancelButtonTitle:@"No"
										  otherButtonTitles:@"Yes", nil];
	
	alert.tag = 0;
	[alert show];
	[alert release];
}

- (void)clearAllPressed:(id)sender
{	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Are you sure you want to\nclear all tracking points?\n\nThis action cannot be undone." 
												   delegate:self
										  cancelButtonTitle:@"No"
										  otherButtonTitles:@"Yes", nil];
	alert.tag = 1;
	[alert show];
	[alert release];
}

- (void)importPressed:(id)sender
{
	loadingView = [[[LoadingView alloc] initWithFrame:self.navigationController.view.bounds] autorelease];
	[self.navigationController.view addSubview:loadingView];
	
	[LifePath tracker].bypassUpload = YES;
	
	[[LifePath apiClient] callAsync:@"retrieveAllPoints" 
							   args:[NSDictionary dictionaryWithObject:[[UIDevice currentDevice] uniqueIdentifier]
																forKey:@"deviceID"]
					   withReceiver:self];
}

- (void)selectionViewController:(SelectionViewController*)svc selectedItemChanged:(int)selectedItem;
{
	//[Analytics sendAnalyticsTag:@"changedPreferences" metadata:nil blocking:NO];
	
	if([svc.title isEqualToString:@"Logging Frequency"])
	{
		[LifePath preferences].loggingFrequency = selectedItem;
		[self.tableView reloadData];
	}
	else if([svc.title isEqualToString:@"Coordinates"])
	{
		[LifePath preferences].coordinateUnits = selectedItem;
	}
	else if([svc.title isEqualToString:@"Altitude"])
	{
		[LifePath preferences].altitudeUnits = selectedItem;
	}
	else if([svc.title isEqualToString:@"Speed"])
	{
		[LifePath preferences].speedUnits = selectedItem;
	}
	else if([svc.title isEqualToString:@"Distance"])
	{
		[LifePath preferences].distanceUnits = selectedItem;
	}
	else if([svc.title isEqualToString:@"Time"])
	{
		[LifePath preferences].timeUnits = selectedItem;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)lifetrackerChanged:(UISwitch*)trackerSwitch
{
    /*
	if(trackerSwitch)
		//[Analytics sendAnalyticsTag:@"enabledTracker" metadata:nil blocking:NO];
	else
		//[Analytics sendAnalyticsTag:@"disabledTracker" metadata:nil blocking:NO];
	*/
    
	[LifePath preferences].trackerEnabled = trackerSwitch.on;
	[LifePath tracker].enabled = trackerSwitch.on;
}

#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [super dealloc];
}

#pragma mark AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != alertView.cancelButtonIndex)
	{
		[[LifePath data] clearAllPoints];
		//[Analytics sendAnalyticsTag:@"clearedData" metadata:nil blocking:NO];
	
		/*
		if(alertView.tag == 1)
		{
			NSDictionary* args = [NSDictionary dictionaryWithObject:[[UIDevice currentDevice] uniqueIdentifier]
															 forKey:@"deviceID"];
			[[LifePath apiClient] callAsync:@"deactivateAllPoints" args:args withReceiver:nil];
		}
		 */
	}
}

#pragma mark SolemnAPIClient

- (void)call:(NSString*)method finishedWithResult:(NSDictionary*)result
{	
	[loadingView removeFromSuperview];
	loadingView = nil;
	
	[[LifePath data] clearAllPoints];
	
	NSManagedObjectContext* context = [LifePath data].managedObjectContext;
	
	NSArray* points = [result objectForKey:@"points"];
	for(NSDictionary* point in points)
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		TrackingPoint* tpoint = [NSEntityDescription insertNewObjectForEntityForName:@"TrackingPoint"
															  inManagedObjectContext:context];
		[tpoint setFromDictionary:point];

		[pool drain];
	}
	
	[[LifePath data] save];
	
	NSString* message = [NSString stringWithFormat:@"%d points were imported successfully.", [points count]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Successful"
													message:message
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[LifePath tracker].bypassUpload = NO;
}

- (void)call:(NSString*)method finishedWithError:(NSError*)error
{	
	[loadingView removeFromSuperview];
	loadingView = nil;

	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"Unable to import points."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[LifePath tracker].bypassUpload = NO;
}

@end

