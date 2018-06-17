//
//  Analytics.m
//  DangerZones
//
//  Created by Justin on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Analytics.h"
#import "ASIFormDataRequest.h"
#import <sys/utsname.h>

//static NSString* analyticsUrl = @"http://www.gripwire.com/iphone_analytics/?appId=%@&deviceId=%@&tag=%@&version=%f&model=%@&type=%@&device=%@&";
//static NSString* analyticsUrl = @"http://www.gripwire.com/iphone_analytics/?appId=%@&deviceId=%@&tag=%@&version=%f&model=%@&device=%@&";
static NSString* analyticsUrl = @"http://www.gripwire.com/iphone_analytics/index.php";

@implementation Analytics

+ (void)doAnalytics:(NSURL*)url
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSError* error = nil;
	[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	
	if(error)
		NSLog(@"Error recording analytics: %@", error);
	
	[pool drain];
}

/*	GET-based Analytics
+ (void)sendAnalyticsTag:(NSString*)tag metadata:(NSDictionary*)metadata blocking:(BOOL)blocking
{
	NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
	NSString* appId = [[NSBundle mainBundle] bundleIdentifier];
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	NSString* model = [[UIDevice currentDevice] model]; 
	//NSString* name = [[UIDevice currentDevice] name];
	
	struct utsname u;
	uname(&u);
	NSString *nameString = [NSString stringWithFormat:@"%s", u.machine];
	
	//NSMutableString* urlString = [NSMutableString stringWithFormat:analyticsUrl, appId, deviceId, tag, version, model, name, nameString];
	NSMutableString* urlString = [NSMutableString stringWithFormat:analyticsUrl, appId, deviceId, tag, version, model, nameString];
	if(metadata)
	{
		for(NSString* key in metadata)
		{
			[urlString appendFormat:@"&%@=%@",
			 [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
			 [[metadata objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
	}
		
	if(blocking)
		[Analytics doAnalytics:[NSURL URLWithString:urlString]];
	else
		[NSThread detachNewThreadSelector:@selector(doAnalytics:) toTarget:[Analytics self] withObject:[NSURL URLWithString:urlString]];
	NSLog(@"URL ->%@", urlString);
}
*/

+ (void)sendAnalyticsTag:(NSString*)tag metadata:(NSDictionary*)metadata blocking:(BOOL)blocking
{
    /*
	NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
	NSString* appId = [[NSBundle mainBundle] bundleIdentifier];
	NSString* version = [[UIDevice currentDevice] systemVersion];
	NSString* model = [[UIDevice currentDevice] model];
	
	struct utsname u;
	uname(&u);
	NSString* nameString = [NSString stringWithFormat:@"%s", u.machine];
	
	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:analyticsUrl]];
	[request setTimeOutSeconds:20];
	[request setPostValue:appId forKey:@"appId"];
	[request setPostValue:deviceId forKey:@"deviceId"];
	[request setPostValue:tag forKey:@"tag"];
	[request setPostValue:version forKey:@"version"];
	[request setPostValue:model forKey:@"model"];
	[request setPostValue:nameString forKey:@"device"];
	
	if(metadata)
	{
		for(NSString* key in metadata)
			[request setPostValue:[metadata objectForKey:key] forKey:key];
	}
	
	if(blocking)
		[request startSynchronous];
	else
		[request startAsynchronous];	
	
	NSLog(@"Analytics -> %@", tag);
     */
}

@end
