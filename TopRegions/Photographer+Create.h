//
//  Photographer+Create.h
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/30/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

// Adds a photographer from a given photo in a given region in the database
+ (Photographer *)createPhotographerWithPhotoInfo:(NSDictionary *)photoDictionary
                                       fromRegion:(Region *)region
                         inNSManagedContextObject:(NSManagedObjectContext *)context;


@end
