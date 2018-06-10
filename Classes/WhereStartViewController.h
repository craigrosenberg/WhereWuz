//
//  WhereStartViewController.h
//  LifePath
//
//  Created by Justin on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WhereStartViewController : UIViewController
{
	IBOutlet UIDatePicker*	startTimePicker;
}

- (IBAction)continuePressed:(id)sender;

@end
