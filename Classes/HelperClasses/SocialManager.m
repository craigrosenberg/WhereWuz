//
//  SocialManager.m
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import "SocialManager.h"
#import "Analytics.h"

@implementation SocialManager

#define CategoriesAndSubCategoriesFilePath [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CategoriesAndSubCategories.plist"]
#define preferencesFilePath     [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"preferences.plist"]

#pragma mark CategoriesAndSubCategories

static NSDictionary* categories;

+ (NSArray*) categoriesOfTab:(NSString*)tab
{	
	return [[categories objectForKey:tab] isKindOfClass:[NSArray class]] ? [categories objectForKey:tab] : [[categories objectForKey:tab] objectForKey:@"SubCategories"] ;
}

+ (NSArray*) subCategoriesForCategory:(NSString*)category ofTab:(NSString*)tab
{
	return [[categories objectForKey:tab] objectForKey:category];
}

#pragma mark MappingIds

NSDictionary* CategoriesAndSubCategories_ID_Mapping;

+ (NSString*) getMappingIDForSubCategory:(NSString*)_subCategory inCategory:(NSString*)_category ofTab:(NSString*)_tab
{
	return [[[CategoriesAndSubCategories_ID_Mapping objectForKey:_tab] objectForKey:_category] objectForKey:_subCategory];
}

+ (NSString*) getMappingIDForCategory:(NSString*)_category ofTab:(NSString*)_tab
{
	return [[CategoriesAndSubCategories_ID_Mapping objectForKey:_tab] objectForKey:_category];
}

+ (NSString*) getMappingIDForCategory:(NSString*)_category
{
	return [CategoriesAndSubCategories_ID_Mapping  objectForKey:_category];
}

#pragma mark SubCategories Last Receied Feeds

static NSMutableDictionary* lastReceivedFeeds;

+ (NSString*) getLastReceivedFeedforSubCategory:(NSString*)_subCategory inCategory:(NSString*)_category ofTab:(NSString*)_tab
{	
	return [[[lastReceivedFeeds objectForKey:_tab] objectForKey:_category] objectForKey:_subCategory];
}

+ (void) setLastReceivedFeed:(NSString*)_lastFeedReceived forSubCategory:(NSString*)_subCategory inCategory:(NSString*)_category ofTab:(NSString*)_tab
{
	if(![lastReceivedFeeds objectForKey:_tab])
	{
		NSMutableDictionary* feedTab = [[NSMutableDictionary alloc] init];
		[lastReceivedFeeds setObject:feedTab forKey:_tab];
		[feedTab release];
	}
	
	if(![[lastReceivedFeeds objectForKey:_tab] objectForKey:_category])
	{
		NSMutableDictionary* feedCategory = [[NSMutableDictionary alloc] init];
		[[lastReceivedFeeds objectForKey:_tab] setObject:feedCategory forKey:_category];
		[feedCategory release];
	}
	
	[[[lastReceivedFeeds objectForKey:_tab] objectForKey:_category] setObject:_lastFeedReceived forKey:_subCategory];	
}

#pragma mark Publish Settings

static SocialViewController* socialViewController;
static MGTwitterEngine*	sharedTwitterEngine;
static BOOL isTwitterLogedIn;

+ (void) setSocialViewController:(SocialViewController*)_socialViewController
{
	socialViewController = [_socialViewController retain];
	socialViewController.hasFaceBookPermessionToPublishFeed = TRUE;
	sharedTwitterEngine = [[MGTwitterEngine alloc] initWithDelegate:socialViewController];
	
	if(isTwitterLogedIn && [MGTwitterEngine username] && [MGTwitterEngine password] && [[MGTwitterEngine username] length] && [[MGTwitterEngine password] length])
	{
		[sharedTwitterEngine checkUserCredentials];
	}
}

+ (SocialViewController*) getSocialViewController
{
	return socialViewController;	
}

+ (MGTwitterEngine*) getSharedTwitterEngine
{
	NSLog(@"Trying to get Twitter Stuff");
	return sharedTwitterEngine;	
}

static BOOL mobileNotifications;

+ (void) setMobileNotifications:(BOOL)_mobileNotifications
{
	mobileNotifications = _mobileNotifications;
}

+ (BOOL) getMobileNotifications
{
	return mobileNotifications;
}

static BOOL publishFavoritesToFaceBook;

