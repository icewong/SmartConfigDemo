//
//  SimpleLinkNetwokUtil.m
//  Smartconfig
//
//  Created by WangBing on 2018/5/10.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "SimpleLinkNetwokUtil.h"
#import "AFHTTPSessionManager.h"
#import "SmartconfigMacro.h"
#import "ScanResult.h"
@implementation SimpleLinkNetwokUtil

+ (void)getProductVersionFromUrl:(NSString*)baseUrl WithCompletion:(void (^)(Product_Version version))handler {
    baseUrl = [baseUrl stringByAppendingString:@"/param_product_version.txt"];
    

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = NETWORK_REQUEST_TIMEOUTS;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:baseUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSData * responseData = responseObject;
        NSString* responseString = [NSString stringWithUTF8String:[responseData bytes]];
        NSLog(@"New redirect URL: %@",[[[task response] URL] absoluteString]);
        NSString *url = [[[task response] URL] absoluteString];
        NSArray *items = [url componentsSeparatedByString:@":"];
        
        NSString *str1=[items objectAtIndex:0];
        NSLog(@"First item : %@",str1);
        NSString *str2=[items objectAtIndex:1];
        NSLog(@"Second item : %@",str2);
        
        NSUserDefaults *preferences;
        preferences=[NSUserDefaults standardUserDefaults];
        [preferences setObject:str1 forKey:@"httpType"];
        [preferences synchronize];
        
        
        if ([responseString isEqualToString:@"R1.0"])
        handler(Product_Version_R1);
        else if ([responseString isEqualToString:@"R2.0"])
        handler(Product_Version_R2);
        else
        handler(Product_Version_Unkown);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        handler(Product_Version_Unkown);
    }];
}

+ (void)getCGResultFromUrl:(NSString*)baseUrl WithCompletion:(void (^)(CFG_Result result))handler TotalTries:(int)tries {
    
    
    int __block remainingTries = tries;
    
    baseUrl = [baseUrl stringByAppendingString:@"/param_cfg_result.txt"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    manager.requestSerializer.timeoutInterval = NETWORK_REQUEST_TIMEOUTS;

    
    [manager GET:baseUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSData * responseData = responseObject;
        NSString * responseString = [NSString stringWithUTF8String:[responseData bytes]];
        NSLog(@"getCGResultFromUrl: success: %@", responseString);
        CFG_Result result = Time_Out;
        
        if ([responseString isEqualToString:@"5"] || [responseString isEqualToString:@"5"])
        result = Success;
        else if ([responseString isEqualToString:@"0"])
        result = Not_Started;
        else if ([responseString isEqualToString:@"1"])
        result = Ap_Not_Found;
        else if ([responseString isEqualToString:@"2"])
        result = Wrong_Password;
        else if ([responseString isEqualToString:@"3"])
        result = Ip_Add_Fail;
        else
        result = Failure;
        
        handler(result);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"getCGResultFromUrl Error: %@", error);
        if (remainingTries > 0){
            remainingTries--;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, CFG_RETRY_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getCGResultFromUrl:[baseUrl stringByReplacingOccurrencesOfString:@"/param_cfg_result.txt" withString:@""] WithCompletion:handler TotalTries:remainingTries];
            });
        }
        else {
            handler(Time_Out);
        }
    }];
}


+ (void)startAddingProfileProcedureFromUrl:(NSString*)baseUrl SSID:(NSString*)ssid Password:(NSString*)password ProductVersion:(Product_Version)version Security:(int)securityType WithCompletion:(void (^)(NSString * errorMsg))handler {
    
    switch (securityType) {
            case SecurityType_UNKNOWN: {
                
                if (!password || [password isEqualToString:@""]) {
                    //need to add profile with security type Open
                    [self addProfileFromUrl:baseUrl SSID:ssid Password:nil ProductVersion:version Security:SecurityType_OPEN WithCompletion:^(NSString *errorMsg) {
                        if (errorMsg) {
                            handler(errorMsg);
                        }
                        else {
                            [self moveStateMachineFromUrl:baseUrl SSID:ssid ProductVersion:version WithCompletion:handler];
                        }
                    }];
                }
                else {
                    //need to add profile with security type WEP, WPA1
                    [self addProfileFromUrl:baseUrl SSID:ssid Password:password ProductVersion:version Security:SecurityType_WEP WithCompletion:^(NSString *errorMsg) {
                        if (errorMsg) {
                            handler(errorMsg);
                        }
                        else {
                            [self addProfileFromUrl:baseUrl SSID:ssid Password:password ProductVersion:version Security:SecurityType_WPA1 WithCompletion:^(NSString *errorMsg) {
                                if (errorMsg) {
                                    handler(errorMsg);
                                }
                                else {
                                    [self moveStateMachineFromUrl:baseUrl SSID:ssid ProductVersion:version WithCompletion:handler];
                                }
                            }];
                        }
                    }];
                }
                
                break;
            }
        default: {
            
            [self addProfileFromUrl:baseUrl SSID:ssid Password:password ProductVersion:version Security:securityType WithCompletion:^(NSString *errorMsg) {
                if (errorMsg) {
                    handler(errorMsg);
                }
                else {
                    [self moveStateMachineFromUrl:baseUrl SSID:ssid ProductVersion:version WithCompletion:handler];
                }
            }];
            
            break;
        }
    }
}

