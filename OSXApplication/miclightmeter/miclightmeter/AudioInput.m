//
//  AudioInput.m
//  miclightmeter
//
//  Created by Jack Jansen on 29/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "AudioInput.h"

#define showErrorAlert(x) NSLog(@"Error %@", x)

@implementation AudioInput
@synthesize deviceID;
@synthesize deviceName;

- (AudioInput *)init
{
    NSLog(@"AudioInput init");
    self = [super init];
    if (self) {
        deviceID = nil;
        deviceName = nil;
        outputCapturer = nil;
        session = nil;
        sampleBufferQueue = dispatch_queue_create("Audio Sample Queue", DISPATCH_QUEUE_SERIAL);
        [self _initDevice];
    }
    return self;
}

- (void)_initDevice
{
    // Clean up old session
    if (session) {
        [session stopRunning];
        session = nil;
    }
    deviceID = nil;
    deviceName = nil;
    
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (dev == nil) return;
    session = [[AVCaptureSession alloc] init];
    if(session == nil) return;

    NSError *error;
    AVCaptureDeviceInput *myInput = [AVCaptureDeviceInput deviceInputWithDevice:dev error:&error];
    if (error) {
        showErrorAlert(error);
        return;
    }
    [session addInput: myInput];
    outputCapturer = [[AVCaptureAudioDataOutput alloc] init];
    [outputCapturer setSampleBufferDelegate: self queue:sampleBufferQueue];
    [session addOutput: outputCapturer];
#if !TARGET_OS_IPHONE
    if ([outputCapturer respondsToSelector:@selector(audioSettings)]) {
        // Not available on iOS. We chance it.
        // XXXJACK Should catch AVCaptureSessionRuntimeErrorNotification
        // Set the parameters so that we get the samples in a format we understand.
        // Unfortunately, setting to 'mono' doesn't seem to work, at least not consistently...
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                  [NSNumber numberWithFloat:44100], AVSampleRateKey,
                                  //		[NSNumber numberWithUnsignedInteger:1], AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                  [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                  [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                  //		[NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                  nil];
        [outputCapturer setAudioSettings: settings];
    }
#endif
    // Finally set device name for display
    deviceID = dev.modelID;
    deviceName = dev.localizedName;

}

- (void)startCapturing
{
    [session startRunning];
}

- (void)stopCapturing
{
    [session stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.delegate == nil) return;
    // Determine input level for VU-meter
    float db = 0;
    AVCaptureConnection *conn = [outputCapturer.connections objectAtIndex: 0];
    AVCaptureAudioChannel *ch;
    for (ch in conn.audioChannels) {
        db += ch.averagePowerLevel;
    }
    db /= [connection.audioChannels count];
    float level = (pow(10.f, 0.05f * db) * 20.0f);
    [self.delegate reportAudioLevel: level];

    // Get the audio data and timestamp
    
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
    {
        NSLog( @"sample buffer is not ready. Skipping sample" );
        return;
    }
    if( CMSampleBufferMakeDataReady(sampleBuffer) != noErr)
    {
        NSLog( @"Cannot make data ready. Skipping sample" );
        return;
    }
    
    CMTime durationCMT = CMSampleBufferGetDuration(sampleBuffer);
    durationCMT = CMTimeConvertScale(durationCMT, 1000000, kCMTimeRoundingMethod_Default);
    UInt64 duration = durationCMT.value;
    
    CMTime timestampCMT = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    timestampCMT = CMTimeConvertScale(timestampCMT, 1000000, kCMTimeRoundingMethod_Default);
    UInt64 timestamp = timestampCMT.value;
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    OSType format = CMFormatDescriptionGetMediaSubType(formatDescription);
    assert(format == kAudioFormatLinearPCM);
    
    CMBlockBufferRef bufferOut = nil;
    size_t bufferListSizeNeeded = 0;
    AudioBufferList *bufferList = NULL;
    OSStatus err = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, &bufferListSizeNeeded, NULL, 0, NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &bufferOut);
    if (err == 0) {
        bufferList = malloc(bufferListSizeNeeded);
        err = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, bufferList, bufferListSizeNeeded, NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &bufferOut);
    }
    if (err == 0 && bufferList[0].mNumberBuffers == 1) {
        // Pass to the manager
        [self.delegate newInputDone: bufferList[0].mBuffers[0].mData
                              size: bufferList[0].mBuffers[0].mDataByteSize
                          channels: bufferList[0].mBuffers[0].mNumberChannels
                                at: timestamp
                          duration: duration];
    } else {
        NSLog(@"AudioInput: CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer returned err=%d, mNumberBuffers=%d", (int)err, (unsigned int)(bufferList?bufferList[0].mNumberBuffers:-1));
    }
    if (bufferOut) CFRelease(bufferOut);
    if (bufferList) free(bufferList);
}

@end
