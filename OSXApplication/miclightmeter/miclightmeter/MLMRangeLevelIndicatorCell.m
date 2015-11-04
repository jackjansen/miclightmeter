//
//  MLMRangeLevelIndicatorCell.m
//  miclightmeter
//
//  Created by Jack Jansen on 02/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLMRangeLevelIndicatorCell.h"

@implementation MLMRangeLevelIndicatorCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    double level = (self.floatValue - self.minValue)/(self.maxValue- self.minValue);
    double leftBoundary = (self.warningValue - self.minValue)/(self.maxValue- self.minValue);
    double rightBoundary = (self.criticalValue - self.minValue)/(self.maxValue- self.minValue);
    if (level > 1.0){level = 1.0;}
    NSLog(@"Level: %a", level);
    if (self.leftColor == nil) self.leftColor = [NSColor yellowColor];
    if (self.midColor == nil) self.midColor = [NSColor greenColor];
    if (self.rightColor == nil) self.rightColor = [NSColor yellowColor];
#if 0
    NSColor *fillColor;
    if(self.floatValue < self.warningValue)
        fillColor = self.leftColor;
    else if(self.floatValue < self.criticalValue)
        fillColor = self.midColor;
    else
        fillColor = self.rightColor;
#endif
    
    
    NSRect levelRect = NSInsetRect(cellFrame, 2, 1);
    NSRect leftRect = levelRect, midRect = levelRect, rightRect = levelRect, valueRect = levelRect;
    leftRect.size.width = levelRect.size.width * leftBoundary;
    midRect.origin.x = leftRect.origin.x + leftRect.size.width;
    midRect.size.width = levelRect.size.width * (rightBoundary-leftBoundary);
    rightRect.origin.x = midRect.origin.x + midRect.size.width;
    rightRect.size.width = levelRect.size.width * (1-rightBoundary);
    valueRect.origin.x = levelRect.size.width * level;
    valueRect.size.width = 0;
    valueRect = NSInsetRect(valueRect, -1, -1);
    
    NSBezierPath * levelPath;
    if (self.leftColor) {
        levelPath = [NSBezierPath bezierPathWithRect:leftRect];
        [self.leftColor setFill];
        [levelPath fill];
    }
    if (self.midColor) {
        levelPath = [NSBezierPath bezierPathWithRect:midRect];
        [self.midColor setFill];
        [levelPath fill];
    }
    if (self.rightColor) {
        levelPath = [NSBezierPath bezierPathWithRect:rightRect];
        [self.rightColor setFill];
        [levelPath fill];
    }
    levelPath = [NSBezierPath bezierPathWithRect:valueRect];
    [[NSColor blackColor] setFill];
    [levelPath fill];
    
    NSBezierPath * indicatorPath = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, 2, 1)];
    [indicatorPath setLineWidth:1];
    [[NSColor grayColor] setStroke];
    [indicatorPath stroke];
    
}

@end
