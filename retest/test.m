//
//  test.m
//  retest
//
//  Created by Anthony Chollet on 10/04/2018.
//  Copyright © 2018 Raphael Sacle. All rights reserved.
//

#import "test.h"
#import "ABTAcr1255uj1Reader.h"

@implementation test

+(BOOL)authenticateWithReader:(ABTBluetoothReader*) bluetooth{
    NSUserDefaults* _defaults = [NSUserDefaults standardUserDefaults];
    NSData *_masterKey = [_defaults dataForKey:@"MasterKey"];
    if (_masterKey == nil) {
        _masterKey = [ABDHex byteArrayFromHexString:@"FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"];
    }
    
    BOOL bresult = false;
    @try{
        bresult = [((ABTAcr1255uj1Reader*)bluetooth) authenticateWithMasterKey:_masterKey];
    }
    @catch (NSException* e){
        NSLog(@"%@",e.description);
    }
    
    return bresult;
//    return [((ABTAcr1255uj1Reader*)bluetooth) authenticateWithMasterKey:[ABDHex getMasterKey:@"FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"] length:16];
}

@end