+ (void)moveStateMachineFromUrl:(NSString*)baseUrl SSID:(NSString*)ssid ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * errorMsg))handler {
    
    NSDictionary * params = nil;
    
    switch (version) {
            case Product_Version_Unkown:
            handler(@"Failed to move state machine forward");
            return;
            case Product_Version_R1:
            baseUrl = [baseUrl stringByAppendingString:@"/add_profile.html"];
            params = @{@"__SL_P_UAN" : ssid};
            break;
            case Product_Version_R2:
            baseUrl = [baseUrl stringByAppendingString:@"/api/1/wlan/confirm_req"];
            break;
    }
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    manager.requestSerializer.timeoutInterval = NETWORK_REQUEST_TIMEOUTS;
    NSLog(@"moveStateMachineFromUrl %@",params);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        dispatch_group_t downloadGroup = dispatch_group_create();
        dispatch_group_enter(downloadGroup);
        dispatch_group_wait(downloadGroup, dispatch_time(DISPATCH_TIME_NOW, 5000000000)); // Wait 5 seconds before trying again.
        dispatch_group_leave(downloadGroup);
        dispatch_async(dispatch_get_main_queue(), ^{
            //Main Queue stuff here
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager.securityPolicy setAllowInvalidCertificates:YES];
            //Redo the function that made the Request.
        });
    });
    [manager POST:baseUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"moveStateMachineFromUrl: success");
        handler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"moveStateMachineFromUrl: failure: %@", error.localizedDescription);
        handler(nil);
    }];

}
+ (void)addProfileFromUrl:(NSString*)baseUrl SSID:(NSString*)ssid Password:(NSString*)password ProductVersion:(Product_Version)version Security:(SecurityType)securityType WithCompletion:(void (^)(NSString * errorMsg))handler {
    
    switch (version) {
            case Product_Version_Unkown:
            handler(@"Failed to get the version of the simple link device");
            return;
            case Product_Version_R1:
            baseUrl = [baseUrl stringByAppendingString:@"/profiles_add.html"];
            break;
            case Product_Version_R2:
            baseUrl = [baseUrl stringByAppendingString:@"/api/1/wlan/profile_add"];
            break;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:@{@"__SL_P_P.A" : ssid,
                                                                                   @"__SL_P_P.B" : @(securityType),
                                                                                   @"__SL_P_P.D" : @(0)}];
    if (password)
    [params setValue:password forKey:@"__SL_P_P.C"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    //manager.requestSerializer.timeoutInterval = NETWORK_REQUEST_TIMEOUTS;
    
    NSLog(@"addProfileFromUrl...");

    [manager POST:baseUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"addProfileFromUrl: success");
        handler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"addProfileFromUrl: failure: %@", error);
        handler(nil);
    }];
}

+ (void)getDeviceNameFromUrl:(NSString*)baseUrl ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * deviceName, NSString * errorMsg))handler {
    switch (version) {
            case Product_Version_Unkown:
            handler(nil, @"Failed to get the version of the simple link device");
            return;
            case Product_Version_R1:
            case Product_Version_R2:
            baseUrl = [baseUrl stringByAppendingString:@"/param_device_name.txt"];
            break;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    //manager.requestSerializer.timeoutInterval = NETWORK_REQUEST_TIMEOUTS;
    
    NSLog(@"getDeviceNameFromUrl...");
    [manager GET:baseUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSData * responseData = responseObject;
        NSString * responseString = [NSString stringWithUTF8String:[responseData bytes]];
        NSLog(@"getDeviceNameFromUrl: success %@", responseString);
        handler(responseString, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"getDeviceNameFromUrl: failure: %@", error);
        handler(nil, @"Failed to get device name from simple link device");
    }];
}

