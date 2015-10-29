//
//  MLMModel.m
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLMModel.h"

@implementation MLMModel

//@property MLMValue* audioLevel;
//@property MLMValue* lightLevel;
//@property MLMValue* variationSensitivity;
//@property MLMValue* variationFrequency;

- (void) awakeFromNib
{
    NSLog(@"MLMModel awakeFromNib");
    self.audioLevel.absMinValue = [NSNumber numberWithFloat: 0.0];
    self.audioLevel.absMaxValue = [NSNumber numberWithFloat: 100.0];
    self.audioLevel.minValue = [NSNumber numberWithFloat: 40.0];
    self.audioLevel.maxValue = [NSNumber numberWithFloat: 80.0];
    self.audioLevel.curValue = [NSNumber numberWithFloat: 50.0];
    self.audioLevel.belowMinColor = [NSColor yellowColor];
    self.audioLevel.midColor = [NSColor greenColor];
    self.audioLevel.aboveMaxColor = [NSColor yellowColor];
    
    self.lightLevel.absMinValue = [NSNumber numberWithFloat: 0.0];
    self.lightLevel.absMaxValue = [NSNumber numberWithFloat: 100.0];
    self.lightLevel.minValue = [NSNumber numberWithFloat: 40.0];
    self.lightLevel.maxValue = [NSNumber numberWithFloat: 80.0];
    self.lightLevel.curValue = [NSNumber numberWithFloat: 50.0];
    self.lightLevel.belowMinColor = [NSColor yellowColor];
    self.lightLevel.midColor = [NSColor greenColor];
    self.lightLevel.aboveMaxColor = [NSColor yellowColor];
    
    self.variationSensitivity.absMinValue = [NSNumber numberWithFloat: 0.0];
    self.variationSensitivity.absMaxValue = [NSNumber numberWithFloat: 100.0];
    self.variationSensitivity.minValue = [NSNumber numberWithFloat: 40.0];
    self.variationSensitivity.maxValue = [NSNumber numberWithFloat: 80.0];
    self.variationSensitivity.curValue = [NSNumber numberWithFloat: 50.0];
    self.variationSensitivity.belowMinColor = [NSColor yellowColor];
    self.variationSensitivity.midColor = [NSColor greenColor];
    self.variationSensitivity.aboveMaxColor = [NSColor yellowColor];
    
    self.variationFrequency.absMinValue = [NSNumber numberWithFloat: 0.0];
    self.variationFrequency.absMaxValue = [NSNumber numberWithFloat: 100.0];
    self.variationFrequency.minValue = [NSNumber numberWithFloat: 40.0];
    self.variationFrequency.maxValue = [NSNumber numberWithFloat: 80.0];
    self.variationFrequency.curValue = [NSNumber numberWithFloat: 50.0];
    self.variationFrequency.belowMinColor = [NSColor yellowColor];
    self.variationFrequency.midColor = [NSColor greenColor];
    self.variationFrequency.aboveMaxColor = [NSColor yellowColor];
    
}

- (void)reportAudioLevel: (NSNumber *)level
{
    NSLog(@"Audiolevel %@", level);
    self.audioLevel.curValue = level;
}

- (IBAction)resetLightLevel:(id)sender
{
}

- (IBAction)resetVariationFrequency:(id)sender
{
}

- (IBAction)changeVariationSensitivity:(id)sender
{
}

- (void)newInputDone: (void*)buffer
                size: (int)size
            channels: (int)channels
                  at: (uint64_t)timestamp
            duration: (uint64_t)duration
{
    NSLog(@"Got audio");
}

@end
