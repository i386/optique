//
//  XPPlugin.h
//  Exposure
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPCollectionViewController.h"
#import "XPItemCollectionViewController.h"
#import "XPItemController.h"
#import "XPCollectionManager.h"

@protocol XPPlugin <NSObject>

@optional

/**
 Called exactly once when the plugin is successfully loaded
 */
-(void)pluginDidLoad:(NSDictionary*)userInfo;

/**
 Called when the plugin unloads.
 Plugins in this API are not dynamic and will unload when the application terminates
 */
-(void)pluginWillUnload:(NSDictionary*)userInfo;

/**
 Called when a collection manager is created.
 Any references to the old collection manager *must* be immediately dereferenced.
 */
-(void)collectionManagerWasCreated:(XPCollectionManager*)collectionManager;

/**
 Called whenever the collection view is loaded
 */
-(void)collectionManager:(XPCollectionManager*)collectionManager collectionViewController:(id<XPCollectionViewController>)controller;

/**
 Called whenever the item collection view is called
 */
-(void)collectionManager:(XPCollectionManager*)collectionManager itemCollectionViewController:(id<XPItemCollectionViewController>)controller;

/**
 Called whenever the item view is loaded
 */
-(void)collectionManager:(XPCollectionManager*)collectionManager itemController:(id<XPItemController>)controller;

/**
 NSMenuItems to add to the 'Debug' menu to make plugin development easier
 */
-(NSArray*)debugMenuItems;

@end
