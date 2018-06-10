//
//  LifePathAppDelegate.h
//  LifePath
//
//  Created by Justin on 5/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrackingViewController;

@interface LifePathAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow*				window;
	UITabBarController*		tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

