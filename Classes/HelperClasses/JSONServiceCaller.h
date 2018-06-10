//
//  JSONServiceCaller.h
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "JSON.h"

@protocol JSONServiceDelegate <NSObject>

- (void) receivedJSON:(id)jSONValue;
- (void) failedReceivingData;

@end

@interface JSONServiceCaller : NSObject
{
	NetworkStatus internetConnectionStatus;
	NetworkStatus remoteHostStatus;
	
	Reachability*	reachability;
}

@property NetworkStatus internetConnectionStatus;
@property NetworkStatus remoteHostStatus;

+ (void) initializeSharedJSONServiceCaller;
+ (JSONServiceCaller*) getSharedJSONServiceCaller;
+ (void) disableSharedJSONServiceCaller;

- (BOOL) checkNetworkAvailability;

- (void) getFeedsinSubCategory:(NSString*)subCategory   ForCategory:(NSString*)category inTab:(NSString*)tab delegate:(id<JSONServiceDelegate>) _delegate;
- (void) getIssuesForCategory:(NSString*)category delegate:(id<JSONServiceDelegate>) _delegate;
- (void) getEventsForCategory:(NSString*)category delegate:(id<JSONServiceDelegate>) _delegate;

- (void) searchStoriesKeyWord:(NSString*)_keyword AndMappingId:(NSString*)_mappingId StartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate;
- (void) getNewsStartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate;

@end