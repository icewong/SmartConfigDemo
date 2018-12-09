//
//  SmartConfig.h
//  SmartConfigDemo
//
//  Created by WangBing on 2018/7/4.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartConfigEncode.h"
@interface OSFailureException : NSException

@end



@interface SmartConfig : NSObject {
    
@private
    bool stopSending;
    NSCondition * stopSendingEvent;
    NSCondition * suspendSendingEvent;
    
    NSString * ip;
    NSString * ssid;
    NSString * key;
    int numberOfTries;
    
    int nSetup;
    int nSync;
    
    useconds_t delay;
    NSData * encryptionKey;
    NSData * encryptionKeyPart1;
    NSData * encryptionKeyPart2;
    SmartConfigEncode * ftcData;
    NSData * sockAddr;
    
    int listenSocket;
    int abortWaitForAckEvent[2];
    short listenPort;
    
    NSThread * sendingThread;
    NSCondition * stoppedSending;
    NSCondition * watchdogFinished;
    NSCondition * ackThreadFinished;
    
    bool isWatchdogRunning;
    bool isSuspended;
    
    const NSString * remoteDeviceName;

}
@property (strong) NSMutableData * sync1;
@property (strong) NSMutableData * sync2;
@end
