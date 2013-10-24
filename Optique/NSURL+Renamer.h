//
//  NSURL+Renamer.h
//  Optique
//
//  Created by James Dumay on 24/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Renamer)

-(NSURL*)URLWithUniqueNameIfExistsAtParent;

@end
