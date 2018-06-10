//
//  SolemnAPIClient.h
//  LifePath
//
//  Created by Justin on 6/21/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SolemnAPIReceiver

- (void)call:(NSString*)method finishedWithResult:(NSDictionary*)result;
- (void)call:(NSString*)method finishedWithError:(NSError*)error;

@end


@interface SolemnAPIClient : NSObject
{
	NSString*		target;
}

@property (nonatomic, copy) NSString* target;

- (id)initWithTarget:(NSString *)tgt;

- (NSDictionary*)call:(NSString*)method error:(NSError**)_error;
- (NSDictionary*)call:(NSString*)method args:(NSDictionary*)args error:(NSError**)_error;
- (NSDictionary*)call:(NSString*)method args:(NSDictionary*)args files:(NSDictionary*)files error:(NSError**)_error;

- (NSThread*)callAsync:(NSString*)method withReceiver:(id<SolemnAPIReceiver>)rcvr;
- (NSThread*)callAsync:(NSString*)method args:(NSDictionary*)args withReceiver:(id<SolemnAPIReceiver>)rcvr;
- (NSThread*)callAsync:(NSString*)method args:(NSDictionary*)args files:(NSDictionary*)files withReceiver:(id<SolemnAPIReceiver>)rcvr;

@end
