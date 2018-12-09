//
//  SmartConfigModel.m
//  Smartconfig
//
//  Created by WangBing on 2018/5/10.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "SmartConfigModel.h"
#import "SmartconfigMacro.h"
@implementation SmartConfigModel

+ (BOOL)showSecurityKey {
    NSString * sk = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_SHOW_SECURITY_KEY];
    if (!sk || [sk isEqualToString:@"NO"])
    return NO;
    else {
        return YES;
    }
}

+ (BOOL)showDeviceName {
    NSString * dn = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_SHOW_DEVICE_NAME];
    if (!dn || [dn isEqualToString:@"YES"])
    return YES;
    else {
        return NO;
    }
}

+ (BOOL)isSmartConfigEnabled {
    NSString * sc = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_SMART_CONFIG_ENABLED];
    if (!sc || [sc isEqualToString:@"NO"]) {
        return NO;
    }
    else {
        return YES;
    }
}

+ (BOOL)isQREnabled {
    NSString * qr = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_QR_ENABLED];
    if (!qr || [qr isEqualToString:@"NO"])
    return NO;
    else {
        return YES;
    }
}

+ (BOOL)startFromDeviceTab {
    NSString * dt = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_START_DEVICE_TAB];
    if (!dt || [dt isEqualToString:@"NO"])
    return NO;
    else {
        return YES;
    }
}
//added by ofir
+ (BOOL)isUUIDEnabled {
    NSString * uuid = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_SHOW_UUID_NAME];
    if (!uuid || [uuid isEqualToString:@"NO"])
    return NO;
    else {
        return YES;
    }
}

@end
