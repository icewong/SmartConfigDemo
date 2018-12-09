//
//  ViewController.m
//  Smartconfig
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "ViewController.h"


#include "SmartconfigManager.h"
#import "MBProgressHUD.h"

#define CUSTOM_OFFSET 10
#define CUSTOM_HEIGHT 44
@interface ViewController ()<UITextFieldDelegate>
{
    UITextField  *_ssidField;
    UITextField  *_passwordField;
    UITextField  *_devicenameField;
    UITextField  *uuidName;
    UITextField  *networkCheckBoxTextField;
    UITextField  *encryptionKeyTextField;

}
@property(nonatomic,strong)UILabel *connectionLabel;
@property(nonatomic,strong)UIButton *startButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Configuration";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromBackground)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)backFromBackground
{
    _ssidField.text = [[SmartconfigManager sharedInstance] getSsidName];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     _ssidField.text = [[SmartconfigManager sharedInstance] getSsidName];
}



- (void)initSubViews
{
    _devicenameField = [[UITextField alloc]initWithFrame:CGRectMake(CUSTOM_OFFSET,64, SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT)];
    _devicenameField.background = [UIImage imageNamed:@"textFieldBorder"];
    UIImageView *deviceNameImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (_devicenameField.frame.size.height - 20)*0.5, 40, 20)];
    deviceNameImgView.image = [UIImage imageNamed:@"thumb_alert_online"];
    deviceNameImgView.contentMode = UIViewContentModeScaleAspectFit;
    _devicenameField.leftView   = deviceNameImgView;
    _devicenameField.leftViewMode = UITextFieldViewModeAlways;
    _devicenameField.delegate = self;
    _devicenameField.placeholder = @"device Name";
    [self.view addSubview:_devicenameField];
    
    networkCheckBoxTextField = [[UITextField alloc]initWithFrame:CGRectMake(CUSTOM_OFFSET,64+_devicenameField.frame.size.height+10, SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT)];
    networkCheckBoxTextField.hidden= YES;
    [self.view addSubview:networkCheckBoxTextField];
    
    encryptionKeyTextField = [[UITextField alloc]initWithFrame:CGRectMake(CUSTOM_OFFSET,64+_devicenameField.frame.size.height+10, SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT)];
    encryptionKeyTextField.hidden= YES;
    [self.view addSubview:encryptionKeyTextField];
    
    
    _ssidField = [[UITextField alloc]initWithFrame:CGRectMake(CUSTOM_OFFSET,64+_devicenameField.frame.size.height+10, SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT)];
    _ssidField.background = [UIImage imageNamed:@"textFieldBorder"];
    UIImageView *leftEmailImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (_ssidField.frame.size.height - 20)*0.5, 40, 20)];
    leftEmailImgView.image = [UIImage imageNamed:@"wifi"];
    leftEmailImgView.contentMode = UIViewContentModeScaleAspectFit;
    _ssidField.leftView   = leftEmailImgView;
    _ssidField.leftViewMode = UITextFieldViewModeAlways;
    _ssidField.delegate = self;
    _ssidField.placeholder = @"Wi-Fi SSID";
    [self.view addSubview:_ssidField];
    
    _passwordField = [[UITextField alloc]initWithFrame:CGRectMake(CUSTOM_OFFSET, 64*2+_ssidField.frame.size.height+10, SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT)];
    _passwordField.background = [UIImage imageNamed:@"textFieldBorder"];
    _passwordField.secureTextEntry = YES;
    
    UIImageView *leftPsdImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (_passwordField.frame.size.height - 20)*0.5, 40, 20)];
    leftPsdImgView.image = [UIImage imageNamed:@"textFieldLock"];
    leftPsdImgView.contentMode = UIViewContentModeScaleAspectFit;
    _passwordField.leftView   = leftPsdImgView;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.delegate = self;
    _passwordField.placeholder = @"password";
    [self.view addSubview:_passwordField];
    
    
    self.connectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(CUSTOM_OFFSET, 64*3+_ssidField.frame.size.height+10 + 50,SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT)];
    [self.view addSubview:self.connectionLabel];
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startButton.frame = CGRectMake(CUSTOM_OFFSET, 64*4+_ssidField.frame.size.height+10 + 50,SCREEN_WIDTH - CUSTOM_OFFSET*2, CUSTOM_HEIGHT);
    [self.startButton setTitle:@"Start Configuration" forState:UIControlStateNormal];
    [self.startButton setBackgroundColor:[UIColor clearColor]];
    [self.startButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [self.startButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    
    [self.startButton.layer setBorderColor:[UIColor colorWithRed:0.0/255 green:174.0/255.0 blue:214.0/255.0 alpha:0.8].CGColor];
    [self.startButton.layer setBorderWidth:1];
    [self.startButton.layer setCornerRadius:5];
    [self.startButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [self.startButton.layer setShadowColor:[UIColor colorWithRed:0.0/255 green:174.0/255.0 blue:214.0/255.0 alpha:1].CGColor];
    [self.startButton.layer setShadowOpacity:0.5];
    [self.startButton.layer setShadowRadius:3];
    [self.startButton addTarget:self action:@selector(sendBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.startButton];

}


- (void)sendWifiInfo:(NSString *)ssid withPassword:(NSString *)password
{
    [[SmartconfigManager sharedInstance] sendWifiInfo:ssid withPassword:password];
    [[SmartconfigManager sharedInstance] setSmartconfigFinishBlock:^(NSError *error, BOOL configResult) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            SmartLog(@"cool failed");
            [self showTips:@"Cool Failed."];
        }else
        {
            SmartLog(@"cool successful");
            [self showTips:@"cool successful"];
        }
    }];
}

- (void)sendBtnAction:(UIButton *)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SmartconfigManager sharedInstance] sendWifiInfo:_ssidField.text withPassword:_passwordField.text];
    [[SmartconfigManager sharedInstance] setSmartconfigFinishBlock:^(NSError *error, BOOL configResult) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            SmartLog(@"cool failed");
            [self showTips:@"Cool Failed."];
        }else
        {
           SmartLog(@"cool successful");
           [self showTips:@"cool successful"];
        }
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //textField放弃第一响应者 （收起键盘）
    //键盘是textField的第一响应者
    [textField resignFirstResponder];
    return YES;
}


-(void)showTips:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:commitAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
