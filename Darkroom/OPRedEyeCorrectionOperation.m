//
//  OPRedEyeCorrectionOperation.m
//  Optique
//
//  Created by James Dumay on 8/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPRedEyeCorrectionOperation.h"
#import <QuartzCore/QuartzCore.h>

@implementation OPRedEyeCorrectionOperation

-(void)performPreviewOperation:(CALayer*)layer
{
    __block CIImage *ciImage = [[CIImage alloc] initWithCGImage:(__bridge CGImageRef)(layer.contents)];
    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustRedEye]];
    
    [adjustments bk_each:^(CIFilter *filter) {
        [filter setValue:ciImage forKey:@"inputImage"];
        ciImage = [filter valueForKey:@"outputImage"];
    }];
    
    CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    CGImageRef img = [context createCGImage:ciImage fromRect:[ciImage extent]];
    layer.contents = (__bridge id)(img);
}

@end
