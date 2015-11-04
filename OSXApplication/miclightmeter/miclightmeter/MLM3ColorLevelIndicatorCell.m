//
//  MLM3ColorLevelIndicatorCell.m
//  miclightmeter
//
//  Created by Jack Jansen on 02/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLM3ColorLevelIndicatorCell.h"

@implementation MLM3ColorLevelIndicatorCell

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

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    double level = (self.floatValue - self.minValue)/(self.maxValue- self.minValue);
    if (level > 1.0){level = 1.0;}
    if (self.leftColor == nil) self.leftColor = [NSColor yellowColor];
    if (self.midColor == nil) self.midColor = [NSColor greenColor];
    if (self.rightColor == nil) self.rightColor = [NSColor yellowColor];
    NSColor *fillColor;
    if(self.floatValue < self.warningValue)
        fillColor = self.leftColor;
    else if(self.floatValue < self.criticalValue)
        fillColor = self.midColor;
    else
        fillColor = self.rightColor;
    
    
    NSRect levelRect = NSInsetRect(cellFrame, 2, 1);
    levelRect.size.width = levelRect.size.width * level;
    NSBezierPath * levelPath = [NSBezierPath bezierPathWithRect:levelRect];
    [fillColor setFill];
    [levelPath fill];
    NSBezierPath * indicatorPath = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, 2, 1)];
    [indicatorPath setLineWidth:1];
    [[NSColor grayColor] setStroke];
    [indicatorPath stroke];
    
}

@end
