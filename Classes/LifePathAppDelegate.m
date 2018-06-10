//
//  LifePathAppDelegate.m
//  LifePath
//
//  Created by Justin on 5/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LifePathAppDelegate.h"
#import "LifePath.h"
#import "FirstRunViewController.h"
#import "TrackingViewController.h"
#import "WhereStartViewController.h"
#import "WhenViewController.h"
#import "PreferencesViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "SocialManager.h"
#import "SocialViewController.h"

#import "Analytics.h"
#import "SocialManager.h"

@implementation LifePathAppDelegate

@synthesize window;

- (UINavigationController*)ncForVC:(UIViewController*)vc
{
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	nav.navigationBar.barStyle = UIBarStyleBlack;
	nav.toolbar.barStyle = UIBarStyleBlackTranslucent;

	return nav;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	// Query the shared LifePath singleton to instantiate it with the launch of the app
	[LifePath shared];
	[SocialManager restoreSocialManager];
	

	/*
	SocialViewController* socialViewController = [[SocialViewController alloc] init];
	[socialViewController loadView];
	[SocialManager setSocialViewController:socialViewController];
	[socialViewController release];	 
	*/
	
	[Analytics sendAnalyticsTag:@"appLaunched" metadata:nil blocking:NO];
	
	UIViewController* trackingVC = [[[TrackingViewController alloc] init] autorelease];
	UIViewController* whereVC = [[[WhereStartViewController alloc] init] autorelease];
	UIViewController* whenVC = [[[WhenViewController alloc] init] autorelease];
	UIViewController* favesVC = [[[FavoritesViewController alloc] init] autorelease];	
	UIViewController* prefsVC = [[[PreferencesViewController alloc] init] autorelease];
	UIViewController* aboutVC = [[[AboutViewController alloc] init] autorelease];
	
/*
 SocialViewController* socVC = [[SocialViewController alloc] init];
	[socVC loadView];
	[SocialManager setSocialViewController:socVC];
	[socVC autorelease];
*/
	
	tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = [NSArray arrayWithObjects:
										[self ncForVC:trackingVC],
										[self ncForVC:whereVC],
										[self ncForVC:whenVC],
										[self ncForVC:favesVC],
										[self ncForVC:prefsVC],
										[self ncForVC:aboutVC],
//										[self ncForVC:socVC],
										nil];
	
	tabBarController.customizableViewControllers = nil;
	tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
    //[window addSubview:tabBarController.view];
    [window setRootViewController: tabBarController];
    [window makeKeyAndVisible];
	
	if([LifePath preferences].firstRunCompleted == NO)
	{
		FirstRunViewController* firstTime = [[FirstRunViewController alloc] init];
		firstTime.parentVC = tabBarController;
		
		[tabBarController presentModalViewController:firstTime animated:YES];
		
		[firstTime release];
	}
		
	// Grab the number of records on the device
	NSUInteger numRecords = [[LifePath data] getRecordCount];
	NSLog(@"%d records in sqlite db.", numRecords);
	
	// Get device revision
	NSString* version = [[UIDevice currentDevice] systemVersion];
	NSArray* revisionNumbers = [version componentsSeparatedByString:@"."];
	
	// Disable idle timer if we're not on iOS 4
	if([[revisionNumbers objectAtIndex:0] intValue] < 4)
		application.idleTimerDisabled = YES;
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[LifePath preferences].firstRunCompleted = YES;
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	[Analytics sendAnalyticsTag:@"appTerminated" metadata:nil blocking:YES];
	[LifePath preferences].firstRunCompleted = YES;
	[SocialManager saveSocialManager];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[Analytics sendAnalyticsTag:@"memoryWarning" metadata:nil blocking:NO];
	NSLog(@"Received memory warning, popping all view controllers (except current).");
	
	UINavigationController* selectedVC = (UINavigationController*)tabBarController.selectedViewController;
	for(UINavigationController* vc in tabBarController.viewControllers)
	{
		if(vc != selectedVC)
			[vc popToRootViewControllerAnimated:NO];
	}
}

- (void)dealloc
{
	[tabBarController release];
    self.window = nil;
    [super dealloc];
}


@end
