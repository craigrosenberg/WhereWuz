//
//  AsyncFeedRequest.h
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialManager.h"

@interface AsyncFeedRequest : NSObject
{
	NSString* tab;
	NSString* category;
	NSString* subCategory;
	
	id<JSONServiceDelegate> delegate;	
	NSMutableData* dataAccumulator;
}

- (id) requestFeedsinSubCategory:(NSString*)_subCategory   ForCategory:(NSString*)_category inTab:(NSString*)_tab delegate:(id<JSONServiceDelegate>) _delegate;
- (id) requestIssuesForCategory:(NSString*)_category delegate:(id<JSONServiceDelegate>)_delegate;
- (id) requestEventsForCategory:(NSString*)_category delegate:(id<JSONServiceDelegate>)_delegate;
- (id) requestStoriesKeyWord:(NSString*)_keyword AndMappingId:(NSString*)_mappingId StartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate;
- (id) requestNewsStartingWith:(int)_startCount delegate:(id<JSONServiceDelegate>)_delegate;
@end
