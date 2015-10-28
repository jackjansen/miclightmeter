//
//  MLMModel.h
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLMValue.h"

@interface MLMModel : NSObject
@property MLMValue* audioLevel;
@property MLMValue* lightLevel;
@property MLMValue* variationSensitivity;
@property MLMValue* variationFrequency;

- (IBAction)resetLightLevel:(id)sender;
- (IBAction)resetVariationFrequency:(id)sender;
- (IBAction)changeVariationSensitivity:(id)sender;
@end
