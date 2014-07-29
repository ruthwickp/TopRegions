//
//  Photographer.h
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/29/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Region *inRegion;

@end
