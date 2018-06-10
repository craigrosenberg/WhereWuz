//
//  Stopwatch.m
//  LifePath
//
//  Created by Justin on 8/19/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "Stopwatch.h"


@implementation Stopwatch

@synthesize marks, elapsedTime;

- (id)init
{
	if(self = [super init])
	{
		marks = [[NSMutableDictionary alloc] init];
		[self reset];
	}
	
	return self;
}

- (void)dealloc
{
	[marks release];
	[super dealloc];
}

- (void)reset
{
	lastStop = 0;
	elapsedTime = 0;
	[marks removeAllObjects];
}

- (void)start
{
	lastStop = CFAbsoluteTimeGetCurrent();
}

- (void)stop
{
	NSTimeInterval now = CFAbsoluteTimeGetCurrent();
	
	elapsedTime += now - lastStop;
	lastStop = now;
}

- (void)startMark:(NSString*)mark
{
	[marks setObject:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]
			  forKey:mark];
}

- (void)endMark:(NSString*)mark
{
	NSNumber* markStart = [marks objectForKey:mark];
	assert(markStart);
	
	NSTimeInterval t = CFAbsoluteTimeGetCurrent() - [markStart doubleValue];
	[marks setObject:[NSNumber numberWithDouble:t] forKey:mark];
}

@end
