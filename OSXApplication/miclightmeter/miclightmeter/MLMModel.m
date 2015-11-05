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

- (void) _updateVariationFrequency: (float)lightLevel at: (uint64_t)timestamp;
@end


@implementation MLMModel

//@property MLMValue* audioLevel;
//@property MLMValue* lightLevel;
//@property MLMValue* variationSensitivity;
//@property MLMValue* variationFrequency;
- (MLMModel *)init
{
    if (self = [super init]) {
        self.audioLevel = [[MLMValue alloc] init];
        self.lightLevel = [[MLMValue alloc] init];
        self.variationSensitivity = [[MLMValue alloc] init];
        self.variationFrequency = [[MLMValue alloc] init];
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
    
    self.lightLevel.absMinValue = 0.0;
    self.lightLevel.absMaxValue = 1000.0;
    self.lightLevel.minValue = 0;
    self.lightLevel.maxValue = 0;
    self.lightLevel.curValue = 0;
    
    self.variationSensitivity.absMinValue = 0.0;
    self.variationSensitivity.absMaxValue = 1000.0;
    self.variationSensitivity.minValue = 0;
    self.variationSensitivity.maxValue = 0;
    self.variationSensitivity.curValue = 00;
    
    self.variationFrequency.absMinValue = 0.0;
    self.variationFrequency.absMaxValue = 100.0;
    self.variationFrequency.minValue = 0;
    self.variationFrequency.maxValue = 0;
    self.variationFrequency.curValue = 0;
    
}

- (IBAction)resetLightLevel:(id)sender
{
    mlm_reset(mlm);
    self.lightLevel.minValue = self.lightLevel.absMinValue;
    self.lightLevel.maxValue = self.lightLevel.absMinValue;
    self.lightLevel.curValue += 1;
    self.lightLevel.curValue -= 1;
}

- (IBAction)resetVariationFrequency:(id)sender
{
    NSLog(@"resetVariationFrequency");
    self.variationFrequency.minValue = self.variationFrequency.absMinValue;
    self.variationFrequency.maxValue = self.variationFrequency.absMinValue;
    self.variationFrequency.curValue += 1;
    self.variationFrequency.curValue -= 1;
}

- (IBAction)changeVariationSensitivity:(id)sender
{
    NSSegmentedControl *ctl = (NSSegmentedControl *)sender;
    NSInteger idx = ctl.selectedSegment;
    NSLog(@"changeVariationSensitivity %ld", idx);
    float delta = (self.variationSensitivity.absMaxValue - self.variationSensitivity.absMinValue) / 20;
    if (idx == 2) {
        if (self.variationSensitivity.minValue > self.variationSensitivity.absMinValue) {
            self.variationSensitivity.minValue -= delta;
        }
        if (self.variationSensitivity.maxValue < self.variationSensitivity.absMaxValue) {
            self.variationSensitivity.maxValue += delta;
        }
    } else if (idx == 1) {
        self.variationSensitivity.minValue = self.lightLevel.minValue;
        self.variationSensitivity.maxValue = self.lightLevel.maxValue;
    } else if (idx == 0) {
        if (self.variationSensitivity.minValue < self.variationSensitivity.maxValue) {
            self.variationSensitivity.minValue += delta;
            self.variationSensitivity.maxValue -= delta;
        }
        if (self.variationSensitivity.minValue > self.variationSensitivity.maxValue) {
            self.variationSensitivity.minValue = self.variationSensitivity.maxValue;
        }
    }
    if (self.variationSensitivity.minValue < self.variationSensitivity.absMinValue) {
        self.variationSensitivity.minValue = self.variationSensitivity.absMinValue;
    }
    if (self.variationSensitivity.maxValue > self.variationSensitivity.absMaxValue) {
        self.variationSensitivity.maxValue = self.variationSensitivity.absMaxValue;
    }
    NSLog(@"changeVariationSensitivity now %f to %f",self.variationSensitivity.minValue, self.variationSensitivity.maxValue);
    // Force redraw
    self.variationSensitivity.curValue += 1;
    self.variationSensitivity.curValue -= 1;
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
    long rate = (((size+2*channels-1)/(2*channels))*1000000)/duration;
//    NSLog(@"rate=%ld", rate);
    mlm_samplerate(mlm, rate);
    mlm_threshold(mlm, 1);
    mlm_feed(mlm, sbuffer, size/2, channels);
    float ppLevel = mlm_amplitude(mlm, sbuffer, size/2, channels) / 32768.0;
    self.audioLevel.curValue = ppLevel;
    if (mlm_ready(mlm)) {
        // If we have light level data store it in the light level variables
        float min = mlm_min(mlm);
        float max = mlm_max(mlm);
        float cur = mlm_current(mlm);
        float avg = mlm_average(mlm);
        self.lightLevel.minValue = min;
        self.lightLevel.maxValue = max;
        self.lightLevel.curValue = cur;
        self.lightLevel.avgValue = avg;
        // Increase the maximum, if needed
        if (self.lightLevel.absMaxValue < max) self.lightLevel.absMaxValue *= 2;
        self.variationSensitivity.curValue = cur;
//        NSLog(@"min %f max %f avg %f cur %f", min, max, avg, cur);
        self.variationSensitivity.absMinValue = self.lightLevel.absMinValue;
        self.variationSensitivity.absMaxValue = self.lightLevel.absMaxValue;
        
        [self _updateVariationFrequency: cur at: timestamp];
    }
}

- (void) _updateVariationFrequency: (float)lightLevel at: (uint64_t)timestamp
{
    bool newIsBelowLow = lightLevel < self.variationSensitivity.minValue;
    if (newIsBelowLow && !isBelowLow) {
        // Have gone from above to below low.
        if (timestampLastTransitionToLow) {
            uint64_t deltaT = timestamp - timestampLastTransitionToLow;
            float freq = 1000000.0 / deltaT;
            NSLog(@"freq=%f", freq);
            if (freq < self.variationFrequency.minValue) {
                self.variationFrequency.minValue = freq;
            }
            if (freq > self.variationFrequency.maxValue) {
                self.variationFrequency.maxValue = freq;
            }
            self.variationFrequency.curValue = freq;
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
