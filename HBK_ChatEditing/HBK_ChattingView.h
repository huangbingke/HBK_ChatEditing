//
//  HBK_ChattingView.h
//  HBK_ChatEditing
//
//  Created by 黄冰珂 on 2018/4/25.
//  Copyright © 2018年 KK. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    BottomViewClickPhoto,//相册Or拍照
    BottomViewClickVoiceTransformText//语音转文字
} BottomViewClickType;


@protocol HBK_ChattingViewDelegate <NSObject>

//输入完成
- (void)bottomDidEndEditing:(NSString *)content;
//弹出视图 点击事件
- (void)bottomViewClick:(BottomViewClickType)clickType;
//语音输入
- (void)bottomVoiceInput;



@end

@interface HBK_ChattingView : UIView
/**
 默认文字编辑 NO-文字编辑, YES-语音
 */
@property (nonatomic, assign) BOOL isDefaultVoice;
@property (nonatomic, weak) id <HBK_ChattingViewDelegate>delegate;

@property (nonatomic, strong) NSMutableArray    *titleArray;//弹出视图标题数据源
@property (nonatomic, strong) NSMutableArray    *imageArray;//弹出视图图片数据源

@end



//-------------------------------------------------------------------------------------------------------


@interface JumpViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;


@end







