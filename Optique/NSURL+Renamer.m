//
//  NSURL+Renamer.m
//  Optique
//
//  Created by James Dumay on 24/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSURL+Renamer.h"

@implementation NSURL (Renamer)

-(NSURL *)URLWithUniqueNameIfExistsAtParent
{
    NSString *filename = [self lastPathComponent];
    NSString *filenameWithNoExt = [filename stringByDeletingPathExtension];
    NSString *extension = [filename pathExtension];
    NSURL *folder = [self URLByDeletingLastPathComponent];
    
    int count = 1;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    while ([fileManager fileExistsAtPath: [[folder URLByAppendingPathComponent:filename] path]])
    {
        filename = [NSString stringWithFormat:@"%@ (%d).%@", filenameWithNoExt, count, extension];
        count++;
    }
    
    return [folder URLByAppendingPathComponent:filename];
}

@end
