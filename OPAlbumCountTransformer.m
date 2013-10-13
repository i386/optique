//
//  OPAlbumCountTransformer.m
//  Optique
//
//  Created by James Dumay on 13/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumCountTransformer.h"

@implementation OPAlbumCountTransformer

-(id)transformedValue:(id)value
{
    return [NSString stringWithFormat:@"%@ albums", value];
}

@end
