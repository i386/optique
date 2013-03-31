//
//  OPMainWindowController.m
//  Optique
//
//  Created by James Dumay on 26/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPMainWindowController.h"
#import "OPWindow.h"

#import "OPNavigationController.h"

@interface OPMainWindowController () {
    OPNavigationController *_navigationController;
}

@end

@implementation OPMainWindowController

-(NSString *)windowNibName
{
    return @"OPMainWindowController";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    OPWindow *iWindow = (OPWindow*)self.window;
    
    _albumViewController = [[OPAlbumViewController alloc] initWithPhotoManager:_photoManager];
    
    _navigationController = [[OPNavigationController alloc] initWithRootViewController:_albumViewController];
    _navigationController.delegate = self;
    
    NSView *contentView = self.window.contentView;
    [self.window.contentView addSubview:_navigationController.view];
    [_navigationController.view setFrame:contentView.frame];
    
    [iWindow.titleBarView addSubview:_navigationController.navigationBar];
}

-(void)update:(OPNavigationController*)navigationController title:(NSString*)title
{
    self.window.title = [NSString stringWithFormat:@"Optique - %@", title];
}

@end
