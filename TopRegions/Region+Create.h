//
//  Region+Create.h
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/29/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "Region.h"

@interface Region (Create)

// Adds region for given photo into the database
+ (Region *)addRegionForPhotoInfo:(NSDictionary *)photoDictionary
         inNSManagedObjectContext:(NSManagedObjectContext *)context;
@end
