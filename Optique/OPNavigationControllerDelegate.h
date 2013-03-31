//
//  OPNavigationControllerDelegate.h
//  Optique
//
//  Created by James Dumay on 31/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPNavigationController;

@protocol OPNavigationControllerDelegate <NSObject>

-(void)update:(OPNavigationController*)navigationController title:(NSString*)title;

@end
