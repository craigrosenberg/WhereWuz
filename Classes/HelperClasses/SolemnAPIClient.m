//
//  SolemnAPIClient.m
//  LifePath
//
//  Created by Justin on 6/21/10.
//  Copyright 2010 Gripwire, Inc. All rights reserved.
//

#import "SolemnAPIClient.h"
#import "CJSONDeserializer.h"
#import "ASIFormDataRequest.h"

#import "LifePath.h"

static NSString* formatStr = @"?method=%@";

@implementation SolemnAPIClient

- (id)initWithTarget:(NSString*)tgt
{
	if(self = [super init])
	{
		self.target = tgt;
	}
	
	return self;
}

- (NSString*)target
{
	return target;
}

- (void)setTarget:(NSString*)tgt
{
	if(tgt != target)
	{
		[target release];
		target = [[tgt stringByAppendingString:formatStr] retain];
	}
}

- (NSDictionary*)call:(NSString*)method error:(NSError**)_error
{
	return [self call:method args:nil error:_error];
}

- (NSDictionary*)call:(NSString*)method args:(NSDictionary*)args error:(NSError**)_error
{
	return [self call:method args:args files:nil error:_error];
}

- (NSDictionary*)call:(NSString*)method args:(NSDictionary*)args files:(NSDictionary*)files error:(NSError**)_error
{
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:target, method]];

	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:20];

	if(args)
	{
		for(id<NSObject> key in args)
		{
			NSString* resolvedKey = [NSString stringWithFormat:@"args[%@]", key];
			id<NSObject> value = [args objectForKey:key];
			
			[request setPostValue:value forKey:resolvedKey];
		}
	}
	
	if(files)
	{
		for(NSString* key in files)
		{
			NSDictionary* file = [files objectForKey:key];
			
			[request setData:[file objectForKey:@"data"]
				withFileName:[file objectForKey:@"filename"]
			  andContentType:[file objectForKey:@"content-type"]
					  forKey:key];
		}
	}
	
	NSLog(@"API Call: %@", request.url);
	NSLog(@"Arguments: %@", [args allKeys]);

	[[LifePath stopwatch] start];
	[[LifePath stopwatch] startMark:@"request"];
	[request startSynchronous];
	[[LifePath stopwatch] endMark:@"request"];
	
	[[LifePath stopwatch] startMark:@"parse"];
	NSString* response = [request responseString];
	NSData* jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSDictionary* resultDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
	[[LifePath stopwatch] endMark:@"parse"];
	
	int resultCode = [[[resultDict objectForKey:@"Result"] objectForKey:@"Code"] intValue];
	if(resultCode > 0)
	{
		return resultDict;
	}
	else
	{
		NSDictionary* info = nil;
		NSString* message = [[resultDict objectForKey:@"Result"] objectForKey:@"Message"];
		if(message)
			info = [NSDictionary dictionaryWithObject:message forKey:@"message"];
		
		*_error = [NSError errorWithDomain:@"solemnAPI" code:resultCode userInfo:info];
		
		return nil;
	}
}

- (NSThread*)callAsync:(NSString*)method withReceiver:(id<SolemnAPIReceiver>)rcvr
{
	NSDictionary* callArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							  method, @"method",
							  rcvr, @"receiver", nil];
	
	NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(asynchronousCall:) object:callArgs];
	[thread start];
	
	return [thread autorelease];
}

- (NSThread*)callAsync:(NSString*)method args:(NSDictionary*)args withReceiver:(id<SolemnAPIReceiver>)rcvr
{
	NSDictionary* callArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							  method, @"method",
							  args, @"args",
							  rcvr, @"receiver", nil];
	
	NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(asynchronousCall:) object:callArgs];
	[thread start];
	
	return [thread autorelease];
}

- (NSThread*)callAsync:(NSString*)method args:(NSDictionary*)args files:(NSDictionary*)files withReceiver:(id<SolemnAPIReceiver>)rcvr
{
	NSDictionary* callArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							  method, @"method",
							  args, @"args",
							  files, @"files",
							  rcvr, @"receiver", nil];
	
	NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(asynchronousCall:) object:callArgs];
	[thread start];
	
	return [thread autorelease];
}

- (void)asynchronousCall:(NSDictionary*)callObjects
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* method = [callObjects objectForKey:@"method"];
	NSDictionary* args = [callObjects objectForKey:@"args"];
	NSDictionary* files = [callObjects objectForKey:@"files"]; 
	id<SolemnAPIReceiver> receiver = [callObjects objectForKey:@"receiver"];
	
	NSError* error = nil;
	NSDictionary* result = [self call:method args:args files:files error:&error];
	
	if([[NSThread currentThread] isCancelled] == NO)
	{
		if(result)
		{
			[self performSelectorOnMainThread:@selector(returnSuccess:) 
								   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
											   receiver, @"receiver",
											   method, @"method",
											   result, @"result", nil]
								waitUntilDone:NO];
		}
		else
		{
			[self performSelectorOnMainThread:@selector(returnError:)
								   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
											   receiver, @"receiver",
											   method, @"method",
											   error, @"error", nil]
								waitUntilDone:NO];
		}
	}
	
	[pool drain];
}

- (void)returnSuccess:(NSDictionary*)args
{
	id<SolemnAPIReceiver> receiver = [args objectForKey:@"receiver"];
	NSString* method = [args objectForKey:@"method"];
	NSDictionary* result = [args objectForKey:@"result"];
	
	[receiver call:method finishedWithResult:result];
}

- (void)returnError:(NSDictionary*)args
{
	id<SolemnAPIReceiver> receiver = [args objectForKey:@"receiver"];
	NSString* method = [args objectForKey:@"method"];
	NSError* error = [args objectForKey:@"error"];
	
	[receiver call:method finishedWithError:error];	
}

@end
