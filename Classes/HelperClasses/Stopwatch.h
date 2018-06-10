//
//  Stopwatch.h
//  LifePath
//
//  Created by Justin on 8/19/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Stopwatch : NSObject
{
	NSMutableDictionary*	marks;
	
	NSTimeInterval			lastStop;
	NSTimeInterval			elapsedTime;
}

@property (nonatomic, readonly) NSDictionary* marks;
@property (nonatomic, readonly) NSTimeInterval elapsedTime;

- (void)reset;
- (void)start;
- (void)stop;

- (void)startMark:(NSString*)mark;
- (void)endMark:(NSString*)mark;

@end
