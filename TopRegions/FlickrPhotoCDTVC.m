//
//  FlickrPhotoCDTVC.m
//  TopPlaces
//
//  Created by Ruthwick Pathireddy on 7/22/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "FlickrPhotoCDTVC.h"
#import "ImageViewController.h"
#import "Photo.h"

@implementation FlickrPhotoCDTVC

#pragma mark - UITableViewDataSource

// Displays photo from region into cell using NSFetchedResultsController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Check to see if photo has an empty title and empty description
    NSString *description = photo.subtitle;
    NSString *title = ![photo.title isEqualToString:@""] ? photo.title : description;
    if ([title isEqualToString:@""] && [description isEqualToString:@""]) {
        title = @"Unknown";
        description = @"Unknown";
    }
    
    // Configures cell
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    return cell;
}

#pragma mark - Navigation

// Displays photo object when user selects row
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    // Prepares the image view controller to display image
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                }
            }
        }
    }
}

// Helper method to display and set info for image view controller
- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(Photo *)photo
{
    ivc.imageURL = [NSURL URLWithString:photo.imageURL];
    ivc.title = photo.title;
}



@end
