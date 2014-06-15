//
//  NSProcessInfo+OSVersion.m
//  Optique
//
//  Created by James Dumay on 15/06/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSProcessInfo+OSVersion.h"

@implementation NSProcessInfo (OSVersion)

-(BOOL)isOperatingSystemAtLeastYosemite
{
    NSOperatingSystemVersion yosemiteSystemVersion;
    yosemiteSystemVersion.majorVersion = 10;
    yosemiteSystemVersion.minorVersion = 10;
    yosemiteSystemVersion.patchVersion = 0;
    
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:yosemiteSystemVersion];
}

@end