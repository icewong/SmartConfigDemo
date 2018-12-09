//
//  SmartconfigManager.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/11.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Smart_Tip_Success     @"Cool successful"
#define Smart_Tip_Fail        @"Cool failed"
#define Smart_Tip_NO_WIFI     @"No wifi"
#define Smart_Tip_Encryption      @"Encryption key must be 16 chars"


typedef enum{
 
  Smartconfig_Success = -1000,
  Smartconfig_Failed,
  Smartconfig_params_Null,
  Smartconfig_NO_WIFI,
  Smartconfig_NO_FIND_DEVICE,
  Smartconfig_MaxLength_EncryptionKey,
  Smartconfig_NSException
    
} Smartconfig_Error_Code;


@interface SmartconfigManager : NSObject

@property(nonatomic,copy)void(^smartconfigFinishBlock)(NSError *error,BOOL configResult);

+(instancetype)sharedInstance;

- (void)sendWifiInfo:(NSString *)ssId withPassword:(NSString *)password;

- (NSString *)getSsidName;

@end
