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

@implementation Region (Create)

// Adds region for given photo into the database
+ (Region *)addRegionForPhotoInfo:(NSDictionary *)photoDictionary
         inNSManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    // Gets region name
    NSURL *photoInformationURL = [FlickrFetcher URLforInformationAboutPlace:[photoDictionary valueForKeyPath:FLICKR_PLACE_ID]];
    __block NSString *regionName = nil;
    dispatch_queue_t regionQ = dispatch_queue_create("Region@", NULL);
    dispatch_async(regionQ, ^{
        NSData *jsonData = [NSData dataWithContentsOfURL:photoInformationURL];
        NSDictionary *photoPlaceDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:0
                                                                               error:NULL];
        regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:photoPlaceDictionary];
    });
    
    // Makes a request to the database for the region
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", regionName];
    
    // Finds if region exists in database
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        // Error in finding photo
        NSLog(@"Error occurred when adding photo");
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
    
    // Creates photographer for photo in region
    if (region) {
    [Photographer createPhotographerWithPhotoInfo:photoDictionary
                                       fromRegion:region
                         inNSManagedContextObject:context];
    }
    
    return region;
}


@end
