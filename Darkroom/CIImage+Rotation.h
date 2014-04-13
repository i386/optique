//
//  CIImage+Rotation.h
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CIImage (Rotation)

- (CIImage *)rotateByDegrees:(float)degrees;

@end
