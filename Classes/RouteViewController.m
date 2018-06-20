    //
//  RouteViewController.m
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "RouteViewController.h"

#import "CSRouteAnnotation.h"
#import "CSMapAnnotation.h"
#import "CSImageAnnotationView.h"
#import "CSRoutePositionAnnotation.h"
#import "CSRouteView.h"

#import "RectangleAnnotation.h"
#import "RectangleView.h"

#import "LifePath.h"

#import <QuartzCore/QuartzCore.h>

// Remove the warning for this undocumented function
CGImageRef UIGetScreenImage();

@interface RouteViewController ()

- (void)loadRoute;

@end


@implementation RouteViewController

@synthesize trackingPoints;
@synthesize searchBottomVC, hideToolbarTimer, startDate, endDate, mapView, loadingView, routeImage, routeAnnotation;

- (void)setRoutePoints:(NSArray*)points
{	
	if(points != routePoints)
	{
		[routePoints release];
		routePoints = [points retain];
		
		if(routePoints && [self isViewLoaded])
			[self loadRoute];
	}
}

- (NSArray*)routePoints
{
	return routePoints;
}

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
	if(self = [super initWithNibName:@"RouteView2" bundle:nil])
	{
		self.routePoints = route;
		
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.timeStyle = NSDateFormatterShortStyle;
		dateFormatter.dateStyle = NSDateFormatterLongStyle;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[self.view addSubview:searchBottomVC.view];
	self.navigationController.toolbarHidden = NO;
	
	loadingView = [[LoadingView alloc] initWithFrame:self.navigationController.view.bounds];
	[self loadRoute];
	[super viewDidLoad];
	
	[[LifePath stopwatch] stop];
	/*
	NSMutableString* stats = [NSMutableString string];
	for(NSString* mark in [[LifePath stopwatch] marks])
	{
		NSNumber* t = [[[LifePath stopwatch] marks] objectForKey:mark];
		[stats appendFormat:@"%@: %.3fs\n", mark, [t doubleValue]];
	}
	
	[stats appendFormat:@"elapsed: %.3fs", [[LifePath stopwatch] elapsedTime]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Statistics"
													message:stats
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	 */
	
	[[LifePath stopwatch] reset];
}

- (void)viewDidUnload
{
	[loadingView release];
	loadingView = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self hideToolbar];
	[super viewWillDisappear:animated];
}

- (void)dealloc
{
	[dateFormatter release];
	[loadingView release];
	
	self.routeImage = nil;
	self.searchBottomVC = nil;
	
	[routePoints release];
	[trackingPoints release];
    [super dealloc];
}

- (void)loadRoute
{
	// Clear the map off
	[mapView removeAnnotations:mapView.annotations];
	
	routeAnnotation = nil;
	routeView = nil;
	
	if(!routePoints)
		return;
	
	[[LifePath stopwatch] startMark:@"loadRoute"];
	
	// Load the points into the mapview
	CLLocation* start = [routePoints objectAtIndex:0];
	CLLocation* end = [routePoints lastObject];
	
	// Add the route into the map
	routeAnnotation = [[CSRouteAnnotation alloc] initWithPoints:routePoints];
	[mapView addAnnotation:routeAnnotation];
	
	// Create the start annotation and add it to the array
	CSMapAnnotation* annotation = [[[CSMapAnnotation alloc] initWithCoordinate:start.coordinate
																annotationType:CSMapAnnotationTypeStart
																		 title:@"Start Point"] autorelease];
	[mapView addAnnotation:annotation];
	
	
	// Create the end annotation and add it to the array
	annotation = [[[CSMapAnnotation alloc] initWithCoordinate:end.coordinate
											   annotationType:CSMapAnnotationTypeEnd
														title:@"End Point"] autorelease];
	[mapView addAnnotation:annotation];
	
	// Create the route position annotation
	routePositionAnnotation = [[[CSRoutePositionAnnotation alloc] initWithPoints:routePoints] autorelease];
	[mapView addAnnotation:routePositionAnnotation];
	
	// Adjust the start and end dates to the first and last recorded times
	self.startDate = start.timestamp;
	self.endDate = end.timestamp;
	searchBottomVC.dateSlider.value = 0;
	[self searchBottomView:searchBottomVC movedSlider:searchBottomVC.dateSlider];
	
	// Set the region and catch any exception if it isn't valid
	@try
	{
		[mapView setRegion:routeAnnotation.region animated:YES];
	}
	@catch(NSException* e)
	{
		NSLog(@"Unable to set map region.");
	}
	
	[[LifePath stopwatch] endMark:@"loadRoute"];
}

