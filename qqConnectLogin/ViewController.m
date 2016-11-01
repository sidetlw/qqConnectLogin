//
//  ViewController.m
//  qqConnectLogin
//
//  Created by Longwei on 16/10/20.
//  Copyright © 2016年 Longwei. All rights reserved.
//

#import "ViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "SDWebImageManager.h"

@interface ViewController ()<TencentSessionDelegate>
@property (strong,nonatomic) TencentOAuth *tencentOAuth;

@property (weak, nonatomic) IBOutlet UILabel *resultLable;
@property (weak, nonatomic) IBOutlet UILabel *openIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessTokenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:APPID andDelegate:self];
    
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    NSDate *expirationDate = [userDefualt objectForKey:kexpirationDate];
    NSDate *now = [NSDate date];
    
    if ((expirationDate != nil) && [now compare:expirationDate] == NSOrderedAscending) {
        //未过期
        [_tencentOAuth setAccessToken:[userDefualt objectForKey:kAccessToken]] ;
        [_tencentOAuth setOpenId:[userDefualt objectForKey:kOpenID]] ;
        [_tencentOAuth setExpirationDate:expirationDate] ;
        
        _resultLable.text =@"恢复授权成功";
        [self.tencentOAuth getUserInfo];
        
    } else {
        //过期
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnTapped:(id)sender {
   NSArray* permissions = [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
    
    [self.tencentOAuth authorize:permissions inSafari:YES];
}

#pragma mark- TencentLoginDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
    _resultLable.text =@"登录授权成功";
    if (self.tencentOAuth.accessToken &&0 != [self.tencentOAuth.accessToken length])
    {
       //  记录登录用户的OpenID、Token以及过期时间
        self.accessTokenLabel.text = self.tencentOAuth.accessToken;
        self.openIDLabel.text = self.tencentOAuth.openId;
        self.expirationDateLabel.text = [[NSString alloc] initWithFormat:@"%@",self.tencentOAuth.expirationDate];
        
        NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
        [userDefualt setObject:self.tencentOAuth.accessToken forKey:kAccessToken];
        [userDefualt setObject:self.tencentOAuth.openId forKey:kOpenID];
        [userDefualt setObject:self.tencentOAuth.expirationDate forKey:kexpirationDate];
        
        BOOL result = [self.tencentOAuth getUserInfo];
        NSLog(@"getUserInfo result %d:",result);
    }
    else
    {
        self.accessTokenLabel.text =@"登录不成功没有获取到accesstoken";
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"tencentDidNotLogin");
    
    if (cancelled)
    {
        self.resultLable.text =@"用户取消登录";
    }else{
        self.resultLable.text =@"登录失败";
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
    NSLog(@"tencentDidNotNetWork");
    
    self.resultLable.text =@"无网络连接，请设置网络";
}

-(void)getUserInfoResponse:(APIResponse *)response
{
    NSLog(@"respons:%@",response.jsonResponse);
    if (response.jsonResponse != nil) {
        NSString *nikename = [response.jsonResponse valueForKey:@"nickname"];
        self.nikeNameLabel.text = nikename;
        
        NSString *avatarUrl = [response.jsonResponse valueForKey:@"figureurl_qq_2"];
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:avatarUrl]
                                                        options:SDWebImageRetryFailed progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                          
                                                          if(error){
                                                              NSLog(@"下载头像出错！！！！！！！！");
                                                              return ;
                                                          }
                                                          self.avatarImage.image = image;
                                                      }];
    }
}

@end
