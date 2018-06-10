//
//  AsyncFeedRequest.m
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import "AsyncFeedRequest.h"

@implementation AsyncFeedRequest

- (id) requestFeedsinSubCategory:(NSString*)_subCategory   ForCategory:(NSString*)_category inTab:(NSString*)_tab delegate:(id<JSONServiceDelegate>) _delegate
{
    return self;
}

- (id) requestEventsForCategory:(NSString*)_category delegate:(id<JSONServiceDelegate>)_delegate
{
    return self;
}

- (id) requestIssuesForCategory:(NSString*)_category delegate:(id<JSONServiceDelegate>)_delegate
{
    return self;
}

- (id) requestStoriesKeyWord:(NSString*)_keyword AndMappingId:(NSString*)_mappingId StartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate
{
    return self;
}

- (id) requestNewsStartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate
{
    return self;
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data 
{ 	
	[dataAccumulator appendData:data];
} 

- (void) connectionDidFinishLoading:(NSURLConnection*)connection 
{ 	 
	NSMutableString* receivedJSON = [[NSMutableString alloc] initWithData:dataAccumulator encoding:NSUTF8StringEncoding];
	[dataAccumulator release];
	dataAccumulator = nil;
	[delegate receivedJSON:[receivedJSON JSONValue]];
	[receivedJSON release];
	[delegate release];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{ 
	[dataAccumulator release];
	dataAccumulator = nil;
	
	[delegate failedReceivingData];
	[delegate release];
}

- (void) dealloc
{	
	[tab release];
	[category release];
	[subCategory release];
	
	[super dealloc];
}

@end
