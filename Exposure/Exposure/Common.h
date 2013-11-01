#import <Foundation/Foundation.h>

typedef void (^XPImageCompletionBlock)(NSImage *image);
typedef void (^XPDataCompletionBlock)(NSData* data);
typedef void (^XPURLSupplier)(NSURL *suppliedUrl);
typedef void (^XPCompletionBlock)(NSError *error);
typedef void (^XPBlock)();