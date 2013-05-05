//
//  OPBundleLoader.m
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPExposureLoader.h"

@implementation OPExposureLoader

+(OPExposureLoader *)defaultLoader
{
    static dispatch_once_t pred;
    static OPExposureLoader *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[OPExposureLoader alloc] init];
    });
    return shared;
}

-(void)loadExposures
{
    NSMutableDictionary *exposures = [[NSMutableDictionary alloc] init];
    
    NSURL *exposuresURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Exposures" isDirectory:YES];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:exposuresURL includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             return YES;
                                         }];
    
    for (NSURL *bundleURL in enumerator)
    {
        [self loadBundle:bundleURL exposures:exposures];
    }
    
    _exposures = exposures;
}

-(void)loadBundle:(NSURL*)path exposures:(NSMutableDictionary*)exposures
{
    Class pluginClass;
    id pluginInstance;
    NSBundle *bundleToLoad = [NSBundle bundleWithURL:path];
    if ((pluginClass = [bundleToLoad principalClass])) {
        pluginInstance = [[pluginClass alloc] init];
        [exposures setObject:pluginInstance forKey:bundleToLoad.bundleIdentifier];
    }
}

@end
