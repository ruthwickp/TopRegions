//
//  FlickrRegionPhotosCDTVC.m
//  TopPlaces
//
//  Created by Ruthwick Pathireddy on 7/23/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "FlickrRegionPhotosCDTVC.h"

@interface FlickrRegionPhotosCDTVC ()

@end

@implementation FlickrRegionPhotosCDTVC

// When region is set, we create a NSFetchResultsController to display
// photos within the region
- (void)setRegion:(Region *)region
{
    _region = region;
    
    // Making a request for the particular region
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"fromRegion = %@", self.region];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[region managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

@end
