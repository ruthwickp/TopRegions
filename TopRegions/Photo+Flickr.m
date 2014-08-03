//
//  Photo+Flickr.m
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/29/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Region+Create.h"

@implementation Photo (Flickr)

// Adds a photo into the database and returns it
+ (Photo *)addPhotoInfo:(NSDictionary *)photoDictionary
inNSManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    // Makes a request to the database for the photo
    NSString *unique = [photoDictionary valueForKey:FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    // Finds if photo exists in database
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        // Error in finding photo
        NSLog(@"Error occurred when adding photo");
    }
    else if ([matches count]) {
        // Returns matched photo
        return [matches firstObject];
    }
    else {
        // Adds photo in database
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.unique = unique;
        NSString *imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.imageURL = imageURL;
        
        // Gets the thumbnail on a different thread
        NSURL *thumbnailURL = [FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare];
        dispatch_queue_t thumbnailQ = dispatch_queue_create("thumbnailQ", NULL);
        dispatch_async(thumbnailQ, ^{
            NSData *jsonData = [NSData dataWithContentsOfURL:thumbnailURL];
            photo.thumbnail = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:0
                                                                error:NULL];
        });
        
        // Add region for photo
        [Region addRegionForPhotoInfo:photoDictionary withPhoto:photo inNSManagedObjectContext:context];
    }
    NSLog(@"%@", photo);
    
    return photo;
}

// Adds array of photos into database
+ (void)addPhotosFromArray:(NSArray *)photos // array of photo dictionaries
  inNSManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [Photo addPhotoInfo:photo inNSManagedObjectContext:context];
    }
    NSLog(@"completed adding photos from array");
}


@end
