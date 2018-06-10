//
//  WhereEndViewController.h
//  LifePath
//
//  Created by Justin on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "LifePath.h"

@interface WhereEndViewController : UIViewController <SolemnAPIReceiver>
{
	NSDate*					startDate;
	IBOutlet UILabel*		startTimeLabel;
	IBOutlet UIDatePicker*	endTimePicker;
	
	LoadingView*			loadingView;
}

@property (nonatomic, retain) NSDate* startDate;

- (id)initWithStartDate:(NSDate*)date;
- (IBAction)searchPressed:(UIButton*)button;

@end
