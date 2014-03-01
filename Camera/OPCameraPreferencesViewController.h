//
//  OPCameraPreferencesViewController.h
//  Optique
//
//  Created by James Dumay on 1/03/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Exposure/Exposure.h>

@interface OPCameraPreferencesViewController : NSViewController<XPPreferencesViewController>

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSImage *toolbarItemImage;
@property (nonatomic, readonly) NSString *toolbarItemLabel;

@end
