//
//  SmartconfigManager.m
//  Smartconfig
//
//  Created by WangBing on 2018/5/11.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "SmartconfigManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <UIKit/UIKit.h>
#import "SmartConfigGlobalConfig.h"
#import "SmartConfigDiscoverMDNS.h"
#import "SimpleLinkNetwokUtil.h"
#import "SimplePing.h"
#import "SimplePingHelper.h"
#import "SmartConfigModel.h"
#import "FirstTimeConfig.h"
#import "ScanResult.h"
#import "GCDAsyncUdpSocket.h"
#import "SmartconfigMacro.h"
#import "NetworkHelper.h"

#import "Reachability.h"
#import "AFHTTPSessionManager.h"




@interface SmartconfigManager()<GCDAsyncUdpSocketDelegate,SimplePingDelegate>
{
    SmartConfigGlobalConfig * globalConfig;
    SmartConfigDiscoverMDNS * mdnsService;
    ScanResult * selectedScanResult;
    Product_Version productVersion;
    GCDAsyncUdpSocket *udpSocket;
    
    NSString *addressResult;
    NSString *resultFromPing;
    NSString * ip;
    NSString *httpOrHttps;
    
    NSUserDefaults *preferences;
    BOOL isRunning;
    BOOL wrongPassword;

    NSTimer *timer;
    NSDate *timerDate;


}
@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)NSString *ssid;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, copy)NSString *uuidName;

@property (nonatomic, copy)NSString *encryptionKey;

@property (nonatomic) FirstTimeConfig *firstTimeConfig;

@property (nonatomic, retain) Reachability *wifiReachability;

@property (nonatomic) BOOL discoveryInProgress;

@property (retain, atomic) NSData *freeData;

@property (retain, atomic) NSString *passwordKey;

@property (weak, nonatomic) id ssidInfo;

@property (nonatomic) NSString * simpleLinkSSID;

@property (nonatomic) BOOL waitingForConnectionToSimpleLinkForCFGConfirmation;
@property (nonatomic) BOOL waitingForConnectionToSimpleLinkForAddingProfile;
@property (nonatomic) BOOL waitingForConnectionToSSIDForMDNS;
@property (nonatomic) BOOL waitingForConnectionToSSIDForMoveToDevicesTab;

@property (assign, nonatomic) float progress;
@property (assign, nonatomic) BOOL isSending;

@property int progressTime;
@end


@implementation SmartconfigManager


static SmartconfigManager* instance = nil;

+(instancetype)sharedInstance{

    @synchronized (self) {
        if(instance == nil){
            instance = [[SmartconfigManager alloc] init];
        }
    }
    return instance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    if(instance == nil){
        
        @synchronized (self) {
            if(instance == nil){
                instance = [super allocWithZone:zone];
            }
        }
    }
    return instance;
}
-(instancetype)init
{
    self = [super init];
    if(self)
    {
        [self initConfig];
        
    }
    return self;
}
- (void)initConfig
{
    globalConfig   = [SmartConfigGlobalConfig getInstance];
    mdnsService    = [SmartConfigDiscoverMDNS getInstance];
    wrongPassword  = NO;
    productVersion = -1;
    preferences    = [NSUserDefaults standardUserDefaults];
    udpSocket      = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                   delegateQueue:dispatch_get_main_queue()];
    [self startStopUdp];
    [self randomDeviceName];
    ScanResult * result = nil;
    result = [ScanResult new];;
    self.discoveryInProgress = NO;

    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability connectionRequired];
    [self.wifiReachability startNotifier];
    
    /*Listeners*/
    [self listenTo:@[@"deviceFound", kReachabilityChangedNotification]];
    [self setToInitialStateWithViewRefresh:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiStateComingBackFromBackground)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    if(netStatus==NotReachable)
    {

    }else if (netStatus==ReachableViaWiFi){
        NSString *ssidName=[globalConfig fetchSSIDName ];
        self.ssid = ssidName;
        SmartLog(@"Wi-Fi SSID Name:%@",ssidName);

    }
}

