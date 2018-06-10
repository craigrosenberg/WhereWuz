//
//  LoadingView.h
//  LifePath
//
//  Created by Justin on 7/2/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DialogView;

@interface LoadingView : UIView
{
	UILabel*		loadingLabel;
	DialogView*		dialog;
}

@property (nonatomic, readonly) UILabel* loadingLabel;

@end
