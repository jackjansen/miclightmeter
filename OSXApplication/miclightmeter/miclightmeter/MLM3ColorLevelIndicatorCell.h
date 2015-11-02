//
//  MLM3ColorLevelIndicatorCell.h
//  miclightmeter
//
//  Created by Jack Jansen on 02/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLM3ColorLevelIndicatorCell : NSLevelIndicatorCell
@property IBOutlet NSColor *leftColor;
@property IBOutlet NSColor *midColor;
@property IBOutlet NSColor *rightColor;

@end
