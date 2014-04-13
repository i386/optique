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

-(void)performPreview:(CALayer *)layer forItem:(id<XPItem>)item
{
    CGImageRef imageRef = (__bridge CGImageRef)layer.contents;
    layer.contents = (__bridge id)[self perform:imageRef];
}

-(OPImage*)perform:(OPImage*)image forItem:(id<XPItem>)item
{
    return [[OPImage alloc] initWithCGImageRef:[self perform:image.imageRef] properties:image.properties];
}

-(CGImageRef)perform:(CGImageRef)imgRef
{
    __block CIImage *ciImage = [[CIImage alloc] initWithCGImage:imgRef];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    
    NSArray *features = [faceDetector featuresInImage:ciImage options:nil];
    
    NSDictionary *adjustmentOptions = @{kCIImageAutoAdjustEnhance: [NSNumber numberWithBool:NO],
                                        kCIImageAutoAdjustRedEye: [NSNumber numberWithBool:YES],
                                        kCIImageAutoAdjustFeatures: features};
    
    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:adjustmentOptions];
    
    [adjustments bk_each:^(CIFilter *filter) {
        [filter setValue:ciImage forKey:@"inputImage"];
        ciImage = [filter valueForKey:@"outputImage"];
    }];
    
    CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    return [context createCGImage:ciImage fromRect:[ciImage extent]];
}

@end
