    //
//  AboutViewController.m
//  LifePath
//
//  Created by Justin on 7/1/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

- (id)init
{
	if(self = [super init])
	{
		self.title = @"About";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		self.tabBarItem.image = [UIImage imageNamed:@"people.png"];
	}
	
	return self;
}

- (void)loadView
{
	[super loadView];
	
	UITextView* about = [[[UITextView alloc] initWithFrame:self.view.bounds] autorelease];
	[self.view addSubview:about];
	
	about.editable = NO;
	about.font = [UIFont fontWithName:@"Arial" size:14.0];
	about.text = @"WhereWuz was developed by Sunny Day Software, an engineering services company that is creating a suite of innovative GPS enabled applications for the mobile market.\n\nWhereWuz leverages the power of one’s path history to allow users to know exactly when they were at any given location and to know precisely where they were at any given time.  Sunny Day Software has a over twenty years of experience in providing exceptional software and engineering services in the areas of systems engineering and software development for the entertainment, telecommunications, and aerospace industries.";
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    [super dealloc];
}


@end