+ (void)setDeviceNameFromUrl:(NSString*)baseUrl Name:(NSString*)newName ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * errorMsg))handler {
    switch (version) {
            case Product_Version_Unkown:
            handler(@"Failed to get the version of the simple link device");
            return;
            case Product_Version_R1:
            baseUrl = [baseUrl stringByAppendingString:@"/mode_config"];
            break;
            case Product_Version_R2:
            baseUrl = [baseUrl stringByAppendingString:@"/api/1/netapp/set_urn"];
            break;
    }
    
    NSDictionary * params = @{@"__SL_P_S.B" : newName};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    NSLog(@"setDeviceNameFromUrl...");

    [manager POST:baseUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"setDeviceNameFromUrl: success");
        handler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"setDeviceNameFromUrl: failure: %@", error);
        handler(@"Failed to set device name for simple link device");
    }];
}

+ (void)getDeviceScanResults:(NSString*)baseUrl WithCompletion:(void (^)(NSArray * resultList, NSString * errorMsg))handler {
    // NSUserDefaults *preferences;
    //    NSString *httpOrHttps=[preferences stringForKey:@"httpType"];
    NSString *httpOrHttps =[[NSUserDefaults standardUserDefaults] stringForKey:@"httpType"];
    NSLog(@"http or https ? %@",httpOrHttps);
    baseUrl = [baseUrl stringByAppendingString:@"/netlist.txt"];
    NSLog(@"%@",baseUrl);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    [manager GET:baseUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSData * responseData = responseObject;
        NSString * responseString = [NSString stringWithUTF8String:[responseData bytes]];
        NSMutableArray * resultsArray = [NSMutableArray new];
        
        NSArray * list = [responseString componentsSeparatedByString:@";"];
        for (NSString * wifiInfoString in list) {
            if ([wifiInfoString isEqualToString:@"X"] || wifiInfoString.length == 0)
            continue;
            
            int securityType = [[wifiInfoString substringToIndex:1] intValue];
            NSString * ssid = [wifiInfoString substringFromIndex:1];
            
            switch (securityType) {
                    case SecurityType_OPEN:
                    case SecurityType_WEP:
                    case SecurityType_WPA1:
                    case SecurityType_WPA2: {
                        ScanResult * scanResult = [ScanResult scanResultWithSSID:ssid SecurityType:securityType];
                        [resultsArray addObject:scanResult];
                        break;
                    }
                default:
                    break;
            }
        }
        
        handler(resultsArray, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {

        NSLog(@"getDeviceScanResults: failure: %@", error.localizedDescription);
        handler(nil, @"Failed to get scan result from the device");
    }];
}

+ (void)rescanNetworkListOnDeviceWithUrl:(NSString*)baseUrl ProductVersion:(Product_Version)version WithCompletion:(void (^)(NSString * errorMsg))handler {
    
    NSDictionary * params;
    
    switch (version) {
            case Product_Version_Unkown:
            handler(@"Failed to rescan");
            return;
            case Product_Version_R1:
            baseUrl = [baseUrl stringByAppendingString:@"/mode_config"];
            params = @{@"__SL_P_UFS" : @"sion"};
            break;
            case Product_Version_R2:
            baseUrl = [baseUrl stringByAppendingString:@"/api/1/wlan/en_ap_scan"];
            params = @{@"__SL_P_SC1" : @"10",
                       @"__SL_P_SC2" : @"1"};
            break;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
  
    [manager POST:baseUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"New redirect URL: %@",[[[task response] URL] absoluteString]);
        handler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"rescanNetworkListOnDeviceWithUrl: failure: %@", error.localizedDescription);
        handler(@"Failed to rescan");
    }];
}
+(void)setUuidToProfile:(NSString *)baseUrl UUID:(NSString *)uuid  {
    
    
    NSDictionary * params = @{@"uuid" : uuid};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    [manager POST:baseUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"setUUIDNameFromUrl: success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      NSLog(@"setUUIDNameFromUrl: failure: %@", error);
    }];
}



@end
