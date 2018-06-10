//
//  FavoritesViewController.h
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FavoritesViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController*		resultsController;
}

@end
