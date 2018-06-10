//
//  DrawRectangleView.h
//  LifePath
//
//  Created by Justin on 6/14/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawRectangleView;

@protocol DrawRectangleDelegate

- (void)drawRectangleView:(DrawRectangleView*)drv finishedRect:(CGRect)rect;

@end


@interface DrawRectangleView : UIView
{
	CGPoint		boxOrigin;
	CGPoint		boxEnd;
	
	id<DrawRectangleDelegate>	delegate;
}

@property (nonatomic) CGRect rectangle;
@property (nonatomic, assign) id<DrawRectangleDelegate> delegate;

@end
