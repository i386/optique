//
//  OPPhotoGridView.h
//  Optique
//
//  Created by James Dumay on 17/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OEGridView.h"
#import <OEGridView/OEGridView.h>

@class OPPhotoCollectionViewController;

@interface OPPhotoGridView : OEGridView

@property (weak) IBOutlet OPPhotoCollectionViewController *controller;
@property (nonatomic, assign) BOOL isSelectionSticky;

-(void)copy:(id)sender;

@end
