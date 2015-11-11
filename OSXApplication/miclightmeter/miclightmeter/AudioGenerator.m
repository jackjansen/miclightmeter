//
//  AudioGenerator.m
//  miclightmeter
//
//  Created by Jack Jansen on 09/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AudioGenerator.h"
#import "mlmlib.h"

@interface AudioGenerator () {
    NSMutableData *audioData;
    AVAudioPlayer *player;
}
@end

@implementation AudioGenerator

- (IBAction)changed:(id)sender
{
    NSLog(@"audiogenerator.changed level=%f variation=%f frequency=%f", self.lightLevel, self.levelVariation, self.variationFrequency);
    int bufferSize = mlm_generate(NULL, 0, self.lightLevel-self.levelVariation, self.lightLevel+self.levelVariation, self.variationFrequency, 1);
    assert(bufferSize > 0);
    audioData = [NSMutableData dataWithLength: bufferSize];
    assert(audioData);
    int bs2 = mlm_generate((short *)audioData.mutableBytes, bufferSize, self.lightLevel-self.levelVariation, self.lightLevel+self.levelVariation, self.variationFrequency, 1);
    assert(bs2 == bufferSize);
    /*xxxjack*/int fp = creat("/tmp/sample.wav", 0666); write(fp,audioData.mutableBytes, bufferSize); close(fp);
    // Start playing new sample
    if (player) {
        [player stop];
    }
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithData:audioData fileTypeHint:AVFileTypeWAVE error:&error];
    if (player == nil || error) {
        NSLog(@"AVAudioPlayer error %@", error);
        return;
    }
    player.numberOfLoops = -1;
    [player play];
}

@end
