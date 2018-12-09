//
//  SmartConfigGlobalConfig.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartConfigGlobalConfig : NSObject
{
    NSString *deviceName;
    NSString *scPass;
    NSString *ssidName;
}
@property(nonatomic,retain)NSDate *launchTime;

@property(nonatomic,retain)NSString *deviceName;
@property(nonatomic,retain)NSString *scPass;

@property(nonatomic,assign) BOOL showDeviceName;
@property(nonatomic,assign) BOOL openDeviceList;
@property(nonatomic,assign) BOOL showScPass;
@property(nonatomic,assign) BOOL enableOOB;
@property(nonatomic,assign) BOOL skipOOB;



+(SmartConfigGlobalConfig*)getInstance;

-(void) updateValues;
-(void) emptyDeviceList;
-(void) addDevice:(NSDictionary * )device withKey:(NSString *)key;
-(void) setValue:(BOOL)value forOption:(NSString*)name;

- (NSString*)fetchSSIDName;

-(NSMutableDictionary*) getDevices;

@end
