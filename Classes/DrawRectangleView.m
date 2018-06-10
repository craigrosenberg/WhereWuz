//
//  DrawRectangleView.m
//  LifePath
//
//  Created by Justin on 6/14/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "DrawRectangleView.h"


@implementation DrawRectangleView

@synthesize delegate;

- (CGRect)rectangle
{
	return CGRectMake(boxOrigin.x, boxOrigin.y,
					  boxEnd.x - boxOrigin.x, boxEnd.y - boxOrigin.y);
}

- (void)setRectangle:(CGRect)rect
{
	boxOrigin = rect.origin;
	boxEnd = CGPointMake(boxOrigin.x + rect.size.width, boxOrigin.y + rect.size.height);
	
	[self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.backgroundColor = [UIColor clearColor];
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor magentaColor].CGColor);
	float lineDash[] = {15.0f, 5.0f};
	CGContextSetLineDash(context, 0, lineDash, 2);
	
	CGContextAddRect(context, self.rectangle);
	CGContextStrokePath(context);
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	boxOrigin = [[touches anyObject] locationInView:self];
	boxEnd = boxOrigin;
	
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	boxEnd = [[touches anyObject] locationInView:self];

	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	boxEnd = [[touches anyObject] locationInView:self];

	[self setNeedsDisplay];
	[delegate drawRectangleView:self finishedRect:self.rectangle];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
