//
//  ScanResult.m
//  Smartconfig
//
//  Created by WangBing on 2018/5/10.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "ScanResult.h"
#import "SmartConfigGlobalConfig.h"

@implementation ScanResult

+ (ScanResult*)scanResultWithDeviceSSID {
    ScanResult * scanResult = [ScanResult new];
    
    SmartConfigGlobalConfig * globalConfig = [SmartConfigGlobalConfig getInstance];
    scanResult.ssidName = [globalConfig fetchSSIDName];
    scanResult.securityType = SecurityType_UNKNOWN;
    
    return scanResult;
}

+ (ScanResult*)scanResultWithSSID:(NSString*)ssidName SecurityType:(SecurityType)secType {
    ScanResult * scanResult = [ScanResult new];
    
    scanResult.ssidName = ssidName;
    scanResult.securityType = secType;
    
    return scanResult;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ %@ %i", self.ssidName, self.password, self.securityType];
}

@end
