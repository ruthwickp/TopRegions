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

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSURLSession *flickrDownloadingSession;
@end

@implementation AppDelegate

#define FLICKR_FETCH @"FLICKR_FETCH"

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

// Posts a notification when the context is set
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
    NSURLSessionDownloadTask *task = [self.flickrDownloadingSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
    task.taskDescription = FLICKR_FETCH;
    [task resume];
}

// Lazily instantiates the flickr downloading session
- (NSURLSession *)flickrDownloadingSession
{
    if (!_flickrDownloadingSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
        _flickrDownloadingSession = [NSURLSession sessionWithConfiguration:configuration
                                                                  delegate:self
                                                             delegateQueue:nil];
    }
    return _flickrDownloadingSession;
}

// Add photos to database after downloading url
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        NSData *jsonFlickrResults = [NSData dataWithContentsOfURL:location];
        NSDictionary *flickrPropertyResults = [NSJSONSerialization JSONObjectWithData:jsonFlickrResults
                                                                              options:0
                                                                                error:NULL];
        NSArray *photos = [flickrPropertyResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        [self.context performBlock:^{
            [Photo addPhotosFromArray:photos inNSManagedObjectContext:self.context];
        }];
    }
}

// Required by protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{}

// Required by protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{}

@end
