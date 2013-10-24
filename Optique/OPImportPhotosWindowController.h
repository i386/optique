//
//  OPImportPhotosWindowController.h
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPImportPhotosWindowController : NSWindowController<NSComboBoxDataSource>

-(id)initWithPhotos:(NSArray *)photos photoManager:(XPPhotoManager*)photoManager whenCompleted:(XPCompletionBlock)block;

@end