-(void)wifiStateComingBackFromBackground{
    
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    if(netStatus==NotReachable)
    {
       
    }
    else if (netStatus==ReachableViaWiFi){
        [self performSelector:@selector(fadeOutLabels) withObject:nil afterDelay:5.0f];
        ScanResult * result = nil;
        result = [ScanResult new];
        NSString *ssid=[globalConfig fetchSSIDName ];
        self.ssid = ssid;
    }
}
- (void)fadeOutLabels
{
    
}
- (void)setToInitialStateWithViewRefresh:(BOOL)viewRefresh {
    
}
- (void)startStopUdp
{
    if (isRunning)
    {
        // STOP udp echo server
        [udpSocket close];
        isRunning = false;
    }
    else
    {
        // START udp echo server
        int port = 1501;
        if (port < 0 || port > 65535)
        {
            port = 0;
        }
        NSError *error = nil;
        if (![udpSocket bindToPort:port error:&error])
        {
            return;
        }
        if (![udpSocket beginReceiving:&error])
        {
            [udpSocket close];
            return;
        }
        isRunning = YES;
    }
}
#pragma mark - Send Wi-Fi info
- (void)sendWifiInfo:(NSString *)ssId withPassword:(NSString *)password
{
    if(self.isSending)
    {
        return;
    }
    self.isSending = YES;
    self.ssid      = ssId;
    self.password  = password;
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    //Check to see if we are connected to wifi
    SmartLog(@"netStatus %ld",(long)netStatus);
    if (netStatus != ReachableViaWiFi) { // No activity if no wifi
        NSError *error = [self getCustomError:Smartconfig_NO_WIFI domain:Smart_Tip_NO_WIFI];
        [self smartConfigFinsihed:error result:NO];
    }else {
        ScanResult * result = nil;
        result = [ScanResult new];
        if ([self.password isEqual:@""] || self.password == nil) {
            result.ssidName     = self.ssid;
            result.password     = nil;
            result.securityType = SecurityType_OPEN;
            selectedScanResult  = result;
        }else{
            result.ssidName     = self.ssid;
            result.password     = self.password;
            result.securityType = SecurityType_UNKNOWN;
            selectedScanResult  = result;
        }
        SmartLog(@"ScanResult:%@",result);
        if(wrongPassword==YES){
            NSString *httpOrHttps =[[NSUserDefaults standardUserDefaults] stringForKey:@"httpType"];
            SmartLog(@"%@",httpOrHttps);
            SmartLog(@"Nice string ? : %@%@",httpOrHttps,BASE_URL);
            self.waitingForConnectionToSimpleLinkForAddingProfile=YES;
            [self getCFGResultWithUrl: [NSString stringWithFormat:@"%@%@",httpOrHttps,BASE_URL] MDNS:NO];
        }
        SmartLog(@"Starting SC procedure with SSID: %@  Password: %@", selectedScanResult.ssidName, selectedScanResult.password);
        
        if (![SmartConfigModel showSecurityKey])  {
            
            [self continueStartAction:nil];
        }
        else{
            if(self.encryptionKey.length==16)
            {
                [self continueStartAction:nil];
            }else{
                SmartLog(@"%lu",self.encryptionKey.length);
                NSError *error = [self getCustomError:Smartconfig_MaxLength_EncryptionKey domain:Smart_Tip_Encryption];
                [self smartConfigFinsihed:error result:NO];
            }
        }
    }
}

