//
//  SearchBottomViewController.h
//  LifePath
//
//  Created by Justin on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SearchBottomViewController;

@protocol SearchBottomViewDelegate

- (void)searchBottomView:(SearchBottomViewController*)sbvc movedSlider:(UISlider*)slider;
- (void)searchBottomViewPressedPrevious:(SearchBottomViewController*)sbvc;
- (void)searchBottomViewPressedNext:(SearchBottomViewController*)sbvc;

@end


@interface SearchBottomViewController : UIViewController
{
	IBOutlet UILabel*				dateLabel;
	IBOutlet UISlider*				dateSlider;
	IBOutlet UILabel*				coordinateLabel;
	
	id<SearchBottomViewDelegate>	delegate;
}

@property (nonatomic, assign) id<SearchBottomViewDelegate> delegate;

@property (nonatomic, readonly) UILabel* dateLabel;
@property (nonatomic, readonly) UISlider* dateSlider;

- (IBAction)sliderChanged:(UISlider*)slider;
- (IBAction)prevPressed:(UIButton*)button;
- (IBAction)nextPressed:(UIButton*)button;

- (void)setCoordinate:(CLLocationCoordinate2D)coord;

@end
