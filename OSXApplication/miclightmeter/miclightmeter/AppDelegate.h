//
//  AppDelegate.h
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AudioInput.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property IBOutlet AudioInput *capturer;


@end

