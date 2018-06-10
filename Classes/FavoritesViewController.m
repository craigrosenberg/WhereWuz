//
//  FavoritesViewController.m
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PathDetailViewController.h"

#import "LifePath.h"
#import "Path.h"
#import "Analytics.h"

@implementation FavoritesViewController


#pragma mark -
#pragma mark Initialization

- (id)init
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = @"Favorites";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0] autorelease];
	}
	
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{	
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	
	resultsController = [[[LifePath data] resultsControllerForPaths] retain];
	resultsController.delegate = self;
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSError* error = nil;
	if([resultsController performFetch:&error] == NO)
		NSLog(@"Unable to retrieve stored paths: %@", error);
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[LifePath data] save];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return resultsController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[resultsController.sections objectAtIndex:section] numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Path* path = [resultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = path.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[[LifePath data] deletePath:[resultsController objectAtIndexPath:indexPath]];
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{
	Path* path = [resultsController objectAtIndexPath:indexPath];
	
	// Convert the path points to locations
	PathDetailViewController* pvc = [[PathDetailViewController alloc] initWithUserPath:path];
	[self.navigationController pushViewController:pvc animated:YES];
	
	[pvc release];
}

#pragma mark -
#pragma mark NSFetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	NSLog(@"controller will change content");
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
	NSLog(@"controller did change content");
	[self.tableView endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;

			/*
		case NSFetchedResultsChangeUpdate:
			//			[self configureCell:(RecipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			 */
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			// Reloading the section inserts a new row and ensures that titles are updated appropriately.
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	[resultsController release];
    [super dealloc];
}


@end

