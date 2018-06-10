//
//  PreferencesViewController.h
//  LifePath
//
//  Created by Justin on 5/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectionViewController.h"
#import "LifePath.h"

@class LoadingView;

@interface PreferencesViewController : UITableViewController <SelectionViewControllerDelegate, UIAlertViewDelegate, SolemnAPIReceiver>
{
	LoadingView* loadingView;
}

@end
