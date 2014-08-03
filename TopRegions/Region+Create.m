//
//  Region+Create.m
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/29/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "Region+Create.h"
#import "Photographer+Create.h"
#import "FlickrFetcher.h"
#import "Photo.h"

@implementation Region (Create)

// Adds a region to the database with the given photo
+ (void)addRegionForPhotoInfo:(NSDictionary *)photoDictionary
                    withPhoto:(Photo *)photo
     inNSManagedObjectContext:(NSManagedObjectContext *)context
{
    // Gets region name
    NSURL *photoInformationURL = [FlickrFetcher URLforInformationAboutPlace:[photoDictionary valueForKeyPath:FLICKR_PLACE_ID]];
    dispatch_queue_t regionQ = dispatch_queue_create("RegionQ", NULL);
    dispatch_async(regionQ, ^{
        NSData *jsonData = [NSData dataWithContentsOfURL:photoInformationURL];
        NSDictionary *photoPlaceDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:0
                                                                               error:NULL];
        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:photoPlaceDictionary];
        
        // Adds region in database for given photo
        [self createRegionWithName:regionName withPhotoInfo:photoDictionary fromPhoto:photo withContext:context];
    });
}

// Helper method to add region to database
+ (void)createRegionWithName:(NSString *)regionName
                       withPhotoInfo:(NSDictionary *)photoDictionary
                       fromPhoto:(Photo *)photo
                     withContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    // Makes a request to the database for the region
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", regionName];
    
    // Finds if region exists in database
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        // Error in finding photo
        NSLog(@"Error occurred when adding region");
    }
    else if ([matches count]) {
        // Gets matched region
        region = [matches firstObject];
    }
    else {
        // Adds region in database
        region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
        region.name = regionName;
    }
    
    // Sets the region property of the photo
    photo.fromRegion = region;
    
    // Creates photographer for photo in region
    if (region) {
        [Photographer createPhotographerWithPhotoInfo:photoDictionary
                                           fromRegion:region
                             inNSManagedContextObject:context];
    }
}


@end
