//
//  AudioGenerator.h
//  miclightmeter
//
//  Created by Jack Jansen on 09/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioGenerator : NSObject
@property float lightLevel;
@property float levelVariation;
@property float variationFrequency;

- (IBAction)changed:(id)sender;

@end
