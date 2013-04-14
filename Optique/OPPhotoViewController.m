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
#import "NSImage+Transform.h"

@implementation OPPhotoViewController

-(id)initWithPhotoAlbum:(OPPhotoAlbum *)album photo:(OPPhoto *)photo
{
    self = [super initWithNibName:@"OPPhotoViewController" bundle:nil];
    if (self) {
        _photoAlbum = album;
        _photo = photo;
        _effectsState = NSOffState;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewSizeChanged:) name:NSWindowDidResizeNotification object:self.view.window];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewSizeChanged:) name:NSViewFrameDidChangeNotification object:self.view];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self.view];
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
    _imageView.image = [_imageView.image imageRotatedByDegrees:90];
}

- (IBAction)toggleEffects:(id)sender
{
    if ([self swizzleEffectState])
    {
        [_effectsPanel.animator setHidden:NO];
        [_effectsPanel removeFromSuperview];
        [self.view addSubview:_effectsPanel];
    }
    else
    {
        [_effectsPanel.animator setHidden:YES];
    }
}

-(void)changePhoto:(NSUInteger)position
{
    _photo = [[_photoAlbum allPhotos] objectAtIndex:position];
    [self reloadEffects];
    _imageView.image = [_photo scaleImageToFitSize:_imageView.frame.size];
    [self.controller updateNavigationBar];
}

-(void)loadView
{
    [super loadView];
    
    [_collectionView addObserver:self forKeyPath:@"selectionIndexes" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    [_collectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

-(void)viewSizeChanged:(NSNotification*)notification
{
     _imageView.image = [_photo scaleImageToFitSize:_imageView.frame.size];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if([keyPath isEqualTo:@"selectionIndexes"])
    {
        if (_collectionView.selectionIndexes.count > 0)
        {
            OPEffectProcessedImageRef *processedImage = [[_imagesArrayController content] objectAtIndex:[[_collectionView selectionIndexes] lastIndex]];
            
            NSDictionary *filters = [self filtersForImage:nil];
            
            CIFilter *filter = [filters objectForKey:processedImage.effect];
            
            [self performBlockOnMainThread:^{
                [_imageView setCompositingFilter:filter];
                
                //Keeps next/previous keyboard navigation working when the collection view is used to set an effect.
                [self.view.window makeFirstResponder:self.view];
            }];
        }
        else
        {
            [_collectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
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
    
    CIFilter *curve = [CIFilter filterWithName:@"CIToneCurve"];
    
    [curve setDefaults];
    [curve setValue:image forKey:kCIInputImageKey];
    [curve setValue:[CIVector vectorWithX:0.0  Y:0.0] forKey:@"inputPoint0"]; // default
    [curve setValue:[CIVector vectorWithX:0.25 Y:0.15] forKey:@"inputPoint1"];
    [curve setValue:[CIVector vectorWithX:0.5  Y:0.5] forKey:@"inputPoint2"];
    [curve setValue:[CIVector vectorWithX:0.75  Y:0.85] forKey:@"inputPoint3"];
    [curve setValue:[CIVector vectorWithX:1.0  Y:1.0] forKey:@"inputPoint4"]; // default
    
    [filters setObject:curve forKey:@"Curve"];
    
    CIFilter *saturate= [CIFilter filterWithName:@"CIColorControls"];
    
    [saturate setValue:image forKey:@"inputImage"];
    
    [saturate setValue:[NSNumber numberWithFloat:3] forKey:@"inputSaturation"];
    [saturate setValue:[NSNumber numberWithFloat:1] forKey:@"inputContrast"];
    
    [filters setObject:saturate forKey:@"Summer"];
    
    return filters;
}

-(void)reloadEffects
{
    [self willChangeValueForKey:@"processedImages"];
    [self didChangeValueForKey:@"processedImages"];
    [_collectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

-(BOOL)swizzleEffectState
{
    if (_effectsState == NSOnState)
    {
        _effectsState = NSOffState;
    }
    else if (_effectsState == NSOffState)
    {
        _effectsState = NSOnState;
    }
    return (_effectsState == NSOnState);
}

@end
