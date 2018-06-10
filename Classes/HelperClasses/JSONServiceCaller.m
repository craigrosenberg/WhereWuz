//
//  JSONServiceCaller.m
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import "JSONServiceCaller.h"
#import "AsyncFeedRequest.h"

@interface JSONServiceCaller (Hidden) 

- (void) initializeLocationManager;
- (void) updateStatus;
- (BOOL) checkNetworkAvailability;

@end

@implementation JSONServiceCaller

@synthesize internetConnectionStatus;
@synthesize remoteHostStatus;

#define GripWareHostName @"www.gripwire.com"

static JSONServiceCaller* sharedJSONServiceCaller;

+ (void) initializeSharedJSONServiceCaller
{
	if(!sharedJSONServiceCaller)
	{
		sharedJSONServiceCaller = [[JSONServiceCaller alloc] init];
		
//		[[Reachability sharedReachability] setHostName:GripWareHostName];
//		[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
		
		[sharedJSONServiceCaller updateStatus];
	}
}

+ (JSONServiceCaller*) getSharedJSONServiceCaller
{
	return sharedJSONServiceCaller;
}

+ (void) disableSharedJSONServiceCaller
{
	[sharedJSONServiceCaller release];	
}

- (id) init
{
	if(self =  [super init])
	{
		reachability = [Reachability reachabilityWithHostName:GripWareHostName];
		[reachability startNotifier];
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedJSONServiceCaller
												 selector:@selector(reachabilityChanged:) 
													 name:@"kNetworkReachabilityChangedNotification" object:nil];
	}	
	return self;
}

- (void) updateStatus 
{
//	self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
//	self.internetConnectionStatus	= [[Reachability sharedReachability] internetConnectionStatus];
}

- (void) reachabilityChanged:(NSNotification *)note 
{
	[self updateStatus];
}

- (BOOL) checkNetworkAvailability
{
	if (self.internetConnectionStatus == NotReachable && self.remoteHostStatus == NotReachable)
	{
		UIAlertView *networkAlert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"This app requires a wifi or wireless connection to the internet." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
		[networkAlert show];
		[networkAlert release];
		return NO;
	}
	return YES;
}

- (void) getFeedsinSubCategory:(NSString*)subCategory   ForCategory:(NSString*)category inTab:(NSString*)tab delegate:(id<JSONServiceDelegate>) _delegate
{
	if([self checkNetworkAvailability]) 
	{		
		AsyncFeedRequest* asyncFeedRequest = [[AsyncFeedRequest alloc] requestFeedsinSubCategory:subCategory ForCategory:category inTab:tab delegate:_delegate];
		[asyncFeedRequest autorelease];
	}
	else 
	{
		[_delegate failedReceivingData];
	}
}

- (void) getIssuesForCategory:(NSString*)category delegate:(id<JSONServiceDelegate>) _delegate
{
	if([self checkNetworkAvailability]) 
	{		
		AsyncFeedRequest* asyncFeedRequest = [[AsyncFeedRequest alloc] requestIssuesForCategory:category delegate:_delegate];
		[asyncFeedRequest autorelease];
	}
	else 
	{
		[_delegate failedReceivingData];
	}
}

- (void) getEventsForCategory:(NSString*)category delegate:(id<JSONServiceDelegate>) _delegate
{
	if([self checkNetworkAvailability]) 
	{		
		AsyncFeedRequest* asyncFeedRequest = [[AsyncFeedRequest alloc] requestEventsForCategory:category delegate:_delegate];
		[asyncFeedRequest autorelease];
	}
	else 
	{
		[_delegate failedReceivingData];
	}
}

- (void) searchStoriesKeyWord:(NSString*)_keyword AndMappingId:(NSString*)_mappingId StartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate
{
	if([self checkNetworkAvailability]) 
	{		
		AsyncFeedRequest* asyncFeedRequest = [[AsyncFeedRequest alloc] requestStoriesKeyWord:_keyword AndMappingId:_mappingId StartingWith:_startCount delegate:_delegate];
		[asyncFeedRequest autorelease];
	}
	else 
	{
		[_delegate failedReceivingData];
	}
}

- (void) getNewsStartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate
{
	if([self checkNetworkAvailability]) 
	{		
		AsyncFeedRequest* asyncFeedRequest = [[AsyncFeedRequest alloc] requestNewsStartingWith:_startCount delegate:_delegate];
		[asyncFeedRequest autorelease];
	}
	else 
	{
		[_delegate failedReceivingData];
	}
}

- (void) dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNetworkReachabilityChangedNotification" object:nil];
	 
	[super dealloc];
}

@end
