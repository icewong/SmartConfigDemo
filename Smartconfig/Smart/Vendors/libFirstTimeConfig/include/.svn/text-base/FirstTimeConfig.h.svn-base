/* 
 * Copyright (C) 2015 Texas Instruments Incorporated - http://www.ti.com/
 *
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *    Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 *
 *    Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import <Foundation/Foundation.h>
#import "FtcEncode.h"

@interface OSFailureException : NSException

@end

@interface FirstTimeConfig : NSObject {
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

/*    NSMutableData * sync1;
    NSMutableData * sync2;
*/
    NSData * encryptionKey;
    NSData * encryptionKeyPart1;
    NSData * encryptionKeyPart2;
    FtcEncode * ftcData;
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

/**************************************************************\
 * Method name: initWithKey
 * Purpose: This method creates new FirstTimeConfig instance
 * Parameters: In (NSString *)Key - The network key
 *             In OPT (NSData *)encryptionKey - The AES key to
 *             encrypt the nework key with. Can be nil if not used
 * Exceptions: OSFailureException
 * Return value: New FirstTimeConfig instance
\**************************************************************/
- (id)initWithKey:(NSString *)Key withEncryptionKey:(NSData *)encryptionKey;

/**************************************************************\
 * Method name: stopTransmitting
 * Purpose: This method used to stop transmitting.
 * Parameters: None
 * Exceptions: OSFailureException
 * Return value: None
\**************************************************************/
- (void)stopTransmitting;

/**************************************************************\
 * Method name: transmitSettings
 * Purpose: This method begins the settings transmit. The method
 *          Creates a new thread that do the actually the sending
 *          and returns immediately
 * Parameters: None
 * Exceptions: OSFailureException
 * Return value: None
\**************************************************************/
- (void)transmitSettings;

/**************************************************************\
 * Method name: isTransmitting
 * Purpose: This method returns if the instance is transmitting
 * Parameters: None
 * Exceptions: OSFailureException
 * Return value: The method returns true if the instance is 
 *               transmitting and false otherwise
\**************************************************************/
- (bool)isTransmitting;

/*************************************************************\
 * Method name: getSSID
 * Purpose: This method retreives the SSID of the currently
 *          connected WIFI
 * Parameters: None
 * Exceptions: None
 * Return value: The SSID of the WIFI network
\**************************************************************/
+ (NSString *)getSSID;

/*************************************************************\
 * Method name: getGatewayAddress
 * Purpose: This method retreives the gateway of the currently
 *          connected network
 * Parameters: None
 * Exceptions: None
 * Return value: The IP of the network's gateway
 \**************************************************************/
+ (NSString *)getGatewayAddress;


/* The following procedure can throw an OSFailureException exception */
- (id)initWithData:(NSString *)Ip withSSID:(NSString *)Ssid withKey:(NSString *)Key withFreeData:(NSData*)freeData withEncryptionKey:(NSData *)EncryptionKey numberOfSetups:(int)numOfSetups numberOfSyncs:(int)numOfSyncs syncLength1:(int)lSync1 syncLength2:(int)lSync2 delayInMicroSeconds:(useconds_t)uDelay;
@end
