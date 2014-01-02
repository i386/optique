//
//  ICCameraDevice+OrderedMediaFiles.m
//  Optique
//
//  Created by James Dumay on 2/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "ICCameraDevice+OrderedMediaFiles.h"

@implementation ICCameraDevice (OrderedMediaFiles)

-(NSArray *)orderedMediaFiles
{
    return [self.mediaFiles sortedArrayUsingComparator:^NSComparisonResult(ICCameraFile *obj1, ICCameraFile *obj2) {
        return [obj2.creationDate compare:obj1.creationDate];
    }];
}

@end
