//
//  OPBundleLoader.h
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPExposureLoader : NSObject

@property (readonly, strong) NSDictionary *exposures;

+(OPExposureLoader*)defaultLoader;

-(void)loadExposures;

@end
