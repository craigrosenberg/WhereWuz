//
//  WhereResultsViewController.h
//  LifePath
//
//  Created by Justin on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RouteViewController.h"
#import "SolemnAPIClient.h"

@interface WhereResultsViewController : RouteViewController <SolemnAPIReceiver, UIActionSheetDelegate>
{
	LoadingView*	shareLoadingView;
	int				sharingAction;
	
	UIBarButtonItem* accuracyButton;
}

@end
