//
//  OPDateValueTransformer.m
//  Optique
//
//  Created by James Dumay on 13/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPDateItemCountValueTransformer.h"
#import <Exposure/Exposure.h>

@implementation OPDateItemCountValueTransformer

-(id)transformedValue:(id)value
{
    id<XPItemCollection> collection = value;
    
    NSString *date = [NSDateFormatter localizedStringFromDate:[collection created]
                                   dateStyle:NSDateFormatterLongStyle
                                   timeStyle:NSDateFormatterNoStyle];
    
    
    
    return [NSString stringWithFormat:@"%@ – %lu items", date, [collection.allItems count]];
}

@end
