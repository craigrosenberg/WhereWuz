//
//  Path.h
//  LifePath
//
//  Created by Justin on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PathPoint;

@interface Path :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet* points;

@end


@interface Path (CoreDataGeneratedAccessors)
- (void)addPointsObject:(PathPoint *)value;
- (void)removePointsObject:(PathPoint *)value;
- (void)addPoints:(NSSet *)value;
- (void)removePoints:(NSSet *)value;

@end

