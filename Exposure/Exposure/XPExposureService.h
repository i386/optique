//
//  OPBundleLoader.h
//  Optique
//
//  Created by James Dumay on 5/05/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPPlugin.h"
#import "XPItemCollectionProvider.h"
#import "XPCollectionManager.h"
#import "XPNavigationController.h"

@interface XPExposureService : NSObject

@property (readonly, strong) NSDictionary *exposures;

+(id<XPPlugin>)pluginForBundle:(NSString*)bundleId;

+(id<XPItemCollectionProvider>)itemCollectionProviderForBundle:(NSString*)bundleId;

+(void)loadPlugins:(NSDictionary*)userInfo;

+(void)unloadPlugins:(NSDictionary*)userInfo;

+(void)collectionManagerWasCreated:(XPCollectionManager*)collectionManager;

+(void)collectionManager:(XPCollectionManager*)collectionManager collectionViewController:(id<XPCollectionViewController>)controller;

+(void)collectionManager:(XPCollectionManager*)collectionManager itemCollectionViewController:(id<XPItemCollectionViewController>)controller;

+(void)collectionManager:(XPCollectionManager*)collectionManager itemController:(id<XPItemController>)controller;

+(void)menuVisiblity:(NSMenu*)menu items:(NSArray*)items;

+(void)menuVisiblity:(NSMenu*)menu item:(id)item;

+(NSSet*)itemCollectionProviders;

+(NSArray*)debugMenuItems;

+(id<XPItemCollection>)collectionWithTitle:(NSString*)title path:(NSURL*)path;

+(id<XPItem>)itemForURL:(NSURL*)url collection:(id<XPItemCollection>)collection;

+(void)registerToolbar:(NSToolbar*)toolbar;

+(void)navigationControllerWasCreated:(id<XPNavigationController>)navigationController;

+(void)sidebarControllerWasCreated:(id<XPSidebarController>)sidebarController;

+(NSArray*)preferencePanelViewControllers;

@end
