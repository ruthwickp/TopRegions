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
@property (strong, nonatomic) NSURLSession *flickrDownloadingSession;
@property (copy, nonatomic) void (^backgroundURLSessionCompletionHandler)();
@end

@implementation AppDelegate

#define RELOAD_TIME 10*60

// Lazy instantiation
- (UIManagedDocument *)document
{
    if (!_document) {
        // Creates the url for document
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
    // Tries to create a ManagedObjectContext
    [self createUIManagedObjectContext];
    return YES;
}

// Tries to create or open UIManagedDocument
- (void)createUIManagedObjectContext
{
    // Check if file already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self.document fileURL] path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            // If successful, informs that the document is ready
            if (success) {
                [self documentIsReady];
            }
            else {
                NSLog(@"Error, document could not be opened.");
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

// Posts a notification when the context is set
- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    // Loads data every 10 minutes while in foreground
    [NSTimer scheduledTimerWithTimeInterval:RELOAD_TIME
                                     target:self
                                   selector:@selector(fetchFlickrPhotos:)
                                   userInfo:nil
                                    repeats:YES];
    
    NSDictionary *userInfo = self.context ? @{ DatabaseAvailabilityContext : self.context } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

// Method for NSTimer selector
- (void)fetchFlickrPhotos:(NSTimer *)timer
{
    [self fetchFlickrPhotos];
}

// Fetches flickr photos
- (void)fetchFlickrPhotos
{
    NSURLSessionDownloadTask *task = [self.flickrDownloadingSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]
      completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
          NSData *jsonFlickrResults = [NSData dataWithContentsOfURL:location];
          NSDictionary *flickrPropertyResults = [NSJSONSerialization JSONObjectWithData:jsonFlickrResults
                                                                                options:0
                                                                                  error:NULL];
          NSArray *photos = [flickrPropertyResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
          // Adds photos to database
          [self.context performBlock:^{
              [Photo addPhotosFromArray:photos inNSManagedObjectContext:self.context];
          }];

    }];
    [task resume];
}

// Lazily instantiates the flickr downloading session
- (NSURLSession *)flickrDownloadingSession
{
    if (!_flickrDownloadingSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _flickrDownloadingSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _flickrDownloadingSession;
}

@end