+ (void) setPublishFavoritesToFaceBook:(BOOL)_publishFavoritesToFaceBook
{
	publishFavoritesToFaceBook = _publishFavoritesToFaceBook;
}

+ (BOOL) getPublishFavoritesToFaceBook
{
	return publishFavoritesToFaceBook;
}

+ (void) setTwitterLogedIn:(BOOL)_isTwitterLogedIn
{
	isTwitterLogedIn = _isTwitterLogedIn;
}

+ (BOOL) getTwitterLogedIn
{
	return isTwitterLogedIn;
}

static BOOL publishFavoritesToTwitter;

+ (void) setPublishFavoritesToTwitter:(BOOL)_publishFavoritesToTwitter
{
	publishFavoritesToTwitter = _publishFavoritesToTwitter;
}

+ (BOOL) getPublishFavoritesToTwitter
{
	return publishFavoritesToTwitter;
}

#pragma mark Publish Permissions

+ (BOOL) canPublishFavoritesToFaceBook
{
	if(socialViewController.hasFaceBookPermessionToPublishFeed)
	{
		return YES;
	}
	
	return NO;
}

+ (BOOL) canPublishFavoritesToTwitter
{
	if(isTwitterLogedIn)
	{		
		return YES;		
	}
	
	return NO;
}

#pragma mark Feed Storing

static NSMutableDictionary* storedFeeds;

+ (void) setFeeds:(NSArray*)feeds inSubCategory:(NSString*)subCategory ForCategory:(NSString*)category inTab:(NSString*)tab
{
	if(feeds && [feeds count])
	{	
		NSMutableDictionary* tabCategories = [storedFeeds objectForKey:tab];
		if(!tabCategories)
		{
			tabCategories = [[NSMutableDictionary alloc] init];
			[storedFeeds setObject:tabCategories forKey:tab];
			[tabCategories release];
		}
		
		NSMutableDictionary* feedCategory = [[storedFeeds objectForKey:tab] objectForKey:category];
		if(!feedCategory)
		{
			feedCategory = [[NSMutableDictionary alloc] init];
			[[storedFeeds objectForKey:tab] setObject:feedCategory forKey:category];
			[feedCategory release];
		}
		
		[[[storedFeeds objectForKey:tab] objectForKey:category] setObject:feeds forKey:subCategory];
	}	
}

+ (NSArray*) getFeedsinSubCategory:(NSString*)subCategory ForCategory:(NSString*)category inTab:(NSString*)tab
{
	return [NSArray arrayWithArray:[[[storedFeeds objectForKey:tab] objectForKey:category] objectForKey:subCategory]];
}

#pragma mark Feed Read/UnRead Status

static NSMutableDictionary* feedsStatus;

+ (void) markFeedAsRead:(NSString*)feed inSubCategory:(NSString*)subCategory ForCategory:(NSString*)category  inTab:(NSString*)tab
{
	NSMutableDictionary* tabCategories = [feedsStatus objectForKey:tab];
	if(!tabCategories)
	{
		tabCategories = [[NSMutableDictionary alloc] init];
		[feedsStatus setObject:tabCategories forKey:tab];
		[tabCategories release];
	}
	
	NSMutableDictionary* feedCategory = [[feedsStatus objectForKey:tab] objectForKey:category];
	if(!feedCategory)
	{
		feedCategory = [[NSMutableDictionary alloc] init];
		[[feedsStatus objectForKey:tab] setObject:feedCategory forKey:category];
		[feedCategory release];
	}
	
	NSMutableArray* feedSubCategory = [[[feedsStatus objectForKey:tab] objectForKey:category] objectForKey:subCategory];
	
	if(!feedSubCategory)
	{
		feedSubCategory = [[NSMutableArray alloc] init];
		[[[feedsStatus objectForKey:tab] objectForKey:category] setObject:feedSubCategory forKey:subCategory];
		[feedSubCategory release];
	}

	[[[[feedsStatus objectForKey:tab] objectForKey:category] objectForKey:subCategory] addObject:feed];
}

+ (BOOL) getFeedStatus:(NSString*)feed  inSubCategory:(NSString*)subCategory ForCategory:(NSString*)category  inTab:(NSString*)tab
{
	return [[[[feedsStatus objectForKey:tab] objectForKey:category] objectForKey:subCategory] containsObject:feed];
}


#pragma mark Event Storing

static NSMutableDictionary* storedEvents;

