//
//  OPAutoAdjustEnhanceOperation.m
//  Optique
//
//  Created by James Dumay on 8/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPAutoAdjustEnhanceOperation.h"

@implementation OPAutoAdjustEnhanceOperation

-(void)performPreview:(CALayer *)layer forItem:(id<XPItem>)item
{
    CGImageRef imageRef = (__bridge CGImageRef)layer.contents;
    layer.contents = (__bridge id)[self perform:imageRef forItem:item];
}

-(CGImageRef)perform:(CGImageRef)imgRef forItem:(id<XPItem>)item
{
    __block CIImage *ciImage = [[CIImage alloc] initWithCGImage:imgRef];
    
    NSDictionary *adjustmentOptions = @{kCIImageAutoAdjustEnhance: [NSNumber numberWithBool:YES],
                                        kCIImageAutoAdjustRedEye: [NSNumber numberWithBool:YES]};
    
    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:adjustmentOptions];
    
    [adjustments bk_each:^(CIFilter *filter) {
        [filter setValue:ciImage forKey:@"inputImage"];
        ciImage = [filter valueForKey:@"outputImage"];
    }];
    
    CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    return [context createCGImage:ciImage fromRect:[ciImage extent]];
}

@end
