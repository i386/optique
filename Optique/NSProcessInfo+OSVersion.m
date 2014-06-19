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

+(NSOperatingSystemVersion)yosemiteSystemVersion
{
    static dispatch_once_t pred;
    static NSOperatingSystemVersion _yosemiteSystemVersion;
    
    dispatch_once(&pred, ^{
        _yosemiteSystemVersion.majorVersion = 10;
        _yosemiteSystemVersion.minorVersion = 10;
        _yosemiteSystemVersion.patchVersion = 0;
    });
    
    return _yosemiteSystemVersion;
}

-(BOOL)isOperatingSystemAtLeastYosemite
{
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:[NSProcessInfo yosemiteSystemVersion]];
}

@end