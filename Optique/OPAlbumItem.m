//
//  OPAlbumItem.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPAlbumItem.h"

@interface OPAlbumItem ()

@end

@implementation OPAlbumItem

- (void)doubleClick:(id)sender
{
	if([self collectionView] && [[self collectionView] delegate] && [[[self collectionView] delegate] respondsToSelector:@selector(doubleClick:)]) {
		[[[self collectionView] delegate] performSelector:@selector(doubleClick:) withObject:self];
	}
}

@end
