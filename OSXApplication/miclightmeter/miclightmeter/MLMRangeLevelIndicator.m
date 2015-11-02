//
//  MLMRangeLevelIndicator.m
//  miclightmeter
//
//  Created by Jack Jansen on 02/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLMRangeLevelIndicator.h"
#import "MLMRangeLevelIndicatorCell.h"

@implementation MLMRangeLevelIndicator

+ (Class) cellClass {
    return [MLMRangeLevelIndicatorCell class];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
