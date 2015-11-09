//
//  AudioGenerator.m
//  miclightmeter
//
//  Created by Jack Jansen on 09/11/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "AudioGenerator.h"

@implementation AudioGenerator

- (IBAction)changed:(id)sender
{
    NSLog(@"audiogenerator.changed level=%f variation=%f frequency=%f", self.lightLevel, self.levelVariation, self.variationFrequency);
}

@end
