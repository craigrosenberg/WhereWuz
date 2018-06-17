//
//  LifePath.m
//  LifePath
//
//  Created by Justin on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LifePath.h"
#import "ComposeEmailViewController.h"
#import "Analytics.h"
#import "SocialManager.h"

static LifePath* sharedLP = nil;


@implementation LifePath

+ (LifePath*)shared
{
	if(sharedLP == nil)
		sharedLP = [[LifePath alloc] init];
	
	return sharedLP;
}

+ (LifePathTracker*)tracker
{
	return [LifePath shared]->tracker;
}

+ (LifePathPreferences*)preferences
{
	return [LifePath shared]->preferences;
}

+ (LifePathData*)data
{
	return [LifePath shared]->data;
}

+ (SolemnAPIClient*)apiClient
{
	return [LifePath shared]->apiClient;
}

+ (Stopwatch*)stopwatch
{
	return [LifePath shared]->stopwatch;
}

- (id)init
{
	if(self = [super init])
	{
		// Ensure that this singleton is available for the classes we init
		sharedLP = self;
		
		// Shared singletons
		stopwatch = [[Stopwatch alloc] init];
		preferences = [[LifePathPreferences alloc] init];
		data = [[LifePathData alloc] init];
		tracker = [[LifePathTracker alloc] init];
		apiClient = [[SolemnAPIClient alloc] initWithTarget:@"http://184.72.254.21/api"];
	}
	
	return self;
}

- (void)dealloc
{
	[stopwatch release];
	[apiClient release];
	[tracker release];
	[data release];
	[preferences release];
	
	[super dealloc];
}

- (void)shareRoute:(int)shareAction
			   url:(NSString*)shareURL
			 image:(UIImage*)routeImage
navigationController:(UINavigationController*)nc
{
	//[Analytics sendAnalyticsTag:@"sharedRoute" metadata:nil blocking:NO];
	NSLog(@"url: %@", shareURL);
	
	switch(shareAction)
	{
		case kFacebookAction:
		{

			NSMutableDictionary* path = [NSMutableDictionary dictionary];
			[path setObject:@"News" forKey:@"category"];
			[path setObject:@"My Path" forKey:@"Title"];
			[path setObject:shareURL forKey:@"Link"];
			[SocialManager addFavoriteStory:path];	
 
			NSLog(@"Hello, FB Share");
			break; 
		}
			
		case kTwitterAction:
		{
			
			break;
		}
			
		case kEmailAction:
		{
			NSData* pngData = UIImagePNGRepresentation(routeImage);
			
			ComposeEmailViewController* emailVC = [[ComposeEmailViewController alloc] init];
			emailVC.body = [NSString stringWithFormat:@"\n\n%@", shareURL];
			[emailVC addAttachment:pngData mimeType:@"image/png" filename:@"route.png"];
			[nc pushViewController:emailVC animated:YES];
			[emailVC release];
			break;
		}
	}
}

@end
