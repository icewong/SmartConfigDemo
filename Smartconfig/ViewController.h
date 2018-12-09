//
//  ViewController.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <arpa/inet.h>
#import "Reachability.h"
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigDiscoverMDNS.h"
#import "FirstTimeConfig.h"
#import "ScanResult.h"
#import "GCDAsyncUdpSocket.h"
#import "SimplePing.h"
#import "SimplePingHelper.h"
@interface ViewController : UIViewController
{
    SmartConfigGlobalConfig * globalConfig;
    SmartConfigDiscoverMDNS * mdnsService;
    BOOL clearField;
    BOOL firstRunCheck;
    ScanResult * selectedScanResult;
    BOOL discoveryInProgress;
    BOOL waitingForConnectionToSimpleLinkForScanResults;
    BOOL waitingForConnectionToDeviceForConfirmation;
    BOOL waitingForConnectionToSSIDForMoveToDevicesTab;
    BOOL checkConnection;
    
    int versionFetchTryNumber;
}
@property ( nonatomic) FirstTimeConfig *firstTimeConfig;
@property (nonatomic) BOOL checkBoxBool;
@property (nonatomic) BOOL securityWifiBoxBool;
@property (nonatomic) BOOL discoveryInProgress;
@property (nonatomic, retain) Reachability *wifiReachability;
@property (retain, atomic) NSData *freeData;
@property (retain, atomic) NSString *passwordKey;
@property (weak, nonatomic) id ssidInfo;

@property (nonatomic) BOOL modifiedSSID;

@property (nonatomic) NSString * simpleLinkSSID;
@property (nonatomic) BOOL waitingForConnectionToSimpleLinkForCFGConfirmation;
@property (nonatomic) BOOL waitingForConnectionToSimpleLinkForAddingProfile;
@property (nonatomic) BOOL waitingForConnectionToSSIDForMDNS;
@property (nonatomic) BOOL waitingForConnectionToSSIDForMoveToDevicesTab;
@property (weak, nonatomic) NSTimer *updateTimer;


@property int progressTime;
@end

