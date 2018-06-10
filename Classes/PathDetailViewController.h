//
//  PathDetailViewController.h
//  LifePath
//
//  Created by Justin on 7/9/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Path.h"
#import "EditTableViewCell.h"

@interface PathDetailViewController : UITableViewController
{
	Path*					path;
	EditTableViewCell*		editCell;
	
	EditTableViewCell*		nameCell;
	EditTableViewCell*		notesCell;
}

@property (nonatomic, retain) Path* path;
@property (nonatomic, retain) IBOutlet EditTableViewCell* editCell;

- (id)initWithUserPath:(Path*)p;

@end
