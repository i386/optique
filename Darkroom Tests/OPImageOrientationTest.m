//
//  OPImageOrientationTest.m
//  Optique
//
//  Created by James Dumay on 13/04/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPImageOrientation.h"

@interface OPImageOrientationTest : XCTestCase

@end

@implementation OPImageOrientationTest

-(OPImageOrientation)orientationForResource:(NSString*)resource
{
    NSURL *url = [[[NSBundle bundleForClass:[self class]] resourceURL] URLByAppendingPathComponent:resource];
    
    CGImageSourceRef imgSrcRef = CGImageSourceCreateWithURL((__bridge CFURLRef)(url), nil);
    
    OPImageOrientation orientation = NSNotFound;
    
    if (imgSrcRef)
    {
        orientation = OPImageOrientationGet(imgSrcRef);
        CFRelease(imgSrcRef);
    }
    
    return orientation;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testLandscapeOrientationUp
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_1.jpg"];
    XCTAssertTrue(OPImageOrientationUp == orientation);
}

-(void)testLandscapeOrientationDown
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_2.jpg"];
    XCTAssertTrue(OPImageOrientationDown == orientation);
}

-(void)testLandscapeOrientationLeft
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_3.jpg"];
    XCTAssertTrue(OPImageOrientationLeft == orientation);
}

-(void)testLandscapeOrientationRight
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_4.jpg"];
    XCTAssertTrue(OPImageOrientationRight == orientation);
}

-(void)testLandscapeOrientationUpMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_5.jpg"];
    XCTAssertTrue(OPImageOrientationUpMirrored == orientation);
}

-(void)testLandscapeOrientationDownMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_6.jpg"];
    XCTAssertTrue(OPImageOrientationDownMirrored == orientation);
}

-(void)testLandscapeOrientationLeftMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_7.jpg"];
    XCTAssertTrue(OPImageOrientationLeftMirrored == orientation);
}

-(void)testLandscapeOrientationRightMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Landscape_8.jpg"];
    XCTAssertTrue(OPImageOrientationRightMirrored == orientation);
}

-(void)testPortraitOrientationUp
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_1.jpg"];
    XCTAssertTrue(OPImageOrientationUp == orientation);
}

-(void)testPortraitOrientationDown
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_2.jpg"];
    XCTAssertTrue(OPImageOrientationDown == orientation);
}

-(void)testPortraitOrientationLeft
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_3.jpg"];
    XCTAssertTrue(OPImageOrientationLeft == orientation);
}

-(void)testPortraitOrientationRight
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_4.jpg"];
    XCTAssertTrue(OPImageOrientationRight == orientation);
}

-(void)testPortraitOrientationUpMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_5.jpg"];
    XCTAssertTrue(OPImageOrientationUpMirrored == orientation);
}

-(void)testPortraitOrientationDownMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_6.jpg"];
    XCTAssertTrue(OPImageOrientationDownMirrored == orientation);
}

-(void)testPortraitOrientationLeftMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_7.jpg"];
    XCTAssertTrue(OPImageOrientationLeftMirrored == orientation);
}

-(void)testPortraitOrientationRightMirrored
{
    OPImageOrientation orientation = [self orientationForResource:@"Portrait_8.jpg"];
    XCTAssertTrue(OPImageOrientationRightMirrored == orientation);
}

@end