+ (void) setEvents:(NSArray*)events ForCategory:(NSString*)category
{
	if(events && [events count])
	{	
		[storedEvents setObject:events forKey:category];
	}
}

+ (NSArray*) getEventsForCategory:(NSString*)category
{
	return [NSArray arrayWithArray:[storedEvents objectForKey:category]];
}

#pragma mark Event Read/UnRead Status

static NSMutableDictionary* eventsStatus;

+ (void) markEventAsRead:(NSString*)event inCategory:(NSString*)category
{
	NSArray* readCategoryEvents = [eventsStatus objectForKey:category];
	
	if(readCategoryEvents && [readCategoryEvents count])
	{
		if(![readCategoryEvents containsObject:event])
		{	
			readCategoryEvents = [readCategoryEvents arrayByAddingObject:event];
		}
	}
	else
	{
		readCategoryEvents = [NSArray arrayWithObject:event];
	}
	
	[eventsStatus setObject:readCategoryEvents forKey:category];
}

+ (BOOL) getEventStatus:(NSString*)event inCategory:(NSString*)category
{
	return [[eventsStatus objectForKey:category] containsObject:event];
}


#pragma mark Issue Storing

static NSMutableDictionary* storedIssues;

+ (void)     setIssues:(NSArray*)issues ForCategory:(NSString*)category
{
	if(issues && [issues count])
	{	
		[storedIssues setObject:issues forKey:category];
	}
}

+ (NSArray*) getIssuesForCategory:(NSString*)category
{
	return [NSArray arrayWithArray:[storedIssues objectForKey:category]];
}

#pragma mark Issue Read/UnRead Status

static NSMutableDictionary* issuesStatus;

+ (void) markIssueAsRead:(NSString*)issue inCategory:(NSString*)category
{
	NSArray* readCategoryIssues = [issuesStatus objectForKey:category];
	
	if(readCategoryIssues && [readCategoryIssues count])
	{
		if(![readCategoryIssues containsObject:issue])
		{	
			readCategoryIssues = [readCategoryIssues arrayByAddingObject:issue];
		}
	}
	else
	{
		readCategoryIssues = [NSArray arrayWithObject:issue];
	}
	
	[issuesStatus setObject:readCategoryIssues forKey:category];
}

+ (BOOL) getIssueStatus:(NSString*)issue  inCategory:(NSString*)category
{
	return [[issuesStatus objectForKey:category] containsObject:issue];	
}


#pragma mark Favorite Candidate Methods

static NSMutableArray* favoriteCandidates;

+ (NSMutableArray*) favoriteCandidates
{
	return [NSMutableArray arrayWithArray:favoriteCandidates];
}

+ (int) availableFavoriteCandidates
{
	return [favoriteCandidates count];
}

#define CandidateFacebookShare @"{\"name\":\"WhereWuz iPhone Application\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"Real-time and historical information on your location.\",\"description\":\"Turn your iPhone into a powerful tool for viewing real-time and historical data related to where you've been. Get WhereWuz.\",\"media\":[{\"type\":\"image\",\"src\":\"http://184.72.254.21/images/icon.png\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"iTunes Url\":{\"text\":\"Other WhereWuz iPhone Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}}}"
#define CandidateTwitterShare  @"WhereWuz: Know Where You Were at Any Time. http://bit.ly/wherewuz"

+ (void) addFavoriteZone
{
	
	if(publishFavoritesToFaceBook && socialViewController.hasFaceBookPermessionToPublishFeed)
	{	
		[Analytics sendAnalyticsTag:@"FavoriteZonePostedFB" metadata:nil blocking:NO];
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		NSString *attachment = [NSString stringWithFormat:CandidateFacebookShare,socialViewController.connectedFaceBookUserName];
		[params setObject:attachment forKey:@"attachment"];
		[[FBRequest requestWithDelegate:socialViewController] call:@"facebook.Stream.publish" params:params];
	}
	
	if(isTwitterLogedIn && publishFavoritesToTwitter)
	{		
		[Analytics sendAnalyticsTag:@"FavoriteZonePostedTwitter" metadata:nil blocking:NO];
		NSString* twitterFavoriteStationString = [NSString stringWithFormat:CandidateTwitterShare];
		[sharedTwitterEngine sendUpdate:twitterFavoriteStationString];		
	}
}

