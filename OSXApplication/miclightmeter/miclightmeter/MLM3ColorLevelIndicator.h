//
//  MLM3ColorLevelIndicator.h
//  miclightmeter
//
//  Created by Jack Jansen on 02/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface MLM3ColorLevelIndicator : NSLevelIndicator
@property IBInspectable NSColor *leftColor;
@property IBInspectable NSColor *midColor;
@property IBInspectable NSColor *rightColor;

+ (Class) cellClass;
@end
