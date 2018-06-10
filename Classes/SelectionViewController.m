//
//  SelectionViewController.m
//  LifePath
//
//  Created by Justin on 6/11/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "SelectionViewController.h"


@implementation SelectionViewController

@synthesize items, selectedItem, delegate;

#pragma mark -
#pragma mark Initialization

- (id)initWithTitle:(NSString*)title items:(NSArray*)itemsArray
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = title;
		self.navigationItem.title = title;
		self.tabBarItem.title = title;

		self.items = itemsArray;
	}
	
	return self;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
	cell.textLabel.textColor = (selectedItem == indexPath.row) ? [UIColor blueColor] : [UIColor blackColor];
	cell.accessoryType = (selectedItem == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedItem = indexPath.row;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[tableView reloadData];
	
	[delegate selectionViewController:self selectedItemChanged:selectedItem];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	self.items = nil;
    [super dealloc];
}


@end

