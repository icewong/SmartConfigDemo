//
//  ScanResult.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/10.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartconfigMacro.h"

@interface ScanResult : NSObject

@property (assign) SecurityType securityType;
@property (nonatomic, strong) NSString * ssidName;
@property (nonatomic, strong) NSString * password;

+ (ScanResult*)scanResultWithDeviceSSID;
+ (ScanResult*)scanResultWithSSID:(NSString*)ssidName SecurityType:(SecurityType)secType;
@end
