//
//  LifePathData.h
//  LifePath
//
//  Created by Justin on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "TrackingPoint.h"
#import "Path.h"
#import "PathPoint.h"

@interface LifePathData : NSObject
{
@private
	NSPersistentStoreCoordinator*	persistentStoreCoordinator;
	NSManagedObjectModel*			managedObjectModel;
	NSManagedObjectContext*			managedObjectContext;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

- (TrackingPoint*)insertNewPoint:(CLLocation*)location;
- (void)deletePoint:(TrackingPoint*)point;
- (void)clearAllPoints;
- (void)save;

// Gets the last recorded point in the database
- (TrackingPoint*)retrieveMostRecentPoint;

// Get the last 10 recorded points
- (NSArray*)retrieveRecentPoints;

// Get all points recorded in the last 24h
- (NSArray*)retrievePointsFromLast24h;

// Get all points that haven't been uploaded to the server
- (NSArray*)retrieveUnsynchronizedPoints;

// Retrieve a list of stored paths
- (NSArray*)retrieveStoredPaths;

// WhereWuz Query
- (NSArray*)whereWuzStart:(NSDate*)start end:(NSDate*)end;

// WhereWuz Query
- (NSArray*)whenWuzOrigin:(CLLocationCoordinate2D)origin extent:(CLLocationCoordinate2D)extent;

// Results 
- (NSFetchedResultsController*)resultsControllerForPaths;

// Save a new path to the database (takes CLLocation objects)
- (void)saveNewPath:(NSArray*)locations;

// Remove a path from the database
- (void)deletePath:(Path*)path;

// Get the total number of recorded points in the local DB
- (NSUInteger)getRecordCount;

// Helper methods to convert tracking points into CLLocations
- (CLLocation*)convertTrackingPointToLocation:(TrackingPoint*)point;
- (NSArray*)convertTrackingPointsToLocations:(NSArray*)trackingPoints;

- (NSArray*)convertPathToLocations:(Path*)path;

// Maintenance
- (void)performMaintenance;

@end
