//
//  RecentlyViewedFlickrPhotosCDTVC.m
//  TopPlaces
//
//  Created by Ruthwick Pathireddy on 7/24/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "RecentlyViewedFlickrPhotosCDTVC.h"
#import "DatabaseAvailability.h"

@interface RecentlyViewedFlickrPhotosCDTVC ()

@end

@implementation RecentlyViewedFlickrPhotosCDTVC

#define MAX_RECENT_PHOTOS 20

// Makes the controller listen for changes in the database
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.context = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
}

// Displays recently viewed photos
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createFetchedViewController];
}

// Creates NSFetchedViewController to display recently viewed photos
- (void)createFetchedViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"viewDate" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"viewDate != %@", nil];
    request.fetchLimit = MAX_RECENT_PHOTOS;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

@end
