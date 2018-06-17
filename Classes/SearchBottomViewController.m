    //
//  SearchBottomViewController.m
//  LifePath
//
//  Created by Justin on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchBottomViewController.h"


@implementation SearchBottomViewController

@synthesize delegate, dateLabel, dateSlider;

- (id)init
{
	if(self = [super initWithNibName:@"SearchBottomView2" bundle:nil])
	{

	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)sliderChanged:(UISlider*)slider
{
	[delegate searchBottomView:self movedSlider:slider];
}

- (IBAction)prevPressed:(UIButton*)button
{
	[delegate searchBottomViewPressedPrevious:self];
}

- (IBAction)nextPressed:(UIButton*)button
{
	[delegate searchBottomViewPressedNext:self];
}

- (void)setCoordinate:(CLLocationCoordinate2D)coord
{
	coordinateLabel.text = [NSString stringWithFormat:@"Coordinate: %f, %f", coord.latitude, coord.longitude];
}

@end
