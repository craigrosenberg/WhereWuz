//
//  CSRouteView.m
//  testMapp
//
//  Created by Craig on 8/18/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import "CSRouteView.h"
#import "CSRouteAnnotation.h"
#import "CSMapAnnotation.h"
#import "LifePath.h"

#define DISTANCE_THRESHOLD 1000

// this is an internally used view to CSRouteView. The CSRouteView needs a subview that does not get clipped to always
// be positioned at the full frame size and origin of the map. This way the view can be smaller than the route, but it
// always draws in the internal subview, which is the size of the map view. 
@interface CSRouteViewInternal : UIView
{
	// route view which added this as a subview. 
	CSRouteView* _routeView;
	// annotations added to the map
	NSMutableArray*		annotations;
	// Indicates whether this is the first time the route is drawn
	BOOL				firstDraw;
}
@property (nonatomic, retain) CSRouteView* routeView;
@end

@implementation CSRouteViewInternal
@synthesize routeView = _routeView;

-(void) drawRect:(CGRect) rect
{
	CSRouteAnnotation* routeAnnotation = (CSRouteAnnotation*)self.routeView.annotation;
	
	if([routeAnnotation.points count] > 1000)
	{
		NSMutableArray* pointsArray = routeAnnotation.points;
		
		NSMutableIndexSet* indexesToRemove = [NSMutableIndexSet indexSet];
		NSUInteger size = [pointsArray count];
		
		NSUInteger numberToRemove = size - 1000;
		float idxSkip = (float)size / (numberToRemove + 1);
		
		for(NSUInteger i = 1; i <= numberToRemove; ++i)
		{
			NSUInteger idx = (NSUInteger)(i * idxSkip);
			if(idx >= size)
				break;
			
			[indexesToRemove addIndex:idx];
		}
		
		[pointsArray removeObjectsAtIndexes:indexesToRemove];
	}
	
	if(!self.hidden && nil != routeAnnotation.points && routeAnnotation.points.count > 0)
	{
		[[LifePath stopwatch] startMark:@"pathRender"];
//		const float accuracy = routeAnnotation.accuracy;
		const float accuracy = 0;
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		if(nil == routeAnnotation.lineColor)
			routeAnnotation.lineColor = [UIColor blueColor];
		
		CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
		
		// Draw them with a 2.0 stroke width so they are a bit more visible.
		CGContextSetLineWidth(context, 2.0);
		
		CGMutablePathRef path = CGPathCreateMutable();
		BOOL lastOffScreen = NO;
		CLLocation* lastLoc = nil;
		CLLocation* lastRealLoc = nil;
		CGPoint lastPoint;
		int pointsDrawn = 0;
		
		for(CLLocation* location in routeAnnotation.points)
		{
			BOOL startNew = (!lastRealLoc || [location getDistanceFrom:lastRealLoc] > DISTANCE_THRESHOLD);
			CGPoint point = [self.routeView.mapView convertCoordinate:location.coordinate toPointToView:self];
			
			if(CGRectContainsPoint(rect, point))
			{
				if(lastOffScreen)
				{
					++pointsDrawn;
					CGPathMoveToPoint(path, NULL, lastPoint.x, lastPoint.y);
					lastOffScreen = NO;
				}
				
				if(lastLoc)
				{
					float distSq = (point.x - lastPoint.x) * (point.x - lastPoint.x)
						+ (point.y - lastPoint.y) * (point.y - lastPoint.y);
					
					// Skip drawing the point if the distance from the last point is small enough
					if(distSq < accuracy)
					{
						lastRealLoc = location;
						continue;
					}
				}
				
				if(startNew)
				{
					if(lastLoc)
					{
						// Set color to yellow
						CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
						
						if(firstDraw)
						{
							CSMapAnnotation* startPin = [[[CSMapAnnotation alloc] initWithCoordinate:lastLoc.coordinate
																					  annotationType:CSMapAnnotationTypeStart
																							   title:@"Lost Accuracy"] autorelease];
							[_routeView.mapView addAnnotation:startPin];
							[annotations addObject:startPin];
						}
						
						
						// Draw small circle at the end of the last route
//						CGContextFillEllipseInRect(context, CGRectMake(lastPoint.x - 3, lastPoint.y - 3, 6, 6));
					}
					
					// Move to the first point on the route
					CGPathMoveToPoint(path, NULL, point.x, point.y);
					++pointsDrawn;
					
					if(lastLoc)
					{
						if(firstDraw)
						{
							CSMapAnnotation* endPin = [[[CSMapAnnotation alloc] initWithCoordinate:location.coordinate
																					annotationType:CSMapAnnotationTypeEnd
																							 title:@"Regained Accuracy"] autorelease];
							[_routeView.mapView addAnnotation:endPin];
							[annotations addObject:endPin];
						}
						
						// Draw small circle at the beginning of the route
//						CGContextFillEllipseInRect(context, CGRectMake(point.x - 3, point.y - 3, 6, 6));
					}
				}
				else
				{
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					++pointsDrawn;
				}
			}
			else
				lastOffScreen = YES;
			
			lastLoc = location;
			lastRealLoc = location;
			lastPoint = point;
		}
		
		CGContextSetStrokeColorWithColor(context, routeAnnotation.lineColor.CGColor);
		CGContextAddPath(context, path);
		CGContextStrokePath(context);
		CGPathRelease(path);

		[[LifePath stopwatch] endMark:@"pathRender"];
		/*
		NSTimeInterval renderTime = [[[[LifePath stopwatch] marks] objectForKey:@"pathRender"] doubleValue];
		NSString* stats = [NSString stringWithFormat:@"Points: %d\nPoints Drawn: %d\nRender Time:%.3fs",
						   routeAnnotation.points.count, pointsDrawn, renderTime];
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Path Statistics"
														message:stats 
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		 */
	}
}

-(id) init
{
	self = [super init];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	
	annotations = [[NSMutableArray alloc] init];
	
	return self;
}

-(void) dealloc
{
	[_routeView.mapView removeAnnotations:annotations];
	[annotations release];
	self.routeView = nil;
	
	[super dealloc];
}
@end

@implementation CSRouteView
@synthesize mapView = _mapView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		self.backgroundColor = [UIColor clearColor];

		// do not clip the bounds. We need the CSRouteViewInternal to be able to render the route, regardless of where the
		// actual annotation view is displayed. 
		self.clipsToBounds = NO;
		
		// create the internal route view that does the rendering of the route. 
		_internalRouteView = [[CSRouteViewInternal alloc] init];
		_internalRouteView.routeView = self;
		
		[self addSubview:_internalRouteView];
    }
    return self;
}

-(void) setMapView:(MKMapView*) mapView
{
	[_mapView release];
	_mapView = [mapView retain];
	
	[self regionChanged];
}
-(void) regionChanged
{
	// move the internal route view. 
	CGPoint origin = CGPointMake(0, 0);
	origin = [_mapView convertPoint:origin toView:self];
	
	_internalRouteView.frame = CGRectMake(origin.x, origin.y, _mapView.frame.size.width, _mapView.frame.size.height);
	[_internalRouteView setNeedsDisplay];
	
}

- (void)dealloc 
{
	[_mapView release];
	[_internalRouteView release];
	
    [super dealloc];
}


@end
