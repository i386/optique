//
//  OPDateValueTransformer.m
//  Optique
//
//  Created by James Dumay on 13/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPDateValueTransformer.h"

@implementation OPDateValueTransformer

-(id)transformedValue:(id)value
{
    return [NSDateFormatter localizedStringFromDate:[NSDate date]
                                   dateStyle:NSDateFormatterLongStyle
                                   timeStyle:NSDateFormatterNoStyle];
}

@end