- (void)getCFGResultWithUrl:(NSString*)url MDNS:(BOOL)isFromMDNS {
    [SimpleLinkNetwokUtil getCGResultFromUrl:url WithCompletion:^(CFG_Result result) {
        [self hideLoader];
        SmartLog(@"CFG_Result:%d",result);
        switch (result) {
            case Success:
                //save device ip
                SmartLog(@"ip Address:%@",ip);
                [preferences setObject:ip forKey:@"deviceip"];
                [preferences synchronize];
                [self showSuccess];
                self.waitingForConnectionToSSIDForMoveToDevicesTab = NO;
//                [self httpGETOutOfTheBoxDeviceCheckRequest];
//                SmartLog(@"httpGETOutOfTheBoxDeviceCheckRequest fired");
                break;
            case Ap_Not_Found:
                [self showErrorWithMsg:ERROR_CFG_AP_NOT_FOUND_STRING];
                break;
            case Failure:
                [self showErrorWithMsg:ERROR_CFG_FAILURE_STRING];
                break;
            case Ip_Add_Fail:
                [self showErrorWithMsg:ERROR_CFG_IP_ADD_FAIL_STRING];
                break;
            case Not_Started:
                
                if (isFromMDNS) {
                    [self startManualProcedureWithSSID:SIMPLE_LINK_NETWORK_PREFIX];
                }
                else {
                    [self showErrorWithMsg:ERROR_CFG_NOT_STARTED];
                }
                
                break;
            case Time_Out:
                
                if (isFromMDNS) {
                    [self startManualProcedureWithSSID:SIMPLE_LINK_NETWORK_PREFIX];
                }
                else {
                    [self showErrorWithMsg:ERROR_CFG_TIME_OUT];
                }
                break;
            case Wrong_Password:
                if(wrongPassword==YES){
                    [self addProfile:Product_Version_R2];
                }else{
                    wrongPassword=YES;
                    [self showErrorWithMsg:ERROR_CFG_WRONG_PASSWORD_STRING];
                }
                break;
        }
    } TotalTries:CFG_TOTAL_TRIES];
}


- (void) continueStartAction:(UIButton*)button
{
    [mdnsService emptyMDNSList];
    self.progressTime = 0;
    [self startTransmitting];
}

- (void)startTransmitting{
    @try {
        [self connectLibrary];
        if (self.firstTimeConfig == nil) {
            return;
        }
        [self reallySend];
    }
    @catch (NSException *exception) {
        
        [self performSelectorOnMainThread:@selector(showErrorWithMsg:) withObject:[exception description] waitUntilDone:NO];
    }
    @finally {
    }
}


-(void) reallySend{
     SmartLog(@"********reallySend*******");
    @try {
        [self stopDiscovery];
        [self showBroadcastProgress];
        self.discoveryInProgress = YES;
        [mdnsService startMDNSDiscovery:self.deviceName];
        SmartLog(@"self.deviceName:%@",self.deviceName);
        [self.firstTimeConfig transmitSettings];
    }
    @catch (NSException *exception) {
        
        [self performSelectorOnMainThread:@selector(showErrorViewWithString:) withObject:[exception description] waitUntilDone:NO];
    }
    @finally {
        
    }
}


-(void)setUUID{
    

    if(self.uuidName !=nil ){
        NSString *address = [NSString stringWithFormat:@"http://mysimplelink.net/api/1/iotlink/uuid"];
        [SimpleLinkNetwokUtil setUuidToProfile:address UUID:self.uuidName];
    }
}

