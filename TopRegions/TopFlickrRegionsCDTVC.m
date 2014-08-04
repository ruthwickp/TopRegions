//
//  TopFlickrRegionsCDTVC.m
//  TopPlaces
//
//  Created by Ruthwick Pathireddy on 7/23/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "TopFlickrRegionsCDTVC.h"
#import "FlickrRegionPhotosCDTVC.h"
#import "Region.h"
#import "DatabaseAvailability.h"

@implementation TopFlickrRegionsCDTVC

#define POPULAR_REGION_COUNT 50

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

// When context gets set, we create a fetched NSFetchedResultsController
- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    // Create a request for regions in order of photographer count
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photographerCount"
                                                              ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    request.predicate = nil;
    request.fetchLimit = POPULAR_REGION_COUNT;
    
    // Creates NSFetchedResultsController
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

// Configures tableview based on NSFetchedResultsController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Region Cell" forIndexPath:indexPath];
    
    // Configures cell for a region
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photographers", [region.photographers count]];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
        if (cellIndex) {
            if ([segue.identifier isEqualToString:@"Display Region Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[FlickrRegionPhotosCDTVC class]]) {
                    // Sets up destination view controller
                    FlickrRegionPhotosCDTVC *regionPhotosCDTVC = segue.destinationViewController;
                    Region *region = [self.fetchedResultsController objectAtIndexPath:cellIndex];
                    regionPhotosCDTVC.title = region.name;
                    regionPhotosCDTVC.region = region;
                }
            }
        }
    }
}


@end