- (void)grabRouteImage
{
	UIGraphicsBeginImageContext(self.view.bounds.size);
	
	[mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
	self.routeImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();	
}
/*
- (void)executeScreenGrab
{
	// Capture screen
	unprocessedScreenGrab = UIGetScreenImage();	
	
	// Restore the elements on top of the map
	searchBottomVC.view.hidden = NO;
	self.navigationController.toolbarHidden = NO;
	
	// Schedule a time to process the image after the UI elements have been restored
	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(processScreenGrab) userInfo:nil repeats:NO];
}

- (void)processScreenGrab
{
	// Get the correct rect to clip with
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	CGRect mapFrame = [self.view convertRect:mapView.frame toView:window];
	
	CGSize screenSize = [UIApplication sharedApplication].keyWindow.bounds.size;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(unprocessedScreenGrab), CGImageGetHeight(unprocessedScreenGrab));
	
	if(CGSizeEqualToSize(screenSize, imageSize) == NO)
	{
		UIGraphicsBeginImageContext(screenSize);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0.0, screenSize.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height),
						   unprocessedScreenGrab);
		
		UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
		
		CGImageRelease(unprocessedScreenGrab);
		unprocessedScreenGrab = CGImageRetain(scaledImage.CGImage);
	}
		
	// Clip the image to grab just the mapView
	CGImageRef image = CGImageCreateWithImageInRect(unprocessedScreenGrab,
													CGRectMake(0, mapFrame.origin.y,
															   mapFrame.size.width, mapFrame.size.height));
	// Release the original screen grab
	CGImageRelease(unprocessedScreenGrab);
	unprocessedScreenGrab = NULL;
	
	// Convert the CGImage to UIImage
	UIImage* screenImage = [UIImage imageWithCGImage:image];
	
	// Release the CGImage now that it's a UIImage
	CGImageRelease(image);
	
	[self routeImageCaptured:screenImage];	
}

- (void)routeImageCaptured:(UIImage*)image
{
	self.routeImage = image;
}
*/
#pragma mark Timers

- (void)hideToolbar
{
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)resetToolbarTimer
{
/*
	[hideToolbarTimer invalidate];
	self.hideToolbarTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
															 target:self
														   selector:@selector(hideToolbar)
														   userInfo:nil repeats:NO];
 */
}

#pragma mark SearchBottomViewControllerDelegate

- (void)searchBottomView:(SearchBottomViewController*)sbvc movedSlider:(UISlider*)slider
{
	NSTimeInterval dateDifference = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
	NSDate* interpolatedDate = [startDate dateByAddingTimeInterval:dateDifference * slider.value]; 
	
	sbvc.dateLabel.text = [dateFormatter stringFromDate:interpolatedDate];
	
	// Hide the annotation callout if it's visible
	[mapView deselectAnnotation:routePositionAnnotation animated:YES];
	
	[routePositionAnnotation setTargetDate:interpolatedDate];
	[sbvc setCoordinate:routePositionAnnotation.coordinate];
}

- (void)searchBottomViewPressedPrevious:(SearchBottomViewController*)sbvc
{
	[routePositionAnnotation setPreviousPoint];
	sbvc.dateLabel.text = [dateFormatter stringFromDate:routePositionAnnotation.targetDate];
	[sbvc setCoordinate:routePositionAnnotation.coordinate];
	
	NSTimeInterval dateDifference = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
	NSTimeInterval t = [routePositionAnnotation.targetDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
	
	sbvc.dateSlider.value = t / dateDifference;
}

- (void)searchBottomViewPressedNext:(SearchBottomViewController*)sbvc
{
	[routePositionAnnotation setNextPoint];
	sbvc.dateLabel.text = [dateFormatter stringFromDate:routePositionAnnotation.targetDate];
	[sbvc setCoordinate:routePositionAnnotation.coordinate];
	
	NSTimeInterval dateDifference = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
	NSTimeInterval t = [routePositionAnnotation.targetDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
	
	sbvc.dateSlider.value = t / dateDifference;
}

#pragma mark MapView Delegate Methods

- (void)mapView:(MKMapView *)mv regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
	[self.navigationController setToolbarHidden:NO animated:YES];	
	[self resetToolbarTimer];
}

- (void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated
{
	routeView.hidden = NO;
	[routeView regionChanged];
	[rectangleView update];
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
	else if([annotation isKindOfClass:[CSRoutePositionAnnotation class]])
	{
		annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"position"] autorelease];
		annotationView.image = [UIImage imageNamed:@"user_location.png"];
		
		annotationView.enabled = YES;
		annotationView.canShowCallout = YES;
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	else if([annotation isKindOfClass:[RectangleAnnotation class]])
	{
		rectangleView = [[[RectangleView alloc] initWithFrame:mapView.bounds] autorelease];
		annotationView = rectangleView;
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView*)v calloutAccessoryControlTapped:(UIControl*)control
{
	// Throw up loading screen
	[self.navigationController.view addSubview:loadingView];
	
	// Start reverse geocoding the location
	MKReverseGeocoder* geocoder = [[MKReverseGeocoder alloc] 
								   initWithCoordinate:routePositionAnnotation.coordinate];
	geocoder.delegate = self;
	[geocoder start];
}

#pragma mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)placemark
{
	// Kill the loading screen
	[loadingView removeFromSuperview];
	
	NSArray* addressLines = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
	NSMutableString* info = [NSMutableString string];
	
	for(NSString* line in addressLines)
	{
		if(info.length > 0)
			[info appendString:@"\n"];
		
		[info appendString:line];
	}
	
	// Display the information
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Location Information"
													message:info
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[geocoder autorelease];
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
{
	// Kill the loading screen
	[loadingView removeFromSuperview];
	
	// Throw up an error message
	NSString* errorMsg = [NSString stringWithFormat:
						  @"We were unable to load additional information about this location.\nPlease try again later.\n(Code: %d)", [error code]];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
													message:errorMsg
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	NSLog(@"Failed to reverse geocode: %@", error);
	[geocoder autorelease];
}

@end
