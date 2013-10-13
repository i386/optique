//
//  OPDateValueTransformer.m
//  Optique
//
//  Created by James Dumay on 13/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPDatePhotoCountValueTransformer.h"
#import <Exposure/Exposure.h>

@implementation OPDatePhotoCountValueTransformer

-(id)transformedValue:(id)value
{
    id<XPPhotoCollection> collection = value;
    
    NSString *date = [NSDateFormatter localizedStringFromDate:[collection created]
                                   dateStyle:NSDateFormatterLongStyle
                                   timeStyle:NSDateFormatterNoStyle];
    
    
    
    return [NSString stringWithFormat:@"%@ – %lu photos", date, [collection.allPhotos count]];
}

@end
