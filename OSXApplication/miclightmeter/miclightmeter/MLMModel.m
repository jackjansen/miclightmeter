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
}
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
    self.audioLevel.belowMinColor = [NSColor yellowColor];
    self.audioLevel.midColor = [NSColor greenColor];
    self.audioLevel.aboveMaxColor = [NSColor yellowColor];
    
    self.lightLevel.absMinValue = 0.0;
    self.lightLevel.absMaxValue = 100.0;
    self.lightLevel.minValue = 40.0;
    self.lightLevel.maxValue = 80.0;
    self.lightLevel.curValue = 50;
    self.lightLevel.belowMinColor = [NSColor yellowColor];
    self.lightLevel.midColor = [NSColor greenColor];
    self.lightLevel.aboveMaxColor = [NSColor yellowColor];
    
    self.variationSensitivity.absMinValue = 0.0;
    self.variationSensitivity.absMaxValue = 100.0;
    self.variationSensitivity.minValue = 40.0;
    self.variationSensitivity.maxValue = 80.0;
    self.variationSensitivity.curValue = 50;
    self.variationSensitivity.belowMinColor = [NSColor yellowColor];
    self.variationSensitivity.midColor = [NSColor greenColor];
    self.variationSensitivity.aboveMaxColor = [NSColor yellowColor];
    
    self.variationFrequency.absMinValue = 0.0;
    self.variationFrequency.absMaxValue = 100.0;
    self.variationFrequency.minValue = 40.0;
    self.variationFrequency.maxValue = 80.0;
    self.variationFrequency.curValue = 50;
    self.variationFrequency.belowMinColor = [NSColor yellowColor];
    self.variationFrequency.midColor = [NSColor greenColor];
    self.variationFrequency.aboveMaxColor = [NSColor yellowColor];
    
}

- (IBAction)resetLightLevel:(id)sender
{
    mlm_reset(mlm);
    self.lightLevel.minValue = self.lightLevel.curValue;
    self.lightLevel.maxValue = self.lightLevel.curValue;
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
    assert(size > 0);
    assert(buffer);
    assert((size&1) == 0);
    
    if (size == 0 || size &1 || buffer == NULL) return;
    long rate = ((size/2)*1000000)/duration;
    NSLog(@"rate=%ld", rate);
    mlm_samplerate(mlm, rate);
    mlm_threshold(mlm, 32768 / 10);
    mlm_feed(mlm, (short *)buffer, size/2, channels);
    float ppLevel = mlm_amplitude(mlm, (short *)buffer, size/2, channels) / 32768.0;
    self.audioLevel.curValue = ppLevel;
    if (mlm_ready(mlm)) {
        self.lightLevel.minValue = mlm_min(mlm);
        if (self.lightLevel.absMinValue > self.lightLevel.minValue) self.lightLevel.absMinValue = self.lightLevel.minValue;
        self.lightLevel.maxValue = mlm_max(mlm);
        if (self.lightLevel.absMaxValue > self.lightLevel.maxValue) self.lightLevel.absMaxValue = self.lightLevel.maxValue;
        self.lightLevel.curValue = mlm_average(mlm);
        NSLog(@"min %f max %f avg %f", mlm_min(mlm), mlm_max(mlm), mlm_average(mlm));
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"mlmmodel observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    NSLog(@"now mlmmodel observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
}
@end
