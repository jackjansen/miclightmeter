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
@property float absMinValue;
@property float absMaxValue;
@property float minValue;
@property float maxValue;
@property float curValue;

@end
