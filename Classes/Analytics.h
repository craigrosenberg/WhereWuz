//
//  Analytics.h
//  DangerZones
//
//  Created by Justin on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Analytics : NSObject
{

}

+ (void)sendAnalyticsTag:(NSString*)tag metadata:(NSDictionary*)metadata blocking:(BOOL)blocking;

@end
