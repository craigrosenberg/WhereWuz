//
//  CSMapAnnotation.m
//  mapLines
//
//  Created by Craig on 5/15/09.
//  Copyright 2009 Craig Spitzkoff. All rights reserved.
//

#import "CSMapAnnotation.h"


@implementation CSMapAnnotation

@synthesize coordinate     = _coordinate;
@synthesize annotationType = _annotationType;
@synthesize userData       = _userData;
@synthesize url            = _url;

@synthesize title = _title;
@synthesize subtitle = _subtitle;

-(id) initWithCoordinate:(CLLocationCoordinate2D)c 
		  annotationType:(CSMapAnnotationType)annotationType
				   title:(NSString*)t
{
	self = [super init];
	self.coordinate = c;
	self.title = t;
	_annotationType = annotationType;
	
	geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:c];
	geocoder.delegate = self;
	[geocoder start];
	
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	_coordinate = newCoordinate;
}

-(void) dealloc
{
	[geocoder cancel];
	[geocoder release];
	
	[_title    release];
	[_userData release];
	[_url      release];
	
	[super dealloc];
}

#pragma mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark*)placemark
{
	NSArray* addressLines = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
	
	if(addressLines.count > 0)
		self.title = [addressLines objectAtIndex:0];
	if(addressLines.count > 1);
		self.subtitle = [addressLines objectAtIndex:1];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"Failed to reverse geocode: %@", error);
}

@end
