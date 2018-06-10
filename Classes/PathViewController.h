//
//  PathViewController.h
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteViewController.h"
#import "SolemnAPIClient.h"

@class LoadingView;

@interface PathViewController : RouteViewController <SolemnAPIReceiver, UIActionSheetDelegate>
{
	LoadingView*	shareLoadingView;
	int				sharingAction;
}

- (id)initWithRoute:(NSArray*)route;

@end
