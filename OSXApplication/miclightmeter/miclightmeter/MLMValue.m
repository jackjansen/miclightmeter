//
//  MLMValue.m
//  miclightmeter
//
//  Created by Jack Jansen on 28/10/15.
//  Copyright © 2015 CWI. All rights reserved.
//

#import "MLMValue.h"

@implementation MLMValue
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"mlmvalue observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    NSLog(@"now mlmvalue observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%p", keyPath, object, change, context);
}

@end