-(void) connectLibrary {
    
    @try {
        [self disconnectFromLibrary];
        self.passwordKey = [selectedScanResult.password length] ? selectedScanResult.password : nil;
        NSString *paddedEncryptionKey = self.encryptionKey;
        NSData *encryptionData = [self.encryptionKey length] ? [paddedEncryptionKey dataUsingEncoding:NSUTF8StringEncoding] : Nil;
        
        self.freeData = [NSData alloc];
        if ([self.deviceName length]) {
            char freeDataChar[[self.deviceName length] + 3];
            // prefix
            freeDataChar[0] = 3;
            // device name length
            freeDataChar[1] = [self.deviceName length];
            
            for(int i = 0; i < [self.deviceName length]; i++)
            {
                freeDataChar[i+2] = [self.deviceName characterAtIndex:i];
            }
            
            // added terminator
            freeDataChar[[self.deviceName length] + 2] = '\0';
            NSString *freeDataString = [[NSString alloc] initWithCString:freeDataChar encoding:NSUTF8StringEncoding];
            self.freeData = [freeDataString dataUsingEncoding:NSUTF8StringEncoding ];
        }
        else {
            self.freeData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSString *ipAddress = [FirstTimeConfig getGatewayAddress];
        SmartLog(@"%@ The encrypted data",encryptionData);
        self.firstTimeConfig = [[FirstTimeConfig alloc] initWithData:ipAddress
                                                            withSSID:selectedScanResult.ssidName
                                                             withKey:self.passwordKey
                                                        withFreeData:self.freeData
                                                   withEncryptionKey:encryptionData
                                                      numberOfSetups:4
                                                       numberOfSyncs:10
                                                         syncLength1:3
                                                         syncLength2:23
                                                 delayInMicroSeconds:10000];
        
    }
    @catch (NSException *exception) {
        
        [self performSelectorOnMainThread:@selector(showErrorViewWithString:) withObject:[exception description] waitUntilDone:NO];
    }
}

-(void)disconnectFromLibrary {
    self.firstTimeConfig = nil;
}
- (void)showBroadcastProgress {
    [self performSelector:@selector(advanceBroadcastProgesss) withObject:nil afterDelay:1];
}
- (void)advanceBroadcastProgesss
{
    float addAmount = 1.0 / SMART_CONFIG_TRANSMIT_TIME;
    self.progress += addAmount;
    
    if (!self.discoveryInProgress) {
        //device was found...
        SmartLog(@"Device was found in the middle of broadcast");
        return;
    }
    
    if (self.progress < 1)
        [self performSelector:@selector(advanceBroadcastProgesss) withObject:nil afterDelay:1];
    else {
        
        NSString * connectedSSID = [globalConfig fetchSSIDName];
        //[self.firstTimeConfig stopTransmitting];
        [self stopDiscovery];
        timerDate = [NSDate date];
        NSTimeInterval pingDelay =2; // delay of 2s from ping to ping
        // schedule it
        timer = [NSTimer scheduledTimerWithTimeInterval :pingDelay target:self selector:@selector(Ping:) userInfo:nil repeats:YES];
        self.progress = 0;
        if ([selectedScanResult.ssidName isEqualToString:connectedSSID]) {
            SmartLog(@"Broadcast was finished, starting MDNS");
            [self mDnsDiscoverStart];
        }
        else {
            [self startManualProcedureWithSSID:SIMPLE_LINK_NETWORK_PREFIX];
        }
    }
}
- (void)Ping:(NSTimer *)timer
{
    [self startPing];
    NSTimeInterval interval = -[timerDate timeIntervalSinceNow]; // return value will be negative, so change sign
    if(interval >= 15) {
        self->timer = nil;            // ARC way to release it
        timerDate = nil;
        [timer invalidate];
    }
}
#pragma mark -OutOfTheBox
-(void)httpGETOutOfTheBoxDeviceCheckRequest{
    NSString* deviceInfoUrl = [NSString stringWithFormat:@"http://%@/device?appname",ip];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = NETWORK_REQUEST_TIMEOUTS;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:deviceInfoUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        SmartLog(@"JSON: %@", responseObject);
        
        NSData * responseData = responseObject;
        NSString* responseString = [NSString stringWithUTF8String:[responseData bytes]];
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [responseString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            [queryStringDictionary setObject:value forKey:key];
            SmartLog(@"Key:%@",key);
            SmartLog(@"Value:%@",value);
            if([key containsString:@"appname"]){
                // self.currentSoftwareLabel.text=value;
                if ([value isEqualToString:@"out_of_box_fs"]) {
                    [self OutOfTheBoxDeviceType:@"F"];
                }
                if ([value isEqualToString:@"out_of_box_rs"]||[value isEqualToString:@"out_of_box"]) {
                    [self OutOfTheBoxDeviceType:@"S"];
                }
            }
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        SmartLog(@"Error: %@", error);
    }];
}

-(void)OutOfTheBoxDeviceType:(NSString*)deviceType{
    preferences=[NSUserDefaults standardUserDefaults];
    [preferences setObject:deviceType forKey:@"oobtype"];
    [preferences synchronize];
}


