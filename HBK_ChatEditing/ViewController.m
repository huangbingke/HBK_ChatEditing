//
//  ViewController.m
//  HBK_ChatEditing
//
//  Created by 黄冰珂 on 2018/4/25.
//  Copyright © 2018年 KK. All rights reserved.
//

#import "ViewController.h"
#import "HBK_ChattingView.h"
@interface ViewController ()<HBK_ChattingViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    HBK_ChattingView *hbkView = [[HBK_ChattingView alloc] init];
//    hbkView.isDefaultVoice = YES;
    hbkView.delegate = self;
    [self.view addSubview:hbkView];
    [hbkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(0);
        make.left.mas_equalTo(self.view).offset(0);
        make.right.mas_equalTo(self.view).offset(0);
        make.height.mas_equalTo(40);
    }];
}


- (void)bottomVoiceInput {
    NSLog(@"语音输入");
}

- (void)bottomDidEndEditing:(NSString *)content {
    NSLog(@"%@", content);
}

- (void)bottomViewClick:(BottomViewClickType)clickType {
    NSLog(@"%lu", (unsigned long)clickType);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
