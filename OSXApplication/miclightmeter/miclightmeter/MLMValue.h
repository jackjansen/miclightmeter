//
//  MLMValue.h
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface MLMValue : NSObject
@property NSNumber* absMinValue;
@property NSNumber* absMaxValue;
@property NSNumber* minValue;
@property NSNumber* maxValue;
@property NSNumber* curValue;
@property NSColor* belowMinColor;
@property NSColor* midColor;
@property NSColor* aboveMaxColor;

- (void)resetMinMax;

@end