#pragma mark - Device Operation
- (void) deviceWasAdded:(NSDictionary*)device {
    SmartLog(@"Device found by bcast: %@", device);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceFound" object:device];
}
- (void) listenTo:(NSArray*)eventsArray {
    
    for (NSString * event in eventsArray) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:event object:nil];
    }
}
- (void)handleNotification:(NSNotification*)notification {
    
    if ([notification.name isEqualToString:@"deviceFound"]) {
        if (self.discoveryInProgress)
        {
            SmartLog(@"Device found, discoveryInProgress = YES");
        }else
        {
            SmartLog(@"Device found, discoveryInProgress = NO");
        }
        if (self.discoveryInProgress == YES) {
            [self stopDiscovery];
            [self showLoaderWithMsg:@"Checking results"];
            SmartLog(@"When find the device you should do like this:getCFG");
            [self getCFGResultWithUrl:notification.object[@"url"] MDNS:YES];
        }
    }
    if (notification.name == kReachabilityChangedNotification) {
        Reachability * noteObject = notification.object;
        NSString * connectedSSID = [globalConfig fetchSSIDName];
        self.ssid = connectedSSID;
        switch (noteObject.currentReachabilityStatus) {
            case NotReachable:
                SmartLog(@"NotReachable");
                break;
            case ReachableViaWiFi:
                SmartLog(@"ReachableViaWiFi");
                break;
            case ReachableViaWWAN:
                SmartLog(@"ReachableViaWWAN");
                break;
        }
    }
}

#pragma mark - MDNS Discovery
- (void)mDnsDiscoverStart {
    [self showMDNSProgress];
    self.discoveryInProgress = YES;
    [mdnsService startMDNSDiscovery:self.deviceName];
}

- (void)showMDNSProgress {

    [self performSelector:@selector(advanceMDNSProgesss) withObject:self afterDelay:1];
}

- (void)advanceMDNSProgesss
{
    float addAmount = 1.0 / MDNS_SCAN_TIME;
    self.progress += addAmount;
    
    if (!self.discoveryInProgress) {
        //device was found...
        SmartLog(@"Device was found in the middle of MDNS scan");
        return;
    }
    
    if (self.progress < 1)
        [self performSelector:@selector(advanceMDNSProgesss) withObject:self afterDelay:1];
    else {
        SmartLog(@"MDNS was finished");
        [self stopDiscovery];
        self.progress = 0;
        [self startManualProcedureWithSSID:SIMPLE_LINK_NETWORK_PREFIX];
    }
}

-(void)stopDiscovery {
    SmartLog(@"Stopping transmitiing & MDNS scanning");
    self.discoveryInProgress = NO;
    [self.firstTimeConfig stopTransmitting];
    [mdnsService stopMDNSDiscovery];
}

- (void)startManualProcedureWithSSID:(NSString*)ssidName {
    self.waitingForConnectionToSimpleLinkForAddingProfile = YES;
    [self showInstructionsWithNetwork:ssidName];
}


#pragma mark - Ping

