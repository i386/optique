//
//  OPPhotoCollectionItem.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPhotoCollectionItem.h"

@interface OPPhotoCollectionItem ()

@end

@implementation OPPhotoCollectionItem

-(NSString *)nibName
{
    return @"PhotoCollectionViewItemPrototype";
}

- (void)doubleClick:(id)sender
{
	if([self collectionView] && [[self collectionView] delegate] && [[[self collectionView] delegate] respondsToSelector:@selector(doubleClick:)]) {
		[[[self collectionView] delegate] performSelector:@selector(doubleClick:) withObject:self];
	}
}

@end
