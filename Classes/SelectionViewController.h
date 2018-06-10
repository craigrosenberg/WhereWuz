//
//  SelectionViewController.h
//  LifePath
//
//  Created by Justin on 6/11/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectionViewController;

@protocol SelectionViewControllerDelegate

- (void)selectionViewController:(SelectionViewController*)svc selectedItemChanged:(int)selectedItem;

@end



@interface SelectionViewController : UITableViewController
{
	NSArray*							items;
	int									selectedItem;
	id<SelectionViewControllerDelegate>	delegate;
}

@property (nonatomic, retain) NSArray* items;
@property (nonatomic) int selectedItem;
@property (nonatomic, assign) id<SelectionViewControllerDelegate> delegate;

- (id)initWithTitle:(NSString*)title items:(NSArray*)itemsArray;

@end
