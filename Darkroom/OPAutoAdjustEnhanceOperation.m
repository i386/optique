//
//  OPAutoAdjustEnhanceOperation.m
//  Optique
//
//  Created by James Dumay on 8/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPAutoAdjustEnhanceOperation.h"
#import "CIImage+CGImageRef.h"

@implementation OPAutoAdjustEnhanceOperation

-(OPImage*)perform:(OPImage*)image layer:(CALayer *)layer
{
    __block CIImage *ciImage = image.image;
    
    NSDictionary *adjustmentOptions = @{kCIImageAutoAdjustEnhance: [NSNumber numberWithBool:YES],
                                        kCIImageAutoAdjustRedEye: [NSNumber numberWithBool:YES]};
    
    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:adjustmentOptions];
    
    [adjustments bk_each:^(CIFilter *filter) {
        [filter setValue:ciImage forKey:@"inputImage"];
        ciImage = [filter valueForKey:@"outputImage"];
    }];
    
    CGImageRef imageRef = ciImage.imageRef;
    layer.contents = (__bridge id)(imageRef);
    return [[OPImage alloc] initWithCIImage:ciImage properties:image.properties];
}

@end
