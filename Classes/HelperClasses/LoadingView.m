//
//  LoadingView.m
//  LifePath
//
//  Created by Justin on 7/2/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "LoadingView.h"

#define CORNER_RADIUS 10.0f


@interface DialogView : UIView
{
	UILabel*	loadingLabel;
}

@property (nonatomic, readonly) UILabel* loadingLabel;

@end


@implementation LoadingView

- (UILabel*)loadingLabel
{
	return dialog.loadingLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
		
		dialog = [[[DialogView alloc] initWithFrame:CGRectInset(frame, 
														   frame.size.width * 0.15, 
														   frame.size.height * 0.37)] autorelease];
		[self addSubview:dialog];

    }
	
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation DialogView

- (UILabel*)loadingLabel
{
	if(!loadingLabel)
	{
		loadingLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		loadingLabel.backgroundColor = [UIColor clearColor];
		loadingLabel.textColor = [UIColor whiteColor];
		loadingLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:21.0];
		loadingLabel.text = @"Loading: Please Wait";
	}
	
	return loadingLabel;
}

- (UIActivityIndicatorView*)activityIndicator
{
	UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] 
										 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	activity.frame = CGRectOffset(activity.frame,
								  CGRectGetWidth(self.frame) / 2.0f - CGRectGetMidX(activity.frame), 
								  CGRectGetHeight(self.frame) / 2.0f - CGRectGetMidY(activity.frame) + 15);
	[activity startAnimating];
	activity.hidesWhenStopped = NO;
	
	return [activity autorelease];
}


- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];
		
		[self addSubview:[self loadingLabel]];
		[self addSubview:[self activityIndicator]];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[loadingLabel sizeToFit];
	loadingLabel.frame = CGRectOffset(loadingLabel.frame, 
									  CGRectGetWidth(self.frame) / 2.0f - CGRectGetMidX(loadingLabel.frame), 20);

}

- (void)drawRect:(CGRect)rect
{
	CGSize size = self.frame.size;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 2.0 + CORNER_RADIUS, 2.0);
	CGContextAddArcToPoint(context, size.width - 2.0, 2.0, size.width, 2.0 + CORNER_RADIUS, CORNER_RADIUS);
	CGContextAddArcToPoint(context, size.width - 2.0, size.height, size.width - CORNER_RADIUS, size.height - 2.0, CORNER_RADIUS);
	CGContextAddArcToPoint(context, 2.0, size.height - 2.0, 2.0, size.height - CORNER_RADIUS, CORNER_RADIUS);
	CGContextAddArcToPoint(context, 2.0, 2.0, 2.0 + CORNER_RADIUS, 2.0, CORNER_RADIUS);
	CGContextClosePath(context);
	
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor);
	CGContextSetLineWidth(context, 2.0f);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	[super drawRect:rect];
}

@end

