//
//  RecentlyViewedFlickrPhotosCDTVC.m
//  TopPlaces
//
//  Created by Ruthwick Pathireddy on 7/24/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "RecentlyViewedFlickrPhotosCDTVC.h"

@interface RecentlyViewedFlickrPhotosCDTVC ()

@end

@implementation RecentlyViewedFlickrPhotosCDTVC

#define MAX_RECENT_PHOTOS 20

// Displays recently viewed photos
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createFetchedViewController];
}

- (void)createFetchedViewController
{
    
}


@end
