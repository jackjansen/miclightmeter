//
//  MLMModel.h
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMValue.h"
#import "AudioInput.h"

@interface MLMModel : NSObject <AudioInputDelegate>
@property IBOutlet MLMValue* audioLevel;
@property IBOutlet MLMValue* lightLevel;
@property IBOutlet MLMValue* lightModulation;
@property IBOutlet AudioInput* capturer;

- (IBAction)resetLightLevel:(id)sender;
- (IBAction)resetLightModulation:(id)sender;

/// Signals that a capture cycle has ended and provides audio data.
/// @param buffer The audio data, as 16 bit signed integer samples
/// @param size Size of the buffer in bytes
/// @param channels Number of channels (1 for mono, 2 for stereo)
/// @param timestamp Timestamp in microseconds of the start of this sample
/// @param duration Duration of the sample in microseconds
///
- (void)newInputDone: (void*)buffer
                size: (int)size
            channels: (int)channels
                  at: (uint64_t)timestamp
            duration: (uint64_t)duration;
@end