+ (void) removeFavoriteCandidateAtIndex:(int)atIndex
{
	[favoriteCandidates removeObjectAtIndex:atIndex];
}

#pragma mark Favorite publisher Methods

static NSMutableArray* favoritePublishers;

+ (NSMutableArray*) favoritePublishers
{
	return [NSMutableArray arrayWithArray:favoritePublishers];	
}

+ (int) availableFavoritePublishers
{
	return [favoritePublishers count];
}

#define PublisherFacebookShare @"{\"name\":\"%@\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"%@ just uploaded a new Path via WhereWuz iPhone application.\",\"description\":\"Present and historical data.  Get WhereWuz!\",\"media\":[{\"type\":\"image\",\"src\":\"http://184.72.254.21/images/icon.png\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"another link\":{\"text\":\"Other Applications\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}}}"
#define PublisherTwitterShare  @"has just tagged \"%@\" using WhereWuz. Get WhereWuz: http://bit.ly/WhereWuz"

+ (void) addFavoritePublisher:(NSString*)favoritePublisher
{	
	for (NSString* storedPublisher in favoritePublishers)
	{
		if([favoritePublisher isEqualToString:storedPublisher])
		{
			return;
		}
	}
	[favoritePublishers addObject:favoritePublisher];
	
	if(publishFavoritesToFaceBook && socialViewController.hasFaceBookPermessionToPublishFeed)
	{		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		NSString *attachment = [NSString stringWithFormat:PublisherFacebookShare,favoritePublisher,socialViewController.connectedFaceBookUserName];
		[params setObject:attachment forKey:@"attachment"];
		[[FBRequest requestWithDelegate:socialViewController] call:@"facebook.Stream.publish" params:params];
	}
	
	if(isTwitterLogedIn && publishFavoritesToTwitter)
	{		
		NSString* twitterFavoriteStationString = [NSString stringWithFormat:PublisherTwitterShare,favoritePublisher];
		[sharedTwitterEngine sendUpdate:twitterFavoriteStationString];		
	}
}

+ (void) removeFavoritePublisherAtIndex:(int)atIndex
{
	[favoritePublishers removeObjectAtIndex:atIndex];
}

#pragma mark Favorite Story Methods

static NSMutableArray* favoriteStories;

+ (NSMutableArray*) favoriteStories
{
	return [NSMutableArray arrayWithArray:favoriteStories];	
}

+ (int) availableFavoriteStories
{
	return [favoriteStories count];
}

#define StoryFacebookShare @"{\"name\":\"%@'s WhereWuz Path\",\"href\":\"http://bit.ly/WhereWuz\",\"caption\":\"%@ just uploaded a new Path via WhereWuz iPhone application.\",\"description\":\"Present and historical data.  Get WhereWuz!\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?entity=software&media=all&page=1&restrict=false&startIndex=0&term=wherewuz\"}],\"properties\":{\"another link\":{\"text\":\"See Path\",\"href\":\"%@\"}}}"
#define StoryTwitterShare  @"has just shared \"%@\" using WhereWuz. Get WhereWuz: http://bit.ly/WhereWuz"


+ (void) addFavoriteStory:(NSDictionary*)favoriteStory
{
	for (NSDictionary* storedStory in favoriteStories)
	{
		if([[favoriteStory objectForKey:@"category"] isEqualToString:[storedStory objectForKey:@"category"]] && [[favoriteStory objectForKey:@"FeedId"] isEqualToString:[storedStory objectForKey:@"FeedId"]])
		{
			return;
		}
	}
	 
	[favoriteStories addObject:favoriteStory];	
	
	if(publishFavoritesToFaceBook && socialViewController.hasFaceBookPermessionToPublishFeed)	
	{		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		NSString *attachment = [NSString stringWithFormat:StoryFacebookShare,socialViewController.connectedFaceBookUserName,socialViewController.connectedFaceBookUserName,[favoriteStory objectForKey:@"Link"],[favoriteStory objectForKey:@"Link"],[favoriteStory objectForKey:@"Link"],[favoriteStory objectForKey:@"Link"]];
		[params setObject:attachment forKey:@"attachment"];
		[[FBRequest requestWithDelegate:socialViewController] call:@"facebook.Stream.publish" params:params];
	}
	
	if(isTwitterLogedIn && publishFavoritesToTwitter)
	{		
		[NSThread detachNewThreadSelector:@selector(sendFavoriteStory:) toTarget:[SocialManager class] withObject:favoriteStory];		
	}
}

