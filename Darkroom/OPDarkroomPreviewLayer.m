//
//  OPDarkroomPreviewLayer.m
//  Optique
//
//  Created by James Dumay on 1/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPDarkroomPreviewLayer.h"

@implementation OPDarkroomPreviewLayer

-(id)init
{
    self = [super init];
    if (self)
    {
        self.contentsGravity = kCAGravityResizeAspect;
    }
    return self;
}

@end
