//
//  NSURL+UnrollToParent.m
//  Optique
//
//  Created by James Dumay on 16/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "NSURL+UnrollToParent.h"

@implementation NSURL (UnrollToParent)

-(NSURL *)unrollToParent:(NSURL *)parent
{
    NSURL *currentURL = self;
    NSURL *lastURL = currentURL;
    
    while (![currentURL isEqualTo:parent])
    {
        lastURL = currentURL;
        currentURL = [currentURL URLByDeletingLastPathComponent];
    }
    
    return lastURL;
}

@end
