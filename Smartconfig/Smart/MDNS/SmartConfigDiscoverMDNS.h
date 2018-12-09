//
//  SmartConfigDiscoverMDNS.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#include <arpa/inet.h>

#import "SmartConfigGlobalConfig.h"

@interface SmartConfigDiscoverMDNS : NSObject<NSNetServiceBrowserDelegate>

@property (nonatomic) NSNetServiceBrowser *netServiceBrowser;

@property SmartConfigGlobalConfig * globalConfig;
@property (retain) NSMutableArray *netServices;

@property (nonatomic, retain) NSString *deviceName;

+(SmartConfigDiscoverMDNS *)getInstance;

- (void) emptyMDNSList;

- (void) startMDNSDiscovery:(NSString*)deviceName;

-(void) stopMDNSDiscovery;

@end
