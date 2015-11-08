//
//  AudioInput.h
//  miclightmeter
//
//  Created by Jack Jansen on 29/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioInputDelegate
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

@interface AudioInput : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureAudioDataOutput *outputCapturer;
    AVCaptureSession *session;
    dispatch_queue_t sampleBufferQueue;
    NSString *deviceID;
    NSString *deviceName;
}

@property (readonly) NSString *deviceID;
@property (readonly) NSString *deviceName;
@property IBOutlet NSObject<AudioInputDelegate>* delegate;

- (void) _initDevice;
- (void) startCapturing;
- (void) stopCapturing;

@end
