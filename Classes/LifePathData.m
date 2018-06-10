//
//  LPData.m
//  LifePath
//
//  Created by Justin on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LifePathData.h"
#import "Analytics.h"

@implementation LifePathData

- (NSManagedObjectContext*)managedObjectContext
{	
    if(managedObjectContext != nil)
        return managedObjectContext;
	
    NSPersistentStoreCoordinator* coordinator = self.persistentStoreCoordinator;
    if(coordinator != nil)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		managedObjectContext.persistentStoreCoordinator = coordinator;
    }
	
    return managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel
{	
    if(managedObjectModel != nil)
		return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{	
    if(persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSURL* storeUrl = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:@"LifePath.sqlite"]];
	
	NSError *error;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												 configuration:nil
														   URL:storeUrl 
													   options:options
														 error:&error])
	{
        NSLog(@"Couldn't add persistent store: %@", error);
    }    
	
    return persistentStoreCoordinator;
}

- (TrackingPoint*)insertNewPoint:(CLLocation*)location
{
	TrackingPoint* point = [NSEntityDescription insertNewObjectForEntityForName:@"TrackingPoint"
														 inManagedObjectContext:[self managedObjectContext]];
	
	point.timestamp = location.timestamp;
	point.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
	point.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
	point.speed = [NSNumber numberWithFloat:location.speed];
	point.bearing = [NSNumber numberWithFloat:location.course];
	point.altitude = [NSNumber numberWithFloat:location.altitude];
	
	return point;
}

- (void)deletePoint:(TrackingPoint*)point
{
	[[self managedObjectContext] deleteObject:point];
}

- (void)clearAllPoints
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"TrackingPoint" inManagedObjectContext:[self managedObjectContext]]];
	
	NSError* error = nil;
	NSArray* objects = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(objects)
	{
		for(NSManagedObject* object in objects)
			[managedObjectContext deleteObject:object];
		
		[managedObjectContext save:&error];
	}
}

- (void)save
{
	NSError* error = nil;
	[[self managedObjectContext] save:&error];
	
	if(error)
		NSLog(@"Error saving database: %@", error);
}

- (TrackingPoint*)retrieveMostRecentPoint
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setFetchLimit:1];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSSortDescriptor* sort = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
	[fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error fetching recent tracking points: %@", error);
	
	return [results lastObject];	
}

- (NSArray*)retrieveRecentPoints
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSSortDescriptor* sort = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
	[fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSDate* yesterday = [NSDate dateWithTimeIntervalSinceNow:-(60 * 60 * 12)];
	[fetch setPredicate:[NSPredicate predicateWithFormat:@"timestamp > %@", yesterday]];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	results = [[results reverseObjectEnumerator] allObjects];
	
	if(error)
		NSLog(@"Error fetching recent tracking points: %@", error);
	
	return results;
}

- (NSArray*)retrievePointsFromLast24h
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint" 
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSDate* yesterday = [NSDate dateWithTimeIntervalSinceNow:-(60 * 60 * 24)];
	[fetch setPredicate:[NSPredicate predicateWithFormat:@"timestamp > %@", yesterday]];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error fetching last 24h of points: %@", error);
	
	return results;	
}

// WhereWuz Query
- (NSArray*)whereWuzStart:(NSDate*)start end:(NSDate*)end
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSExpression* startExpr = [NSExpression expressionForConstantValue:start];
	NSExpression* endExpr = [NSExpression expressionForConstantValue:end];
	
	NSSortDescriptor* sort = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES] autorelease];
	[fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"timestamp BETWEEN %@", 
							  [NSArray arrayWithObjects:startExpr, endExpr, nil]];
	[fetch setPredicate:predicate];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error fetching WhereWuz points: %@", error);
	
	return results;
}

// WhereWuz Query
- (NSArray*)whenWuzOrigin:(CLLocationCoordinate2D)origin extent:(CLLocationCoordinate2D)extent
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSSortDescriptor* sort = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES] autorelease];
	[fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSExpression* latKey = [NSExpression expressionForKeyPath:@"latitude"];
	NSExpression* lngKey = [NSExpression expressionForKeyPath:@"longitude"];
	
	NSExpression* exLat = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:extent.latitude]];
	NSExpression* ogLat = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:origin.latitude]];
	NSExpression* exLng = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:extent.longitude]];
	NSExpression* ogLng = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:origin.longitude]];
	
	NSExpression* latExpr = [NSExpression expressionForAggregate:[NSArray arrayWithObjects:exLat,ogLat,nil]];
	NSExpression* lngExpr = [NSExpression expressionForAggregate:[NSArray arrayWithObjects:ogLng,exLng,nil]];	
	
	NSPredicate* latComp = [NSComparisonPredicate predicateWithLeftExpression:latKey
															  rightExpression:latExpr
																	 modifier:NSDirectPredicateModifier
																		 type:NSBetweenPredicateOperatorType
																	  options:0];

	NSPredicate* lngComp = [NSComparisonPredicate predicateWithLeftExpression:lngKey
															  rightExpression:lngExpr
																	 modifier:NSDirectPredicateModifier
																		 type:NSBetweenPredicateOperatorType
																	  options:0];
	
	NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
							  [NSArray arrayWithObjects:latComp, lngComp, nil]];
	
	[fetch setPredicate:predicate];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error fetching WhenWuz points: %@", error);
	
	return results;
}


