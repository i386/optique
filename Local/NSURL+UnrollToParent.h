//
//  NSURL+UnrollToParent.h
//  Optique
//
//  Created by James Dumay on 16/02/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (UnrollToParent)

-(NSURL*)unrollToParent:(NSURL*)parent;

@end
