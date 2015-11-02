//
//  MLM3ColorLevelIndicator.m
//  miclightmeter
//
//  Created by Jack Jansen on 02/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLM3ColorLevelIndicator.h"
#import "MLM3ColorLevelIndicatorCell.h"

@implementation MLM3ColorLevelIndicator

+ (void) initialize {
    [self exposeBinding:@"leftColor"];
    [self exposeBinding:@"midColor"];
    [self exposeBinding:@"righttColor"];
}

- (Class) valueClassForBinding:(NSString *)binding
{
    if ([binding isEqualToString: @"leftColor"] || [binding isEqualToString: @"midColor"]  || [binding isEqualToString: @"rightColor"] )
        return [NSColor class];
    return nil;
}

+ (Class) cellClass {
    return [MLM3ColorLevelIndicatorCell class];
}

- (NSColor *)leftColor { return [[self cell] leftColor]; }
- (void)setLeftColor: (NSColor *) color { [[self cell] setLeftColor: color]; }
- (NSColor *)midColor { return [[self cell] midColor]; }
- (void)setMidColor: (NSColor *) color { [[self cell] setMidColor: color]; }
- (NSColor *)rightColor { return [[self cell] rightColor]; }
- (void)setRightColor: (NSColor *) color { [[self cell] setRightColor: color]; }

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