- (void)startPing {
    
    SmartLog(@"*****************");
    SmartLog(@"PING IS RUNNING!");
    SmartLog(@"*****************");
    NSString *routerIp=[self getIPAddress];
    
    NSScanner* scanner = [NSScanner scannerWithString:routerIp];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    int a, b, c;
    [scanner scanInt:&a];
    [scanner scanInt:&b];
    [scanner scanInt:&c];
    NSString* result = [NSString stringWithFormat:@"%d.%d.%d.255", a, b, c];
    [SimplePingHelper ping:result target:self sel:@selector(pingResult:)];
    addressResult=result;
}
- (void)pingResult:(NSNumber*)success {
    
    if (success.boolValue) {
        //parsing the result we get from the packet
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pingResultNotification:) name:@"pingResult" object:nil];
        if(resultFromPing!=nil){
            NSArray *listItems = [resultFromPing componentsSeparatedByString:@","];
            NSString * deviceNameToAdd = [listItems objectAtIndex:0]; //device name
            NSString * ip = [listItems objectAtIndex:1];//ip address
            // keep those logs commented unless you want to check the parameters we getting from ping
            SmartLog(@"(PING) Device Name :%@",deviceNameToAdd);
            SmartLog(@"(PING) IP ADDRESS :%@",ip);
            if(self.deviceName==deviceNameToAdd){
                SmartLog(@"Device found (PING):%@  = %@",self.deviceName,deviceNameToAdd);
                NSString *address = [NSString stringWithFormat:@"http://%@:%u", ip,80];
                NSDictionary *device = [NSMutableDictionary dictionaryWithCapacity:3];
                [device setValue:deviceNameToAdd forKey:@"name"];
                NSDate *now = [NSDate date];
                [device setValue:now forKey:@"date"];
                [device setValue:address forKey:@"url"];
                [device setValue:[NSNumber numberWithBool:YES] forKey:@"recent"];
                NSUInteger deviceCount = [[globalConfig getDevices] count];
                [globalConfig addDevice:device withKey:deviceNameToAdd];
                // check if we have more than one device
                if([[globalConfig getDevices] count] > deviceCount) {
                    // a new device was added
                    [self deviceWasAdded:device];
                    SmartLog(@"*************************");
                    SmartLog(@"**DEVICE FOUND VIA PING**");
                    SmartLog(@"*************************");
                }
            }
        }
    }
    
    else {
        
    }
}
/*ping : the result we getting from simplePingHelper in didReceivePackets*/
- (void) pingResultNotification:(NSNotification *)notification{
    resultFromPing= [notification object];
    
}
/**
 *  getting IP of the connected router
 *
 *  @return connected router IP
 */
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark Popups

- (void)showInstructionsWithNetwork:(NSString*)network {
    
    NSString * connectedSSID = [globalConfig fetchSSIDName];
    SmartLog(@"Showing Instruction view for SSID:%@\nConnected ssid:%@\nwaitingForConnectionToSimpleLinkForCFGConfirmation = %@\nwaitingForConnectionToSimpleLinkForAddingProfile = %@\nwaitingForConnectionToSSIDForMDNS = %@\nwaitingForConnectionToSSIDForMoveToDevicesTab = %@", network, connectedSSID, @(self.waitingForConnectionToSimpleLinkForCFGConfirmation), @(self.waitingForConnectionToSimpleLinkForAddingProfile), @(self.waitingForConnectionToSSIDForMDNS), @(self.waitingForConnectionToSSIDForMoveToDevicesTab));
    
    NSRange range = [connectedSSID rangeOfString:network];
    if (connectedSSID && range.location != NSNotFound) {
        [self instructionViewOkTapped:nil];
    }
    else {
        
         NSError *error = [self getCustomError:Smartconfig_Failed domain:@"Cool Failed."];
        [self smartConfigFinsihed:error result:NO];
    }
}

