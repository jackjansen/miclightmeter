//
//  MLMModel.m
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLMModel.h"
#import "mlmlib.h"

@interface MLMModel () {
    struct mlm *mlm;
    uint64_t timestampLastTransitionToLow;
    bool isBelowLow;
}

- (void) _updateLightModulation: (float)lightLevel at: (uint64_t)timestamp;
@end


@implementation MLMModel

- (MLMModel *)init
{
    if (self = [super init]) {
        self.audioLevel = [[MLMValue alloc] init];
        self.lightLevel = [[MLMValue alloc] init];
        self.lightModulation = [[MLMValue alloc] init];
        mlm = mlm_new();
    }
    return self;
}

- (void) awakeFromNib
{
    NSLog(@"MLMModel awakeFromNib");
    self.audioLevel.absMinValue = 0.0;
    self.audioLevel.absMaxValue = 1.0;
    self.audioLevel.minValue = 0.2;
    self.audioLevel.maxValue = 0.9;
    self.audioLevel.curValue = 0;
    self.audioLevel.valid = NO;
    
    self.lightLevel.absMinValue = 0.0;
    self.lightLevel.absMaxValue = 1000.0;
    self.lightLevel.minValue = 0;
    self.lightLevel.maxValue = 0;
    self.lightLevel.curValue = 0;
    self.lightLevel.valid = NO;
    
    self.lightModulation.absMinValue = 0.0;
    self.lightModulation.absMaxValue = 100.0;
    self.lightModulation.minValue = 0;
    self.lightModulation.maxValue = 0;
    self.lightModulation.curValue = 0;
    self.lightModulation.valid = NO;
    
}

- (IBAction)resetLightLevel:(id)sender
{
    mlm_reset(mlm);
    self.lightLevel.minValue = self.lightLevel.absMinValue;
    self.lightLevel.maxValue = self.lightLevel.absMinValue;
    self.lightLevel.curValue += 1;
    self.lightLevel.curValue -= 1;
    self.lightLevel.valid = NO;
}

- (IBAction)resetLightModulation:(id)sender
{
    NSLog(@"resetLightModulation");
    self.lightModulation.minValue = self.lightModulation.absMinValue;
    self.lightModulation.maxValue = self.lightModulation.absMinValue;
    self.lightModulation.curValue += 1;
    self.lightModulation.curValue -= 1;
    self.lightModulation.valid = NO;
}

- (void)newInputDone: (void*)buffer
                size: (int)size
            channels: (int)channels
                  at: (uint64_t)timestamp
            duration: (uint64_t)duration
{
    assert(size > 0);
    assert(buffer);
    assert((size&1) == 0);
    short *sbuffer = (short *)buffer;
    
    if (size == 0 || size &1 || buffer == NULL) return;
    double rate = 44100;
//    NSLog(@"rate=%ld", rate);
    mlm_feedint(mlm, sbuffer, size, 2, channels);
    float ppLevel = mlm_amplitude(mlm);
    self.audioLevel.curValue = ppLevel;
    self.audioLevel.valid = YES;
    if (mlm_ready(mlm)) {
        // If we have light level data store it in the light level variables
        float min = rate / mlm_max(mlm);
        float max = rate / mlm_min(mlm);
        float cur = rate / mlm_current(mlm);
        float avg = rate / mlm_average(mlm);
        self.lightLevel.minValue = min;
        self.lightLevel.maxValue = max;
        self.lightLevel.curValue = cur;
        self.lightLevel.avgValue = avg;
        self.lightLevel.valid = YES;
        // Increase the maximum, if needed
        if (self.lightLevel.absMaxValue < max) self.lightLevel.absMaxValue *= 2;
        [self _updateLightModulation: cur at: timestamp];
    }
}

- (void) _updateLightModulation: (float)lightLevel at: (uint64_t)timestamp
{
    bool newIsBelowLow = lightLevel < self.lightLevel.avgValue; // xxxjack temp
    if (newIsBelowLow && !isBelowLow) {
        // Have gone from above to below low.
        if (timestampLastTransitionToLow) {
            uint64_t deltaT = timestamp - timestampLastTransitionToLow;
            float freq = 1000000.0 / deltaT;
            NSLog(@"freq=%f", freq);
            if (freq < self.lightModulation.minValue) {
                self.lightModulation.minValue = freq;
            }
            if (freq > self.lightModulation.maxValue) {
                self.lightModulation.maxValue = freq;
            }
            self.lightModulation.curValue = freq;
        }
        timestampLastTransitionToLow = timestamp;
    }
    isBelowLow = newIsBelowLow;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
//    NSLog(@"mlmmodel observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    NSLog(@"now mlmmodel observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
}
@end