// Results 
- (NSFetchedResultsController*)resultsControllerForPaths
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Path"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSSortDescriptor* sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[fetch setSortDescriptors:[NSArray arrayWithObject:sort]];

	NSFetchedResultsController* resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
																						managedObjectContext:[self managedObjectContext] 
																						  sectionNameKeyPath:nil
																								   cacheName:@"root"];
	
	return [resultsController autorelease];
	
}

// Retrieve a list of stored paths
- (NSArray*)retrieveStoredPaths
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Path"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSSortDescriptor* sort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error fetching stored paths: %@", error);
	
	return results;
}

// Save a new path to the database (takes NSDictionary objects)
- (void)saveNewPath:(NSArray*)points
{
	[Analytics sendAnalyticsTag:@"savedNewFavorite" metadata:nil blocking:NO];
	
	NSManagedObjectContext* moc = [self managedObjectContext];
	
	Path* path = [NSEntityDescription insertNewObjectForEntityForName:@"Path"
											   inManagedObjectContext:moc];
	
	NSMutableSet* pathPoints = [NSMutableSet setWithCapacity:points.count];
	for(TrackingPoint* point in points)
	{
		PathPoint* pathPoint = [NSEntityDescription insertNewObjectForEntityForName:@"PathPoint"
															 inManagedObjectContext:moc];
		[pathPoint setFromTrackingPoint:point];
		[pathPoints addObject:pathPoint];
	}
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	
	CLLocation* startLocation = [points objectAtIndex:0];
	NSDate* start = [startLocation timestamp];
	
	NSString* pathName = [NSString stringWithFormat:@"Starting %@", [formatter stringFromDate:start]];
	[formatter release];
	
	path.name = pathName;
	[path addPoints:pathPoints];
	[self save];
}

- (void)deletePath:(Path*)path
{
	[Analytics sendAnalyticsTag:@"deletedFavorite" metadata:nil blocking:NO];
	
	[[self managedObjectContext] deleteObject:path];
	[self save];
}

- (NSArray*)retrieveUnsynchronizedPoints
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint" 
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	[fetch setPredicate:[NSPredicate predicateWithFormat:@"synchronized == FALSE"]];
		
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error fetching unsynchronized points: %@", error);
	
	return results;
}

- (NSUInteger)getRecordCount
{
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint" 
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSError* error = nil;
	NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetch error:&error];
	if(error)
		NSLog(@"Error fetching record count: %@", error);

	return count;
}

- (CLLocation*)convertTrackingPointToLocation:(TrackingPoint*)point
{
	CLLocationCoordinate2D coord;
	coord.latitude = [point.latitude doubleValue];
	coord.longitude = [point.longitude doubleValue];

	return [[[CLLocation alloc] initWithCoordinate:coord
										  altitude:[point.altitude floatValue]
								horizontalAccuracy:0 
								  verticalAccuracy:0
										 timestamp:point.timestamp] autorelease];
}

- (NSArray*)convertTrackingPointsToLocations:(NSArray*)trackingPoints
{
	NSMutableArray* locations = [NSMutableArray arrayWithCapacity:trackingPoints.count];

	for(TrackingPoint* point in trackingPoints)
	{
		CLLocationCoordinate2D coord;
		coord.latitude = [point.latitude doubleValue];
		coord.longitude = [point.longitude doubleValue];
		
		CLLocation* location = [[[CLLocation alloc] initWithCoordinate:coord
															  altitude:[point.altitude floatValue]
													horizontalAccuracy:0 
													  verticalAccuracy:0
															 timestamp:point.timestamp] autorelease];
		[locations addObject:location];
	}
	
	return locations;
}

- (NSArray*)convertPathToLocations:(Path*)path
{
	NSMutableArray* locations = [NSMutableArray arrayWithCapacity:path.points.count];
	
	NSArray* points = path.points.allObjects;
	
	NSSortDescriptor* timestampDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES] autorelease];
	NSArray* sortedPoints = [points sortedArrayUsingDescriptors:[NSArray arrayWithObject:timestampDescriptor]];
			  
	for(PathPoint* point in sortedPoints)
	{
		CLLocationCoordinate2D coord;
		coord.latitude = [point.latitude doubleValue];
		coord.longitude = [point.longitude doubleValue];
		
		CLLocation* location = [[[CLLocation alloc] initWithCoordinate:coord
															  altitude:[point.altitude floatValue]
													horizontalAccuracy:0 
													  verticalAccuracy:0
															 timestamp:point.timestamp] autorelease];
		[locations addObject:location];
	}
	
	return locations;
}

- (void)performMaintenance
{
	// No longer deleting any points
	return;
	
	NSFetchRequest* fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"TrackingPoint"
											  inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entity];
	
	NSDate* yesterday = [NSDate dateWithTimeIntervalSinceNow:-(60.0f * 60 * 24)];
	[fetch setPredicate:[NSPredicate predicateWithFormat:@"(timestamp < %@) AND (synchronized == YES)", yesterday]];
	
	NSError* error = nil;
	NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	
	if(error)
		NSLog(@"Error performing maintenance: %@", error);
	else
	{
		NSManagedObjectContext* moc = [self managedObjectContext];
		
		for(NSManagedObject* object in results)
			[moc deleteObject:object];
		
		[self save];
		NSLog(@"Cleaned up %d records.", results.count);
	}
}

@end
