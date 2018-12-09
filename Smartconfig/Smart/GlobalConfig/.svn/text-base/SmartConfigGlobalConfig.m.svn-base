//
//  SmartConfigGlobalConfig.m
//  Smartconfig
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "SmartConfigGlobalConfig.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation SmartConfigGlobalConfig
static SmartConfigGlobalConfig *instance =nil;

+(SmartConfigGlobalConfig *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES], @"show_device_name",
                                                  [NSNumber numberWithBool:NO], @"open_device_list",
                                                  [NSNumber numberWithBool:NO], @"show_sc_pass",
                                                  nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
            
            
            
            instance= [SmartConfigGlobalConfig new];
            
            // temp empty device table
            NSMutableDictionary *devices = [[NSMutableDictionary alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:devices forKey:@"devices"];
            
        }
    }
    [instance updateValues];
    return instance;
}

-(void) emptyDeviceList
{
    NSMutableDictionary *devices = [[NSMutableDictionary alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:devices forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) updateValues
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.showDeviceName = [[NSUserDefaults standardUserDefaults] boolForKey:@"show_device_name"];
    self.openDeviceList = [[NSUserDefaults standardUserDefaults] boolForKey:@"open_device_list"];
    self.showScPass = [[NSUserDefaults standardUserDefaults] boolForKey:@"show_sc_pass"];
    self.enableOOB = [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_oob"];
    self.skipOOB = [[NSUserDefaults standardUserDefaults] boolForKey:@"skip_oob"];
    
}

-(void) setValue:(BOOL)value forOption:(NSString*)name
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:name];
    [self updateValues];
}

-(void) addDevice:(NSDictionary * )device withKey:(NSString *)key
{
    NSMutableDictionary *devices = [self getDevices];
    
    [devices setValue:device forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:devices forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)fetchSSIDName {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    
    return SSIDInfo ? SSIDInfo[@"SSID"] : nil;
}

-(NSMutableDictionary*) getDevices {
    return[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"devices"] mutableCopy];
}

@end
