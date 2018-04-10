//
//  test.h
//  retest
//
//  Created by Anthony Chollet on 10/04/2018.
//  Copyright © 2018 Raphael Sacle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABDHex.h"
#import "ABTBluetoothReader.h"

@interface test : NSObject


+(BOOL)authenticateWithReader:(ABTBluetoothReader*) bluetooth;
@end
