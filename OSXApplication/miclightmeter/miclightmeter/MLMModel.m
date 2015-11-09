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
    struct mlm *lightMeter;
    struct mlm *modulationMeter;
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
        lightMeter = mlm_new();
        modulationMeter = mlm_new();
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
    self.lightLevel.absMaxValue = 100.0;
    self.lightLevel.minValue = 0;
    self.lightLevel.maxValue = 0;
    self.lightLevel.curValue = 0;
    self.lightLevel.valid = NO;
    
    self.lightModulation.absMinValue = 0.0;
    self.lightModulation.absMaxValue = 1000.0;
    self.lightModulation.minValue = 0;
    self.lightModulation.maxValue = 0;
    self.lightModulation.curValue = 0;
    self.lightModulation.valid = NO;
    
}

- (IBAction)resetLightLevel:(id)sender
{
    mlm_reset(lightMeter);
    self.lightLevel.minValue = self.lightLevel.absMinValue;
    self.lightLevel.maxValue = self.lightLevel.absMinValue;
    self.lightLevel.curValue += 1;
    self.lightLevel.curValue -= 1;
    self.lightLevel.valid = NO;
    [self resetLightModulation: self];
}

- (IBAction)resetLightModulation:(id)sender
{
    NSLog(@"resetLightModulation");
    mlm_reset(modulationMeter);
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
    mlm_feedint(lightMeter, sbuffer, size, 2, channels);
    float ppLevel = mlm_amplitude(lightMeter);
    self.audioLevel.curValue = ppLevel;
    self.audioLevel.valid = YES;
    if (mlm_ready(lightMeter)) {
        // We measure periods (with a value of 1 being 1/samplefreq seconds), but we want
        // the scale to be increasing light levels to the right, so we invert.
        float min = self.lightLevel.absMaxValue - mlm_max(lightMeter);
        float max = self.lightLevel.absMaxValue - mlm_min(lightMeter);
        float cur = self.lightLevel.absMaxValue - mlm_current(lightMeter);
        float avg = self.lightLevel.absMaxValue - mlm_average(lightMeter);
        self.lightLevel.minValue = min;
        self.lightLevel.maxValue = max;
        self.lightLevel.curValue = cur;
        self.lightLevel.avgValue = avg;
        self.lightLevel.valid = YES;
        // Update modulation
        while ((cur=mlm_consume(lightMeter)) > 0) {
            [self _updateLightModulation: cur at: timestamp];
        }
    }
}

- (void) _updateLightModulation: (float)lightLevel at: (uint64_t)timestamp
{
    mlm_feedmodulation(modulationMeter, lightLevel);
//    NSLog(@"lightLevel %f", lightLevel);
    if (mlm_ready(modulationMeter)) {
        float min = 44100.0 / mlm_max(modulationMeter);
        float max = 44100.0 / mlm_min(modulationMeter);
        float cur = 44100.0 / mlm_current(modulationMeter);
        float avg = 44100.0 / mlm_average(modulationMeter);
        self.lightModulation.minValue = min;
        self.lightModulation.maxValue = max;
        self.lightModulation.curValue = cur;
        self.lightModulation.avgValue = avg;
        self.lightModulation.valid = YES;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
//    NSLog(@"mlmmodel observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    NSLog(@"now mlmmodel observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
}
@end
