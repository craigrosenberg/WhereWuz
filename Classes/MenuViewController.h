//
//  MenuViewController.h
//  LifePath
//
//  Created by Justin on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuViewController : UITableViewController
{
	NSMutableArray*		tableArray;
}

- (id)initWithTitle:(NSString*)title items:(NSDictionary*)items arrangement:(NSArray*)tableArrangement;

@end
