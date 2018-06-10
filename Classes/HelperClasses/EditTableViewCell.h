//
//  EditTableViewCell.h
//  LifePath
//
//  Created by Justin on 7/9/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditTableViewCell : UITableViewCell <UITextFieldDelegate>
{
	IBOutlet UILabel*		editLabel;
	IBOutlet UITextField*	editField;
}

@property (nonatomic, readonly) UILabel* editLabel;
@property (nonatomic, readonly) UITextField* editField;

@end
