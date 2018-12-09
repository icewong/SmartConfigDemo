//
//  SimpleLinkNetwokUtil.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/10.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum Product_Version {
    Product_Version_R1 = 0,
    Product_Version_R2 = 1,
    Product_Version_Unkown = 2,
} Product_Version;

typedef enum CFG_Result {
    Success = 5,
    Failure = 6,
    Not_Started = 0,
    Wrong_Password = 2,
    Ap_Not_Found = 1,
    Ip_Add_Fail = 3,
    Time_Out = 7
} CFG_Result;
@interface SimpleLinkNetwokUtil : NSObject
+ (void)getProductVersionFromUrl:(NSString*)url WithCompletion:(void (^)(Product_Version version))handler;
+ (void)getCGResultFromUrl:(NSString*)baseUrl WithCompletion:(void (^)(CFG_Result result))handler TotalTries:(int)tries;
+(void)setUuidToProfile:(NSString*)baseUrl UUID:(NSString*)uuid;

+ (void)startAddingProfileProcedureFromUrl:(NSString*)baseUrl SSID:(NSString*)ssid Password:(NSString*)password ProductVersion:(Product_Version)version Security:(int)securityType WithCompletion:(void (^)(NSString * errorMsg))handler;

+ (void)getDeviceNameFromUrl:(NSString*)baseUrl ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * deviceName, NSString * errorMsg))handler;
+ (void)setDeviceNameFromUrl:(NSString*)baseUrl Name:(NSString*)newName ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * errorMsg))handler;
+ (void)getDeviceScanResults:(NSString*)baseUrl WithCompletion:(void (^)(NSArray * resultList, NSString * errorMsg))handler;
+ (void)rescanNetworkListOnDeviceWithUrl:(NSString*)baseUrl ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * errorMsg))handler;

@end
