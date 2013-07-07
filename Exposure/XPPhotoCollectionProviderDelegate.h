//
//  OPPhotoCollectionDelegate.h
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPPhotoCollection.h"

@protocol XPPhotoCollectionProviderDelegate <NSObject>

-(void)didAddPhotoCollection:(id<XPPhotoCollection>)photoCollection;

-(void)didRemovePhotoCollection:(id<XPPhotoCollection>)photoCollection;

@end
