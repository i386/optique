//
//  NSURL+NSURL_URLWithoutQuery.m
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "NSURL+URLWithoutQuery.h"

@implementation NSURL (URLWithoutQuery)

-(NSURL *)URLWithoutQuery
{
    return [[NSURL alloc] initWithScheme:[self scheme]
                                    host:[self host]
                                    path:[self path]];
}

@end
