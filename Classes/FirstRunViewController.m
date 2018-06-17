    //
//  FirstRunViewController.m
//  LifePath
//
//  Created by Justin on 7/9/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "FirstRunViewController.h"


@implementation FirstRunViewController

@synthesize parentVC;

- (id)init
{
    if ((self = [super initWithNibName:@"FirstRunView2" bundle:nil]))
	{
		
    }

    return self;
}

- (IBAction)dismissPressed:(id)sender
{
	[parentVC dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
