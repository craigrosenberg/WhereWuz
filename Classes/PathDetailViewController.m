//
//  PathDetailViewController.m
//  LifePath
//
//  Created by Justin on 7/9/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "PathDetailViewController.h"
#import "PathViewController.h"
#import "LifePath.h"
#import "Analytics.h"

@implementation PathDetailViewController

@synthesize path, editCell;

#pragma mark -
#pragma mark Initialization

- (id)initWithUserPath:(Path*)p
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = @"Path Detail";
		self.navigationItem.title = self.title;
		self.tabBarItem.title = self.title;
		
		self.path = p;
	}
	
	return self;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewWillDisappear:(BOOL)animated
{
	path.name = nameCell.editField.text;
	path.notes = notesCell.editField.text;
	[[LifePath data] save];
	
	[super viewWillDisappear:animated];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
			return 2;
			
		case 1:
			return 1;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{   
	if(indexPath.section == 0)
	{
		static NSString *CellIdentifier = @"editingCell";
		EditTableViewCell* cell = (EditTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (!cell)
		{
			[[NSBundle mainBundle] loadNibNamed:@"EditCell" owner:self options:nil];
			cell = editCell;
			self.editCell = nil;
		}
		
		switch(indexPath.row)
		{
			case 0:
				cell.editLabel.text = @"Name";
				cell.editField.text = path.name;
				nameCell = cell;
				break;
				
			case 1:
				cell.editLabel.text = @"Note";
				cell.editField.text = path.notes;
				cell.editField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
				notesCell = cell;
				break;
		}
		
		return cell;		
	}
	else if(indexPath.section == 1)
	{
		static NSString *CellIdentifier = @"viewCell";
		UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if(!cell)
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		}
		
		cell.textLabel.text = @"View Path";
		
		return cell;
	}
	
	return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section > 0)
		return indexPath;
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section > 0)
	{	
		[Analytics sendAnalyticsTag:@"viewedFavorite" metadata:nil blocking:NO];
		
		//	Sort the points
		NSMutableArray* sortedPoints = [NSMutableArray arrayWithArray:[path.points allObjects]];
		[sortedPoints sortUsingSelector:@selector(compare:)];

		// Convert the path points to dictionaries
		NSMutableArray* locations = [NSMutableArray arrayWithCapacity:[sortedPoints count]];
		for(PathPoint* point in sortedPoints)
			[locations addObject:[point location]];
		
		PathViewController* pvc = [[PathViewController alloc] initWithRoute:locations];
		pvc.trackingPoints = sortedPoints;
		[self.navigationController pushViewController:pvc animated:YES];
		[pvc release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	self.path = nil;
    [super dealloc];
}


@end