#define BitlyUrlFormatString @"http://api.bit.ly/shorten?version=2.0.1&login=gripwire&apiKey=R_f94cb47709260ea84fa0c900c1bd649d&longUrl=%@"

+ (void) sendFavoriteStory:(NSDictionary*)favoriteStory
{
	if([[JSONServiceCaller getSharedJSONServiceCaller] checkNetworkAvailability])
	{	
		NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
		
		NSURL* BitlyUrl = [NSURL URLWithString:[NSString stringWithFormat:BitlyUrlFormatString,[favoriteStory objectForKey:@"Link"]]];
		NSString* shortenJSONString = [[NSString alloc] initWithContentsOfURL:BitlyUrl encoding:NSUTF8StringEncoding error:nil];
		NSDictionary* shortenJSON = [shortenJSONString JSONValue];
		[shortenJSONString release];
		
		NSString* shortenString;
		if([@"OK" isEqualToString:[shortenJSON objectForKey:@"statusCode"]])
		{
			shortenString = [[[shortenJSON objectForKey:@"results"] objectForKey:[favoriteStory objectForKey:@"Link"]] objectForKey:@"shortUrl"];
		}
		NSString* twitterFavoriteSong = [NSString stringWithFormat:StoryTwitterShare,shortenString];
		
		[sharedTwitterEngine performSelectorOnMainThread:@selector(sendUpdate:) withObject:twitterFavoriteSong waitUntilDone:YES];
		
		[autoReleasePool drain];
		[autoReleasePool release];
	}
}

+ (void) removeFavoriteStoryAtIndex:(int)atIndex
{
	[favoriteStories removeObjectAtIndex:atIndex];
}

#pragma mark Favorite Issue Methods

static NSMutableArray* favoriteIssues;

+ (NSMutableArray*) favoriteIssues
{
	return [NSMutableArray arrayWithArray:favoriteIssues];	
}

+ (int) availableFavoriteIssues
{
	return [favoriteIssues count];
}

+ (void) addFavoriteIssue:(NSDictionary*)favoriteIssue
{
	for (NSDictionary* storedIssue in favoriteIssues)
	{
		if([[favoriteIssue objectForKey:@"category"] isEqualToString:[storedIssue objectForKey:@"category"]] && [[favoriteIssue objectForKey:@"FeedId"] isEqualToString:[storedIssue objectForKey:@"FeedId"]])
		{
			return;
		}
	}
	[favoriteIssues addObject:favoriteIssue];
	
	if(publishFavoritesToFaceBook && socialViewController.hasFaceBookPermessionToPublishFeed)
	{		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		NSString *attachment = [NSString stringWithFormat:StoryFacebookShare,[favoriteIssue objectForKey:@"Title"],[favoriteIssue objectForKey:@"Link"],socialViewController.connectedFaceBookUserName];
		[params setObject:attachment forKey:@"attachment"];
		[[FBRequest requestWithDelegate:socialViewController] call:@"facebook.Stream.publish" params:params];
	}
	
	if(isTwitterLogedIn && publishFavoritesToTwitter)
	{		
		[NSThread detachNewThreadSelector:@selector(sendFavoriteStory:) toTarget:[SocialManager class] withObject:favoriteIssue];		
	}
}

+ (void) removeFavoriteIssueAtIndex:(int)atIndex
{
	[favoriteIssues removeObjectAtIndex:atIndex];
}

#pragma mark Favorite Event Methods

static NSMutableArray* favoriteEvents;

+ (NSMutableArray*) favoriteEvents
{
	return [NSMutableArray arrayWithArray:favoriteEvents];	
}

+ (int) availableFavoriteEvents
{
	return [favoriteEvents count];
} 

