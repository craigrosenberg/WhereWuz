//
//  SocialManager.h
//  
//
//  Created by Robert Frederick
//  Copyright 2010 Gripwire.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import "MGTwitterEngine.h"
#import "JSONServiceCaller.h"
#import "SocialViewController.h"

@interface SocialManager : NSObject // <MGTwitterEngineDelegate> 
{
//	MGTwitterEngine* getSharedTwitterEngine;
}

#pragma mark Settings
+ (SocialViewController*) getSocialViewController;
+ (MGTwitterEngine*) getSharedTwitterEngine;

+ (void) setMobileNotifications:(BOOL)_mobileNotifications;
+ (BOOL) getMobileNotifications;
+ (void) setPublishFavoritesToFaceBook:(BOOL)_publishFavoritesToFaceBook;
+ (BOOL) getPublishFavoritesToFaceBook;
+ (void) setTwitterLogedIn:(BOOL)_isTwitterLogedIn;
+ (BOOL) getTwitterLogedIn;
+ (void) setPublishFavoritesToTwitter:(BOOL)_publishFavoritesToTwitter;
+ (BOOL) getPublishFavoritesToTwitter;
+ (void) setSocialViewController:(SocialViewController*)_socialViewController;


#pragma mark Publish Permissions

+ (BOOL) canPublishFavoritesToFaceBook;
+ (BOOL) canPublishFavoritesToTwitter;

#pragma mark Favorite Candidate Methods

+ (NSMutableArray*) favoriteCandidates;
+ (int)  availableFavoriteCandidates;
//+ (void) addFavoriteCandidate:(NSDictionary*)favoriteCandidate;
+ (void) removeFavoriteCandidateAtIndex:(int)atIndex;

#pragma mark Share With FaceBook And Twitter

+ (void) shareFavoriteStoryWithFaceBook:(NSDictionary*)favoriteStory;
+ (void) shareFavoriteStoryWithTwitter:(NSDictionary*)favoriteStory;

#pragma mark FaceBook And Twitter Queues

+ (void) addStoryIntoFaceBookQueue:(NSDictionary*)_story;
+ (void) addFavoriteStory:(NSDictionary*)favoriteStory;
+ (void) PublishFaceBookQueue;

+ (void) addStoryIntoTwitterQueue:(NSDictionary*)_story;
+ (void) PublishTwitterQueue;
+ (void) addFavoriteZone;

#pragma mark Persistence Methods
+ (void)		  restoreSocialManager;
+ (void)		  saveSocialManager;

@end




