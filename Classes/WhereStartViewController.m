    //
//  WhereStartViewController.m
//  LifePath
//
//  Created by Justin on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WhereStartViewController.h"
#import "WhereEndViewController.h"

@implementation WhereStartViewController

- (id)init
{
	if(self = [super initWithNibName:@"WhereStart" bundle:nil])
	{
		self.title = @"Where Wuz";
		self.navigationItem.title = self.title;
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start Time" style:UIBarButtonItemStylePlain target:nil action:nil];
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"where_was_i_query_alpha_no_invert.png"];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	startTimePicker.date = [NSDate dateWithTimeIntervalSinceNow:-(60.0f * 60 * 24)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	startTimePicker.maximumDate = [NSDate date];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (IBAction)continuePressed:(id)sender
{	
	WhereEndViewController* endVC = [[WhereEndViewController alloc] initWithStartDate:startTimePicker.date];
	[self.navigationController pushViewController:endVC animated:YES];
	[endVC release];
}

- (void)dealloc
{	
    [super dealloc];
}


@end
