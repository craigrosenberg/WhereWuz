//
//  RectangleAnnotation.m
//  LifePath
//
//  Created by Justin on 6/29/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "RectangleAnnotation.h"


@implementation RectangleAnnotation

@synthesize coordinate, origin, extent, mapView;

- (id)initWithOrigin:(CLLocationCoordinate2D)orig extent:(CLLocationCoordinate2D)ext;
{
	if(self = [super init])
	{
		origin = orig;
		extent = ext;
		
		coordinate.latitude = (origin.latitude + extent.latitude) / 2.0;
		coordinate.longitude = (origin.longitude + extent.longitude) / 2.0;
	}
    
	return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