+ (void) addFavoriteEvent:(NSDictionary*)favoriteEvent
{
	for (NSDictionary* storedEvent in favoriteEvents)
	{
		if([[favoriteEvent objectForKey:@"category"] isEqualToString:[storedEvent objectForKey:@"category"]] && [[favoriteEvent objectForKey:@"FeedId"] isEqualToString:[storedEvent objectForKey:@"FeedId"]])
		{
			return;
		}
	}
	
	[favoriteEvents addObject:favoriteEvent];
	
	if(publishFavoritesToFaceBook && socialViewController.hasFaceBookPermessionToPublishFeed)
	{		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		NSString *attachment = [NSString stringWithFormat:StoryFacebookShare,[favoriteEvent objectForKey:@"Title"],[favoriteEvent objectForKey:@"Link"],socialViewController.connectedFaceBookUserName];
		[params setObject:attachment forKey:@"attachment"];
		[[FBRequest requestWithDelegate:socialViewController] call:@"facebook.Stream.publish" params:params];
	}
	
	if(isTwitterLogedIn && publishFavoritesToTwitter)
	{		
		[NSThread detachNewThreadSelector:@selector(sendFavoriteStory:) toTarget:[SocialManager class] withObject:favoriteEvent];		
	}
}

+ (void) removeFavoriteEventAtIndex:(int)atIndex
{
	[favoriteEvents removeObjectAtIndex:atIndex];
}

#pragma mark Share With FaceBook And Twitter

+ (void) shareFavoriteStoryWithFaceBook:(NSDictionary*)favoriteStory
{
	if(publishFavoritesToFaceBook && socialViewController.hasFaceBookPermessionToPublishFeed)
	{		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		NSString *attachment = [NSString stringWithFormat:StoryFacebookShare,[favoriteStory objectForKey:@"Title"],[favoriteStory objectForKey:@"Link"],socialViewController.connectedFaceBookUserName];
		[params setObject:attachment forKey:@"attachment"];
		[[FBRequest requestWithDelegate:socialViewController] call:@"facebook.Stream.publish" params:params];
	}
}

+ (void) shareFavoriteStoryWithTwitter:(NSDictionary*)favoriteStory
{
	if(isTwitterLogedIn && publishFavoritesToTwitter)
	{		
		[NSThread detachNewThreadSelector:@selector(sendFavoriteStory:) toTarget:[SocialManager class] withObject:favoriteStory];		
	}
}

#pragma mark FaceBook And Twitter Queues

static NSMutableArray* faceBookQueue;

+ (void) addStoryIntoFaceBookQueue:(NSDictionary*)_story
{
	for (NSDictionary* storedStory in faceBookQueue)
	{
		if([[_story objectForKey:@"category"] isEqualToString:[storedStory objectForKey:@"category"]] && [[_story objectForKey:@"FeedId"] isEqualToString:[storedStory objectForKey:@"FeedId"]])
		{
			return;
		}
	}
	[faceBookQueue addObject:_story];
}

+ (void) PublishFaceBookQueue
{
	for (NSDictionary* storedStory in faceBookQueue)
	{
		[SocialManager shareFavoriteStoryWithFaceBook:storedStory];
	}
	[faceBookQueue removeAllObjects];
}

static NSMutableArray* twitterQueue;

+ (void) addStoryIntoTwitterQueue:(NSDictionary*)_story
{
	for (NSDictionary* storedStory in twitterQueue)
	{
		if([[_story objectForKey:@"category"] isEqualToString:[storedStory objectForKey:@"category"]] && [[_story objectForKey:@"FeedId"] isEqualToString:[storedStory objectForKey:@"FeedId"]])
		{
			return;
		}
	}
	
	[twitterQueue addObject:_story];
}

+ (void) PublishTwitterQueue
{
	for (NSDictionary* storedStory in twitterQueue)
	{
		[SocialManager shareFavoriteStoryWithTwitter:storedStory];
	}
	[twitterQueue removeAllObjects];
}


