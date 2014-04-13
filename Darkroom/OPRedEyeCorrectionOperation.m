//
//  OPRedEyeCorrectionOperation.m
//  Optique
//
//  Created by James Dumay on 8/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OPRedEyeCorrectionOperation.h"
#import "CIImage+CGImageRef.h"

@implementation OPRedEyeCorrectionOperation

-(OPImage*)perform:(OPImage*)image layer:(CALayer *)layer
{
    __block CIImage *ciImage = image.image;
    
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
    
    CGImageRef imageRef = ciImage.imageRef;
    layer.contents = (__bridge id)(imageRef);
    return [[OPImage alloc] initWithCIImage:ciImage properties:image.properties];
}

@end
