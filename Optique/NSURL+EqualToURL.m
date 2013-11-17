//
//  NSURL+TCBAdditions+EqualToURL.m
//
//  Created by Tony Arnold on 29/02/12.
//  Copyright (c) 2012 The CocoaBots. All rights reserved.
//

#import "NSURL+EqualToURL.h"

@implementation NSURL (EqualToURL)

- (BOOL)isEqualToURL:(NSURL *)otherURL
{
    return [[self absoluteURL] isEqual:[otherURL absoluteURL]] || ([self isFileURL] && [otherURL isFileURL] && ([[self path] isEqual:[otherURL path]]));
}

@end
