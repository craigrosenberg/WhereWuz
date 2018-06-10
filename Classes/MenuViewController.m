//
//  MenuViewController.m
//  LifePath
//
//  Created by Justin on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController

- (void)configureItems:(NSDictionary*)items arrangement:(NSArray*)arrangement
{
	// Clear the current table array
	[tableArray removeAllObjects];
	
	// Create a new section (all configurations have at least 1 section)
	NSMutableArray* currentSection = [NSMutableArray array];
	[tableArray addObject:currentSection];
	
	// Run through the item list
	for(NSString* item in arrangement)
	{
		// The '|' starts a new section
		if([item isEqual:@"|"])
		{
			currentSection = [NSMutableArray array];
			[tableArray addObject:currentSection];
		}
		else
		{
			// Attempt to find the menu item and add it to the current section
			NSDictionary* menuItem = [items objectForKey:item];
			if(menuItem)
				[currentSection addObject:menuItem];
			else
				NSLog(@"Warning: unrecognized menu item: %@", item);
		}
	}
	
	// Instruct the table to reload its data
	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTitle:(NSString*)title items:(NSDictionary*)items arrangement:(NSArray*)tableArrangement
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = title;
		self.navigationItem.title = title;
		self.tabBarItem.title = title;
		
		tableArray = [[NSMutableArray alloc] init];
		[self configureItems:items arrangement:tableArrangement];
	}
	
	return self;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [tableArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[tableArray objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell;
	NSDictionary* menuItem = [[tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	if([menuItem objectForKey:@"subtitle"])
	{
		static NSString *CellIdentifier = @"subtitleCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; 
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
	}
	else
	{
		static NSString *CellIdentifier = @"Cell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}		
	}
	
	BOOL hasVC = [menuItem objectForKey:@"viewController"] != nil;
	
	cell.textLabel.text = [menuItem objectForKey:@"title"];
	cell.detailTextLabel.text = [menuItem objectForKey:@"subtitle"];
    cell.accessoryType = hasVC ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	cell.selectionStyle = hasVC ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary* menuItem = [[tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	UIViewController* viewController = [menuItem objectForKey:@"viewController"];
	
	if(viewController)
		[self.navigationController pushViewController:viewController animated:YES];
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
	[tableArray release];
	
    [super dealloc];
}


@end

