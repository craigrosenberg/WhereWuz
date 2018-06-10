//
//  LifePath.h
//  LifePath
//
//  Created by Justin on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LifePathPreferences.h"
#import "LifePathTracker.h"
#import "LifePathData.h"
#import "SolemnAPIClient.h"
#import "Stopwatch.h"

enum ShareAction
{
	kFacebookAction,
	kTwitterAction,
	kEmailAction,
	kNoAction
};

@interface LifePath : NSObject
{
	LifePathTracker*		tracker;
	LifePathPreferences*	preferences;
	LifePathData*			data;
	SolemnAPIClient*		apiClient;
	Stopwatch*				stopwatch;
}

+ (LifePath*)shared;
+ (LifePathTracker*)tracker;
+ (LifePathData*)data;
+ (LifePathPreferences*)preferences;
+ (SolemnAPIClient*)apiClient;
+ (Stopwatch*)stopwatch;

- (void)shareRoute:(int)shareAction 
			   url:(NSString*)shareURL
			 image:(UIImage*)routeImage
navigationController:(UINavigationController*)nc;

@end
