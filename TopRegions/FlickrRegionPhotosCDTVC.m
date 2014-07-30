//
//  FlickrRegionPhotosCDTVC.m
//  TopPlaces
//
//  Created by Ruthwick Pathireddy on 7/23/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "FlickrRegionPhotosCDTVC.h"
#import "ImageViewController.h"
#import "Photo.h"

@interface FlickrRegionPhotosCDTVC ()

@end

@implementation FlickrRegionPhotosCDTVC

// When region is set, we create a NSFetchResultsController to display
// photos within the region
- (void)setRegion:(Region *)region
{
    _region = region;
    
    // Making a request for the particular region
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", region.name];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[region managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


// Displays photo from region into cell using NSFetchedResultsController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionPhoto" forIndexPath:indexPath];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    return cell;
}

// Displays photo object when user selects row
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    // Prepares the image view controller to display image
                    ImageViewController *ivc = segue.destinationViewController;
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    ivc.imageURL = [NSURL URLWithString:photo.imageURL];
                }
            }
        }
    }
}

@end
