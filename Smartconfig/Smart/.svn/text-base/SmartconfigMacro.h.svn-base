//
//  SmartconfigMacro.h
//  Smartconfig
//
//  Created by WangBing on 2018/5/10.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#ifndef SmartconfigMacro_h
#define SmartconfigMacro_h



#define SYSTEM_VERSION_GREATER_THAN(v)          ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define USER_DEFAULTS_SHOW_TUTORIAL             @"USER_DEFAULTS_SHOW_TUTORIAL"
#define USER_DEFAULTS_SMART_CONFIG_ENABLED      @"USER_DEFAULTS_SMART_CONFIG_ENABLED"
#define USER_DEFAULTS_QR_ENABLED                @"USER_DEFAULTS_QR_ENABLED"
#define USER_DEFAULTS_SHOW_DEVICE_NAME          @"USER_DEFAULTS_SHOW_DEVICE_NAME"
#define USER_DEFAULTS_SHOW_SECURITY_KEY         @"USER_DEFAULTS_SHOW_SECURITY_KEY"
#define USER_DEFAULTS_START_DEVICE_TAB          @"USER_DEFAULTS_START_DEVICE_TAB"
#define USER_DEFAULTS_SHOW_UUID_NAME            @"USER_DEFAULTS_SHOW_UUID_NAME"
#define RGB_COLOR(r,g,b,a)                      [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

#define SMART_CONFIG_TRANSMIT_TIME              40

#define MDNS_SCAN_TIME                          20


#define MDNS_DEVICE_SCAN_TIME                   3

#define SC_AFTER_ADD_PROFILE_WAITING_TIME       20
#define AP_AFTER_ADD_PROFILE_WAITING_TIME       20

#define DELAY_AFTER_RESCAN                      20

#define DELAY_BETWEEN_VERSION_FETCH             2
#define VERSION_FETCH_TRY_NUMBER                5

#define AFTER_SUCCESS_WAITING_TIME              5
//add https instead 10.8
#define BASE_URL                                @"://mysimplelink.net"
#define BASE_URL_DEFAULT                        @"http://mysimplelink.net"
#define DEVICE_TAB_INDEX                        2

#define DEVICE_NAME_CHAR_LENGTH_LIMIT           19

#define NETWORK_REQUEST_TIMEOUTS                15

#define CFG_TOTAL_TRIES                         5
#define CFG_RETRY_DELAY                         1

#define SIMPLE_LINK_NETWORK_PREFIX              @"mysimplelink"

#define UNKNOWN_DEVICE_VERSION_MSG              @"Application cannot configure the selected device. Either you have selected a non-SimpleLink device or you have selected a SimpleLink device which supports only legacy provisioning sequence. Please choose another SimpleLink device"

#define QUESTION_CHOOSE_ROUTER                  @"Please choose the network that the device will connect to"
#define QUESTION_NETWORK_NAME                   @"Set the name of the Network you would like to connect your device to. For example, your home router name. The device will connect to this network at the end of configuration sequence."

#define QUESTION_NETWORK_PASSWORD               @"Set the password for the written network. If the network has no password, leave it empty"
#define QUESTION_ENCRYPTION_KEY                 @"Enter the password used for secure transmission of network information to the device"
#define QUESTION_DEVICE_NAME                    @"Set the \"Device name\" to a friendly name, for example - Kitchen Temp Sensor. If not set, device name shall be factory default name."
#define QUESTION_PAIRED_TABLE_HOMEKIT                    @"This table will contain all the paired accessories you have paired so far.\nTap the desired accessory  and you will gain control on that accessory(make sure the accessory is available for use)."
#define QUESTION_UNPAIRED_TABLE_HOMEKIT                    @"This table will contain all the unpaired accessories around you.\nTap the desired accessory you want to pair."
#define QUESTION_UUID                           @"Please set your iotLink UUID (Unique User Id)"
#define QUESTION_NETWORK_PASSWORD1              @"Please set your network password if the network is open fill the checkbox"
#define QUESTION_CHOOSE_DEVICE                  @"Select the device you want to configure"

#define ERROR_SET_DEVICE_NAME                   @"Failed to set the simple link name"
#define ERROR_ADDING_PROFILE                    @"Failed to add network profile to the simple link device"


#define ERROR_CFG_FAILURE_STRING                @"Please try to restart the device and the configuration application and try again"
#define ERROR_CFG_NOT_STARTED                   @"The provisioning sequence has not started yet. Device is waiting for configuration to be sent"
#define ERROR_CFG_WRONG_PASSWORD_STRING         @"Connection to selected AP has failed. Please try one of the following:\nCheck your password entered correctly and try again.\nCheck your AP is working.\nRestart your AP."
#define ERROR_CFG_AP_NOT_FOUND_STRING           @"Configured AP isn't a scan result, no confirmation for this case"
#define ERROR_CFG_IP_ADD_FAIL_STRING            @"Failed to acquire IP address from the selected AP. Please try one of the following:\nTry connecting a new device to the WiFi AP to see if it is OK\nRestart the WiFi AP"
#define ERROR_CFG_AP_NOT_FOUND_STRING           @"Configured AP isn't a scan result, no confirmation for this case"
#define ERROR_CFG_TIME_OUT                      @"Failed due to communication timeout"

#define ERROR_CONNECTION_REQ                    @"You must connect to simple link device to continue"
#define ERROR_WRONG_CONNECTION                  @"You are connected to the wrong network"


#define INFO_ENABLE_SMART_CONFIG                @"SmartConfig algorithm is activated. Provisioning is performed directly over WiFi connection to the device, acting as a WiFi router."
#define INFO_ENABLE_QR                          @"\"SCAN QR CODE\" button is displayed and provisioning information may be scanned from product QR code."
#define INFO_ENABLE_DEVICE_NAME                 @"Device name entry is available on provisioning screen."
#define INFO_ENABLE_SECURITY_KEY                @"SmartConfig security Key entry is available on provisioning screen."
#define INFO_ENABLE_DEVICES_TAB                 @"Application starts on Devices tab. Otherwise application starts on provisioning tab."
#define INFO_ENABLE_UUID_TAB                    @"iotLink UUID entry is available on provisioning screen"
#define LOADER_CHECK_DEVICE_VERSION             @"Checking for device version"
#define LOADER_CHECK_DEVICE_STATE               @"Checking for device state"
#define LOADER_ADDING_PROFILE                   @"Adding profile"
#define LOADER_CFG_RESULT                       @"Checking results"
#define LOADER_WAITING_FOR_DEVICE               @"Validating configuration"

#define LOGS_EMAIL                              @"ecs-bugreport@list.ti.com"


#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kWeakSelf(type)__weak typeof(type)weak##type = type;

#if DEBUG
#define SmartLog(xx,...) NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define SmartLog(xx,...) ((void)0)
#endif



#endif /* SmartconfigMacro_h */

typedef enum SecurityType {
    SecurityType_OPEN = 0,
    SecurityType_WPA1 = 1,
    SecurityType_WEP = 2,
    SecurityType_WPA2 = 3,
    SecurityType_UNKNOWN = 4
}SecurityType;