- (void)instructionViewOkTapped:(UIView *)_instructionView {
    
    NSString *httpOrHttps =[[NSUserDefaults standardUserDefaults] stringForKey:@"httpType"];
    if (self.waitingForConnectionToSSIDForMoveToDevicesTab) {
        SmartLog(@"waitingForConnectionToSSIDForMoveToDevicesTab = YES");
        self.waitingForConnectionToSSIDForMoveToDevicesTab = NO;
    }
    else if (self.waitingForConnectionToSimpleLinkForCFGConfirmation) {
        SmartLog(@"waitingForConnectionToSimpleLinkForCFGConfirmation = YES");
        self.waitingForConnectionToSimpleLinkForCFGConfirmation = NO;
        SmartLog(@"%@",httpOrHttps);
        SmartLog(@"Nice string ? : %@%@",httpOrHttps,BASE_URL);
        [self getCFGResultWithUrl:[NSString stringWithFormat:@"%@%@",httpOrHttps,BASE_URL] MDNS:NO];
    }
    else if (self.waitingForConnectionToSSIDForMDNS) {
        SmartLog(@"waitingForConnectionToSSIDForMDNS = YES");
        self.waitingForConnectionToSSIDForMDNS = NO;
        [self continueStartAction:nil];
    }
    else if (self.waitingForConnectionToSimpleLinkForAddingProfile) {
        SmartLog(@"waitingForConnectionToSimpleLinkForAddingProfile = YES");
        self.waitingForConnectionToSimpleLinkForAddingProfile = NO;
        
        [self showLoaderWithMsg:LOADER_CHECK_DEVICE_VERSION];
        [SimpleLinkNetwokUtil getProductVersionFromUrl:[NSString stringWithFormat:@"%@%@",httpOrHttps,BASE_URL] WithCompletion:^(Product_Version version) {
            switch (version) {
                case Product_Version_Unkown:
                    [self hideLoader];
                    [self showErrorWithMsg:UNKNOWN_DEVICE_VERSION_MSG];
                    break;
                case Product_Version_R1:
                case Product_Version_R2:
                    productVersion=Product_Version_R2;
                    [self showLoaderWithMsg:LOADER_CHECK_DEVICE_STATE];
                    [SimpleLinkNetwokUtil getCGResultFromUrl:[NSString stringWithFormat:@"%@%@",httpOrHttps,BASE_URL] WithCompletion:^(CFG_Result result) {
                        [self hideLoader];
                        
                        switch (result) {
                            case Success:
                                wrongPassword=NO;
                                [self showSuccess];
                                break;
                            case Ap_Not_Found:
                                [self showErrorWithMsg:ERROR_CFG_AP_NOT_FOUND_STRING];
                                break;
                            case Failure:
                                [self showErrorWithMsg:ERROR_CFG_FAILURE_STRING];
                                break;
                            case Ip_Add_Fail:
                                [self showErrorWithMsg:ERROR_CFG_IP_ADD_FAIL_STRING];
                                break;
                            case Not_Started:
                            case Time_Out:
                                
                                if (![self.deviceName isEqualToString:@""]) {
                                    [self showLoaderWithMsg:[NSString stringWithFormat:@"Changing device name to %@", self.deviceName]];
                                    [SimpleLinkNetwokUtil setDeviceNameFromUrl:[NSString stringWithFormat:@"%@%@",httpOrHttps,BASE_URL] Name:self.deviceName ProductVersion:version WithCompletion:^(NSString *errorMsg) {
                                        if (errorMsg) {
                                            [self hideLoader];
                                            [self showErrorWithMsg:ERROR_SET_DEVICE_NAME];
                                        }
                                        else {
                                            
                                            //                                            if( uuidNameALHeight.constant>0){
                                            //                                                [self setUUID];
                                            //}
                                            [self addProfile:version];
                                        }
                                    }];
                                }
                                else {
                                    //                                    if( uuidNameALHeight.constant>0){
                                    //                                        [self setUUID];
                                    //                                    }
                                    [self addProfile:version];
                                }
                                
                                break;
                            case Wrong_Password:
                                wrongPassword=YES;
                                [self showErrorWithMsg:ERROR_CFG_WRONG_PASSWORD_STRING];
                                break;
                        }
                    } TotalTries:CFG_TOTAL_TRIES];
                    break;
            }
        }];
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    
     NSLog(@"=====receiveData=======%@",data);
        NSLog(@"receive data = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if (!isRunning) return;
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        //spliting msg string  into two string :address and device name
        NSArray *listItems = [msg componentsSeparatedByString:@","];
        ip = [listItems objectAtIndex:0]; //ip address
        NSString * deviceName = [listItems objectAtIndex:1]; //device name
        //keep those logs commented unless you want to check the ip address and device name parameters we getting from the udp
        SmartLog(@"IP address :%@",ip);
        SmartLog(@"Device Name :%@",deviceName);
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        NSString *address = [NSString stringWithFormat:@"http://%@:%u", ip,80];
        SmartLog(@"address :%@",address);
        
        NSDictionary *device = [NSMutableDictionary dictionaryWithCapacity:3];
        [device setValue:deviceName forKey:@"name"];
        NSDate *now = [NSDate date];
        [device setValue:now forKey:@"date"];
        [device setValue:address forKey:@"url"];
        [device setValue:[NSNumber numberWithBool:YES] forKey:@"recent"];
        
        NSUInteger deviceCount = [[globalConfig getDevices] count];
        SmartLog(@"Begin AddDevice %@",device);
        [globalConfig addDevice:device withKey:deviceName];
        // check if we have more than one device
        if([[globalConfig getDevices] count] > deviceCount) {
            // a new device was added
            [self deviceWasAdded:device];
            SmartLog(@"************************");
            SmartLog(@"**DEVICE FOUND VIA UDP**");
            SmartLog(@"************************");
        }
        
    }
    else
    {
        SmartLog(@"Error converting received data into UTF-8 String");
    }
    //[udpSocket close];
    //[udpSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}


- (void)hideLoader {

}
- (void)showErrorWithMsg:(NSString *)msg {
    [self finish];
}

- (void)finish {
    [self setToInitialStateWithViewRefresh:YES];
}
- (void)showSuccess
{
    [self smartConfigFinsihed:nil result:YES];
}

- (void)showLoaderWithMsg:(NSString*)msg {
}
- (void)addProfile:(Product_Version)version {
    
    self.simpleLinkSSID = [globalConfig fetchSSIDName];
    [self showLoaderWithMsg:LOADER_ADDING_PROFILE];
    [SimpleLinkNetwokUtil startAddingProfileProcedureFromUrl:[NSString stringWithFormat:@"%@%@",httpOrHttps,BASE_URL] SSID:selectedScanResult.ssidName Password:selectedScanResult.password ProductVersion:version Security:selectedScanResult.securityType WithCompletion:^(NSString *errorMsg) {
        [self hideLoader];
        if (errorMsg) {
            [self showErrorWithMsg:ERROR_ADDING_PROFILE];
        }
        else {
            SmartLog(@"Profile added - Waiting to %@", selectedScanResult.ssidName);
            [self showWaitingProgress];
        }
    }];
}

- (void)showWaitingProgress {
    [self performSelector:@selector(advanceWaitingProgress) withObject:nil afterDelay:1];
}

- (void)advanceWaitingProgress{
    float addAmount = 1.0 / SC_AFTER_ADD_PROFILE_WAITING_TIME;
    self.progress += addAmount;
    if (self.progress < 1)
    {
        if([[globalConfig fetchSSIDName] isEqualToString:selectedScanResult.ssidName]){
            [self mDnsDiscoverStart];
            [self startPing];
        }
        else{
            [self performSelector:@selector(advanceWaitingProgress) withObject:nil afterDelay:1];
        }
    }
    else {
        
        if([[globalConfig fetchSSIDName] isEqualToString:selectedScanResult.ssidName]){
            [self mDnsDiscoverStart];
            [self startPing];
        }
        else{
            self.waitingForConnectionToSimpleLinkForCFGConfirmation = YES;
            [self showInstructionsWithNetwork:self.simpleLinkSSID];
        }
    }
}
- (NSString *)getSsidName
{
    return self.ssid;
}
-(void)randomDeviceName
{
     if([SmartConfigModel showDeviceName])
     {
         int randomNumber = rand() % 999;
         self.deviceName=[NSString stringWithFormat:@"dev-%i",randomNumber];
     }
}
#pragma mark - Error

-(NSError *)getCustomError:(NSInteger)code domain:(NSString *)domain
{
    NSError *error =[[NSError alloc]initWithDomain:domain code:code userInfo:nil];
    return error;
}

- (void)showErrorViewWithString:(NSString*)message {
    
    NSError *error = [self getCustomError:Smartconfig_NSException domain:message];
    [self smartConfigFinsihed:error result:NO];
}
- (void)smartConfigFinsihed:(NSError *)error result:(BOOL)result
{
    if(self.smartconfigFinishBlock)
    {
        self.isSending = NO;
        self.smartconfigFinishBlock(error, result);
    }
}
@end
