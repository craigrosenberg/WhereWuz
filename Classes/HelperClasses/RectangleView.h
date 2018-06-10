//
//  RectangleView.h
//  LifePath
//
//  Created by Justin on 6/29/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@class RectangleViewInternal;

@interface RectangleView : MKAnnotationView
{
	RectangleViewInternal*	internalView;
}

- (void)update;

@end
