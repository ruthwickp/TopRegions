//
//  Photographer+Create.m
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/30/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "Photographer+Create.h"
#import "Region+Create.h"
#import "FlickrFetcher.h"

@implementation Photographer (Create)

// Adds a photographer from a given photo in a given region in the database
+ (Photographer *)createPhotographerWithPhotoInfo:(NSDictionary *)photoDictionary
                                       fromRegion:(Region *)region
                         inNSManagedContextObject:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    // Makes a request for photographer
    NSString *name = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (inRegion = %@)", name, region];
    
    // Finds if photographer exists in database
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        // Error in finding photographer
        NSLog(@"Error occurred when adding photographer");
    }
    else if ([matches count]) {
        // Returns matched photographer
        return [matches firstObject];
    }
    else {
        // Adds photographer in database
        photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
        photographer.name = name;
        photographer.inRegion = region;
    }
    
    return photographer;
}


@end
