//
//  StatusBar.m
//  DangerZones
//
//  Created by Justin on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatusBar.h"


@implementation StatusBar

@synthesize statusLabel, autoHide, offScreen, tickerTimer;

- (void)repositionStatusLabel
{	
	CGRect statusFrame = self.bounds;

	statusFrame.origin = CGPointMake(activityIndicator.frame.size.width + 5.0, 0.0);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.0];
	statusLabel.frame = statusFrame;
	[UIView commitAnimations];
}

- (void)setTickerMessages:(NSArray*)messages
{
	// Release old messages
	[tickerMessages release];
	tickerMessages = nil;
	
	if(messages)
	{
		// New mutable array to hold the shuffled messages
		NSMutableArray* mutableMessages = [[NSMutableArray alloc] initWithCapacity:messages.count];
		
		// Create a mutable copy of the passed messages
		NSMutableArray* copy = [messages mutableCopy];
		
		// Loop through the copy and remove in random order and add to ticker array
		while(copy.count > 0)
		{
			int index = arc4random() % copy.count;
			id objectToMove = [copy objectAtIndex:index];
			
			[mutableMessages addObject:objectToMove];
			[copy removeObjectAtIndex:index];
		}
		
		// Release our copy
		[copy release];
		
		// Assign newly filled array
		tickerMessages = mutableMessages;
		
		// Reset the ticker index
		tickerIndex = 0;
	}
}

- (NSArray*)tickerMessages
{
	return tickerMessages;
}

- (void)updateTicker:(NSTimer*)timer
{
	if(offScreen && tickerMessages.count > 0)
	{
		[self setStatus:[tickerMessages objectAtIndex:tickerIndex++] animated:YES];
		tickerDisplayed = YES;
		
		// Animate the status message off screen
		CGRect frame = statusLabel.frame;
		float width = frame.size.width;
		frame.origin.x = -width;
		float animationLength = 0.02 * (statusLabel.frame.origin.x - frame.origin.x);

		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelay:3.0];
		[UIView setAnimationDuration:animationLength];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(tickerAnimationStopped)];
		statusLabel.frame = frame;
		[UIView commitAnimations];
		
		if(tickerIndex == tickerMessages.count)
			tickerIndex = 0;
	}
}

- (void)tickerAnimationStopped
{
	if(tickerDisplayed)
		self.status = @"";
}

- (void)checkHidden
{
	if(autoHide)
	{
		if(statusLabel.text.length == 0)
			[self hideBar];
		else
			[self unhideBar];
	}		
}
			
- (void)hideBar
{
	if([NSThread isMainThread] == NO)
	{
		[self performSelectorOnMainThread:@selector(hideBar) withObject:nil waitUntilDone:YES];
		return;
	}
	
	if(offScreen == NO)
	{
		offScreen = YES;
		savedFrame = self.frame;
		
		CGRect newFrame = savedFrame;
		newFrame.origin.y = -newFrame.size.height;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		self.frame = newFrame;
		[UIView commitAnimations];		
	}
}
			
- (void)unhideBar
{
	if([NSThread isMainThread] == NO)
	{
		[self performSelectorOnMainThread:@selector(unhideBar) withObject:nil waitUntilDone:YES];
		return;
	}
	
	if(offScreen == YES)
	{
		offScreen = NO;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		self.frame = savedFrame;
		[UIView commitAnimations];		
	}
}

- (NSString*)status
{
	return statusLabel.text;
}

- (void)setStatus:(NSString*)status
{	
	[self setStatus:status animated:NO];
}

- (void) setStatusNotAnimated:(NSString*)status
{	
	[self repositionStatusLabel];
	
	statusLabel.text = status;
	
	// Let the label be as wide as it wants, but retain its height
	CGRect frame = statusLabel.frame;
	frame.size.width = [statusLabel.text sizeWithFont:statusLabel.font].width;
	statusLabel.frame = frame;
	
	[self checkHidden];
}
		 
- (void)setStatusAnimated:(NSString*)status
{
	// Fade out current message if there is one
	if(statusLabel.text.length > 0)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		statusLabel.alpha = 0.0;
		[UIView commitAnimations];
	}
	
	[self setStatusNotAnimated:status];
	
	// Fade new text in
	if(status.length > 0)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		statusLabel.alpha = 1.0;
		[UIView commitAnimations];
	}
}

- (void)setStatus:(NSString*)status animated:(BOOL)animated
{
	// Do nothing if message is already the same
	if([status isEqualToString:self.status])
		return;

	tickerDisplayed = NO;
	
	if([NSThread isMainThread] == NO)
	{
		if(animated)
			[self performSelectorOnMainThread:@selector(setStatusAnimated:) withObject:status waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(setStatusNotAnimated:) withObject:status waitUntilDone:YES];
	}
	else
	{
		if(animated)
			[self setStatusAnimated:status];
		else
			[self setStatusNotAnimated:status];
	}
}

- (BOOL)showsBusy
{
	return activityIndicator.isAnimating;
}

- (void)setShowsBusy:(BOOL)busy
{
	if([NSThread isMainThread] == NO)
	{
		if(busy)
			[self performSelectorOnMainThread:@selector(turnBusyOn) withObject:nil waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(turnBusyOff) withObject:nil waitUntilDone:YES];
		
		return;
	}
	
	if(busy)
		[activityIndicator startAnimating];
	else
		[activityIndicator stopAnimating];
	
	[self checkHidden];
}

- (void)turnBusyOn
{
	[activityIndicator startAnimating];
}

- (void)turnBusyOff
{
	[activityIndicator stopAnimating];
}
	


- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
	{
 		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
		
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.hidesWhenStopped = YES;
		[activityIndicator sizeToFit];
		
		CGRect activityFrame = activityIndicator.frame;
		activityFrame.origin.x = 2.0;
		activityFrame.origin.y = (self.bounds.size.height / 2) - (activityIndicator.bounds.size.height / 2);
		activityIndicator.frame = activityFrame;
		
		[self addSubview:activityIndicator];
		[activityIndicator release];
		
		statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textColor = [UIColor whiteColor];
		statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
		[self repositionStatusLabel];

		[self addSubview:statusLabel];
		[statusLabel release];
		
		autoHide = YES;
		offScreen = NO;
		
		tickerMessages = nil;
		
		self.tickerTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
															target:self
														  selector:@selector(updateTicker:)
														  userInfo:nil
														   repeats:YES];
    }
	
    return self;
}

- (void)dealloc
{	
	[tickerTimer invalidate];
	self.tickerTimer = nil;
	
	self.tickerMessages = nil;
	
    [super dealloc];
}


@end
