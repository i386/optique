//
//  OPPhotoViewController.m
//  Optique
//
//  Created by James Dumay on 28/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OPPhotoViewController.h"
#import "OPPhotoView.h"
#import "NSImage+CGImage.h"
#import "OPEffectProcessedImageRef.h"

@implementation OPPhotoViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)album photo:(OPPhoto *)photo
{
    self = [super initWithNibName:@"OPPhotoViewController" bundle:nil];
    if (self) {
        _photoAlbum = album;
        _photo = photo;
    }
    return self;
}

-(NSString *)viewTitle
{
    return [[[self.photo.path path] lastPathComponent] stringByDeletingPathExtension];
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)nextPhoto
{
    NSUInteger position = [_photoAlbum.allPhotos indexOfObject:_photo];
    if (position != NSNotFound && position++ < (_photoAlbum.allPhotos.count-1))
    {
        [self changePhoto:position];
    }
}

-(void)previousPhoto
{
    NSUInteger position = [_photoAlbum.allPhotos indexOfObject:_photo];
    if (position != NSNotFound && position != 0 && position-- < _photoAlbum.allPhotos.count)
    {
        [self changePhoto:position];
    }
}

- (IBAction)rotateLeft:(id)sender
{
    [_imageView rotateImageLeft:self];
    [_imageView zoomImageToFit:self];
}

-(void)changePhoto:(NSUInteger)position
{
    _photo = [[_photoAlbum allPhotos] objectAtIndex:position];
    [self reloadEffects];
    [_imageView setCompositingFilter:nil];
    [_imageView setImageWithURL:_photo.path];
    [self.controller updateNavigationBar];
}

-(void)loadView
{
    [super loadView];
    
    [_imageView setDoubleClickOpensImageEditPanel:NO];
}

-(void)awakeFromNib
{
    [_collectionView addObserver:self forKeyPath:@"selectionIndexes" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if([keyPath isEqualTo:@"selectionIndexes"])
    {
        OPEffectProcessedImageRef *processedImage = [[_imagesArrayController content] objectAtIndex:[[_collectionView selectionIndexes] lastIndex]];
        
        NSDictionary *filters = [self filtersForImage:nil];
        
        CIFilter *filter = [filters objectForKey:processedImage.effect];
        [self performSelectorOnMainThread:@selector(setFilter:) withObject:filter waitUntilDone:NO];
    }
}

-(void)setFilter:(CIFilter*)filter
{
    [_imageView setCompositingFilter:filter];
    
    //Keeps next/previous keyboard navigation working when the collection view is used to set an effect.
    [self.view.window makeFirstResponder:self.view];
}

-(NSArray *)processedImages
{
    NSMutableArray *images = [NSMutableArray array];
    
    CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    
    NSImage *image = [[OPImageCache sharedPreviewCache] loadImageForPath:_photo.path];
    [images addObject:[OPEffectProcessedImageRef newWithImage:image effect:@"Original"]];
    
    CGImageRef imageRef = image.CGImageRef;
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:imageRef];
    
    NSDictionary *filters = [self filtersForImage:ciImage];
    for (NSString *filterName in filters.allKeys)
    {
        CIFilter *filter = [filters objectForKey:filterName];
        CIImage *result = [filter valueForKey:kCIOutputImageKey];
        CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
        NSImage *filteredImage = [[NSImage alloc] initWithCGImage:cgImage size:image.size];
        [images addObject:[OPEffectProcessedImageRef newWithImage:filteredImage effect:filterName]];
    }
    
    return [NSArray arrayWithArray:images];
}

-(NSDictionary*)filtersForImage:(CIImage*)image
{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    [filters setObject:[CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,image, @"inputIntensity",[NSNumber numberWithFloat:0.8], nil] forKey:@"Sepia"];
    [filters setObject:[CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,image,@"inputColor",[CIColor colorWithString:@"Red"], @"inputIntensity",[NSNumber numberWithFloat:0.8], nil] forKey:@"Mono"];
    
    return filters;
}

-(void)reloadEffects
{
    [self willChangeValueForKey:@"processedImages"];
    [self didChangeValueForKey:@"processedImages"];
}

@end
