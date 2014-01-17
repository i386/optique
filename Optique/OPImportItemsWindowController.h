//
//  OPImportPhotosWindowController.h
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OPImportItemsWindowController : NSWindowController<NSComboBoxDataSource>

-(id)initWithItems:(NSArray *)items collectionManager:(XPCollectionManager*)collectionManager whenCompleted:(XPCompletionBlock)block;

@end
