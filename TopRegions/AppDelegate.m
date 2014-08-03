//
//  AppDelegate.m
//  TopRegions
//
//  Created by Ruthwick Pathireddy on 7/29/14.
//  Copyright (c) 2014 Darkking. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "DatabaseAvailability.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation AppDelegate

// Creates managed document when accessed for the first time
- (UIManagedDocument *)document
{
    if (!_document) {
        // Finds the url for document
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:(NSUserDomainMask)] firstObject];
        NSString *documentName = @"FlickrPhotoDatabase";
        NSURL *documentURL = [documentsDirectory URLByAppendingPathComponent:documentName];
        _document = [[UIManagedDocument alloc] initWithFileURL:documentURL];
    }
    return _document;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Checks to see if document can be created
    [self createUIManagedDocument];
    return YES;
}

// Tries to create or open UIManagedDocument
- (void)createUIManagedDocument
{
    // Check if file already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self.document fileURL] path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            // If successful, informs that the document is ready
            if (success) {
                [self documentIsReady];
            }
            else {
                NSLog(@"Error, document could not be created.");
            }
        }];
    }
    // Creates a new file
    else {
        [self.document saveToURL:[self.document fileURL]
                forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
                   // If success, informs that the document is ready
                   if (success) {
                       [self documentIsReady];
                   }
                   else {
                       NSLog(@"Error, document could not be created.");
                   }
               }];
    }
}

// Once the document is ready, we fetch flickr photos
- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.context = self.document.managedObjectContext;
        [self fetchFlickrPhotos];
    }
}

// Posts a notification when the database is set
- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    NSDictionary *userInfo = self.context ? @{ DatabaseAvailabilityContext : self.context } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

// Fetches flickr photos
- (void)fetchFlickrPhotos
{
    dispatch_queue_t fetchQ = dispatch_queue_create("fetchQ", NULL);
    dispatch_async(fetchQ, ^{
        NSURL *flickrPhotosURL = [FlickrFetcher URLforRecentGeoreferencedPhotos];
        NSData *jsonFlickrResults = [NSData dataWithContentsOfURL:flickrPhotosURL];
        NSDictionary *flickrPropertyResults = [NSJSONSerialization JSONObjectWithData:jsonFlickrResults
                                                                              options:0
                                                                                error:NULL];
        NSArray *photos = [flickrPropertyResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        [Photo addPhotosFromArray:photos inNSManagedObjectContext:self.context];
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

@end
