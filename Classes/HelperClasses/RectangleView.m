//
//  RectangleView.m
//  LifePath
//
//  Created by Justin on 6/29/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "RectangleView.h"
#import "RectangleAnnotation.h"


@interface RectangleViewInternal : UIView
{
	RectangleView*	rectView;
}

@property (nonatomic, assign) RectangleView* rectView;

@end



@implementation RectangleViewInternal

@synthesize rectView;

- (id)init
{
	if(self = [super init])
	{
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	RectangleAnnotation* ra = rectView.annotation;
	MKMapView* mapView = ra.mapView;
	
	CGPoint origin = [mapView convertCoordinate:ra.origin toPointToView:self];
	CGPoint extent = [mapView convertCoordinate:ra.extent toPointToView:self];
	
	CGRect realRect = CGRectMake(origin.x, origin.y,
								 extent.x - origin.x, extent.y - origin.y);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor magentaColor].CGColor);
	float lineDash[] = {15.0f, 5.0f};
	CGContextSetLineDash(context, 0, lineDash, 2);
	
	CGContextAddRect(context, realRect);
	CGContextStrokePath(context);
}

@end


@implementation RectangleView


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		
		internalView = [[RectangleViewInternal alloc] init];
		internalView.rectView = self;
		[self addSubview:internalView];
		
		[self update];
    }
    return self;
}

- (void)update
{
	RectangleAnnotation* ra = self.annotation;
	
	CGPoint origin = [ra.mapView convertPoint:CGPointZero toView:self];
	internalView.frame = CGRectMake(origin.x, origin.y, ra.mapView.frame.size.width, ra.mapView.frame.size.height);
	[internalView setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}


@end