#pragma mark StoreAndRestore
+ (void)	restoreSocialManager
{
	categories = [[NSDictionary alloc] initWithContentsOfFile:CategoriesAndSubCategoriesFilePath];
	CategoriesAndSubCategories_ID_Mapping = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CategoriesAndSubCategories_ID_Mapping.plist"]];
	
	NSDictionary* preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath];
	
	if([preferences objectForKey:@"publishFavoritesToTwitter"])
	{	
		mobileNotifications        = [[preferences objectForKey:@"mobileNotifications"]  boolValue];
		isTwitterLogedIn           = [[preferences objectForKey:@"isTwitterLogedIn"]  boolValue];
		publishFavoritesToTwitter  = [[preferences objectForKey:@"publishFavoritesToTwitter"]  boolValue];
		publishFavoritesToFaceBook = [[preferences objectForKey:@"publishFavoritesToFaceBook"] boolValue];
	}
	else 
	{
		mobileNotifications        = YES;
		publishFavoritesToTwitter  = YES;
		publishFavoritesToFaceBook = YES;
	}
	
	lastReceivedFeeds = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"lastReceivedFeeds"]];
	storedFeeds = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"storedFeeds"]];
	feedsStatus = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"feedsStatus"]];

	storedIssues = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"storedIssues"]];
	issuesStatus = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"issuesStatus"]];
	
	storedEvents = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"storedEvents"]];
	eventsStatus = [[NSMutableDictionary alloc] initWithDictionary:[preferences objectForKey:@"eventsStatus"]];
	
	favoriteCandidates  = [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"favoriteCandidates"]];
	favoritePublishers  = [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"favoritePublishers"]];
	favoriteStories     = [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"favoriteStories"]];
	favoriteIssues		= [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"favoriteIssues"]];
	favoriteEvents		= [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"favoriteEvents"]];
	
	faceBookQueue		= [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"faceBookQueue"]];
	twitterQueue		= [[NSMutableArray alloc] initWithArray: [preferences objectForKey:@"twitterQueue"]];
	
	[JSONServiceCaller initializeSharedJSONServiceCaller];
}

+ (void)	saveSocialManager
{	
	NSDictionary* preferences = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:mobileNotifications],[NSNumber numberWithBool:isTwitterLogedIn],[NSNumber numberWithBool:publishFavoritesToTwitter],[NSNumber numberWithBool:publishFavoritesToFaceBook],lastReceivedFeeds,storedFeeds,feedsStatus,storedIssues,issuesStatus,storedEvents,eventsStatus,favoriteCandidates,favoritePublishers,favoriteStories,favoriteIssues,favoriteEvents,faceBookQueue,twitterQueue,nil] forKeys:[NSArray arrayWithObjects:@"mobileNotifications",@"isTwitterLogedIn",@"publishFavoritesToTwitter",@"publishFavoritesToFaceBook",@"lastReceivedFeeds",@"storedFeeds",@"feedsStatus",@"storedIssues",@"issuesStatus",@"storedEvents",@"eventsStatus",@"favoriteCandidates",@"favoritePublishers",@"favoriteStories",@"favoriteIssues",@"favoriteEvents",@"faceBookQueue",@"twitterQueue",nil]];
	
	[preferences writeToFile:preferencesFilePath atomically:YES];
	
	[SocialViewController release];
	[sharedTwitterEngine release];
	[categories   release];
	[CategoriesAndSubCategories_ID_Mapping release];
	[storedFeeds  release];
	[feedsStatus  release];
	[storedIssues release];
	[issuesStatus release];
	[storedEvents release];
	[eventsStatus release];
	
	[favoriteCandidates  release];
	[favoritePublishers  release];
	[favoriteStories	 release];
	[favoriteIssues		 release];
	[favoriteEvents		 release];
	
	[faceBookQueue release];
	[twitterQueue release];
	
	[JSONServiceCaller disableSharedJSONServiceCaller];
}

/*
#pragma mark Analytic Methods

#define analyticsUrl @"http://www.gripwire.com/iphone_analytics/?appId=%@&deviceId=%@&tag=%@&version=%f&model=%@&device=%@"

+ (void)doAnalytics:(NSString*)analyticsURLString
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[analyticsURLString  stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]] returningResponse:nil error:nil];
	[pool drain];
	[pool release];
}

+ (void)sendAnalyticsTag:(NSString*)tag metadata:(NSDictionary*)metadata blocking:(BOOL)blocking
{
	NSString* appId    = [[NSBundle mainBundle] bundleIdentifier];
	NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
	float     version  = [[[UIDevice currentDevice] systemVersion] floatValue];
	NSString* model    = [[UIDevice currentDevice] model];
	
	struct utsname u;
	uname(&u);
	NSString *nameString = [NSString stringWithFormat:@"%s", u.machine];
	
	NSMutableString* urlString = [NSMutableString stringWithFormat:analyticsUrl, appId, deviceId, tag, version, model, nameString];
	if(metadata)
	{
		NSEnumerator* keyEnumerator = [metadata keyEnumerator];
		for(NSString* key in keyEnumerator)
		{
			[urlString appendFormat:@"&%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[metadata objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	if(blocking)
		[self doAnalytics:urlString];
	else
		[NSThread detachNewThreadSelector:@selector(doAnalytics:) toTarget:self withObject:urlString];
}
*/


@end
