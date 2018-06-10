//
//  FirstRunViewController.h
//  LifePath
//
//  Created by Justin on 7/9/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstRunViewController : UIViewController 
{
	UIViewController*	parentVC;
}

@property (nonatomic, assign) UIViewController* parentVC;

- (IBAction)dismissPressed:(id)sender;

@end
