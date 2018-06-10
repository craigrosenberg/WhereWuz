//
//  EditTableViewCell.m
//  LifePath
//
//  Created by Justin on 7/9/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "EditTableViewCell.h"


@implementation EditTableViewCell

@synthesize editLabel, editField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)dealloc 
{
    [super dealloc];
}


@end
