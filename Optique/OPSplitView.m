//
//  OPSplitView.m
//  Optique
//
//  Created by James Dumay on 8/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPSplitView.h"

@implementation OPSplitView

-(CGFloat)dividerThickness
{
    if ([self.delegate respondsToSelector:@selector(dividerThickness)])
    {
        CGFloat dividerThickness = [((id)self.delegate) dividerThickness];
        if (dividerThickness >= 0)
        {
            return dividerThickness;
        }
    }
    return [super dividerThickness];
}

@end
