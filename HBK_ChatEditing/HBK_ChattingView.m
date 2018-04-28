//
//  HBK_ChattingView.m
//  HBK_ChatEditing
//
//  Created by 黄冰珂 on 2018/4/25.
//  Copyright © 2018年 KK. All rights reserved.
//

#import "HBK_ChattingView.h"

//--------------------------------------------------------------------
//状态栏和导航栏的总高度
#define StatusNav_Height (isIphoneX ? 88 : 64)
//判断是否是iPhoneX
#define K_Width [UIScreen mainScreen].bounds.size.width
#define K_Height [UIScreen mainScreen].bounds.size.height
//--------------------------------------------------------------------
static float defaultHeight = 40.0f;
static NSString *cellID = @"JumpViewCell";

@class JumpViewCell;
@interface HBK_ChattingView ()<UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
//----------------------UI控件------------------------------------
@property (nonatomic, strong) UIView            *bgView;
@property (nonatomic, strong) UIButton          *moreBtn;
@property (nonatomic, strong) UIButton          *tranformBtn;
@property (nonatomic, strong) UIButton          *voiceBtn;
@property (nonatomic, strong) UITextView        *editTextView;
@property (nonatomic, strong) UICollectionView  *moreCollectionView;
@property (nonatomic, strong) UIView            *jumpBgView;
//-----------------------------------------------------------

@property (nonatomic, assign) CGFloat           keyboardHeight; //键盘高度
@property (nonatomic, assign) CGFloat           duration;//键盘弹出来的时长
@property (nonatomic, assign) BOOL              moreIsShow;//+号是否点击
@property (nonatomic, assign) CGFloat           textViewHeight;//textView高度

@end

@implementation HBK_ChattingView

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        self.titleArray = [NSMutableArray arrayWithObjects:@"相册/相机", @"语音转文字", nil];
    }
    return _titleArray;
}
- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        self.imageArray = [NSMutableArray arrayWithObjects:@"album", @"speechInput", nil];
    }
    return _imageArray;
}
- (instancetype)init {
    if (self = [super init]) {
        //监听键盘出现、消失
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        //此通知主要是为了获取点击空白处回收键盘的处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:@"keyboardHide" object:nil];
        
        [self createSubViews];
        
    }
    return self;
}


- (void)createSubViews {
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self);
        make.top.left.right.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(defaultHeight);
    }];
    [self.bgView addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.bgView).offset(0);
        make.height.width.mas_equalTo(defaultHeight);
    }];

    [self.bgView addSubview:self.tranformBtn];
    [self.tranformBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.mas_equalTo(self.bgView).offset(0);
        make.height.width.mas_equalTo(defaultHeight);
    }];
    
    [self setIsDefaultVoice:NO];
}

#pragma mark - 键盘 -
- (void)keyboardWillShow:(NSNotification *)sender {
    if (self.moreIsShow == YES) {
        [self closeJumpView];
        
    }

    NSDictionary *userInfo = sender.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //获取键盘的高度
    self.keyboardHeight = endFrame.size.height;
    //键盘的动画时长
    self.duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:weakSelf.duration animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                __strong typeof(weakSelf) self = weakSelf;
                make.bottom.mas_equalTo(self.superview).offset(-self.keyboardHeight);
                make.height.mas_equalTo(self.textViewHeight ? self.textViewHeight : defaultHeight);
            }];
        } completion:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)sender {
    if (self.keyboardHeight > 0) {
        self.moreIsShow = YES;
        self.keyboardHeight = 0;
        if (_jumpBgView) {
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:weakSelf.duration animations:^{
        [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
            __strong typeof(self) strongSelf = weakSelf;
            make.bottom.mas_equalTo(strongSelf.superview).offset(0);
        }];
    }];
    
}
- (void)keyboardHide {
    [self.editTextView resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:weakSelf.duration animations:^{
        //设置self的frame到最底部
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.bottom.mas_equalTo(strongSelf.superview).offset(0);
        }];
    }];
}

#pragma mark - Action -
//更多
- (void)moreBtnAction:(UIButton *)sender {
    if (!self.moreIsShow) {
        [self openJumpView];
    } else {
        [self closeJumpView];
    }
    [self.editTextView resignFirstResponder];
}
//语音Or文字编辑
- (void)tranformEditingOrVoiceAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setIsDefaultVoice:sender.selected];
}

//语音聊天
- (void)voiceBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomVoiceInput)]) {
        [self.delegate bottomVoiceInput];
    }
}

//打开
- (void)openJumpView {
    self.moreIsShow = YES;
    [self addSubview:self.jumpBgView];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(K_Width/4+(self.textViewHeight ? self.textViewHeight : defaultHeight));
    }];
    [self.jumpBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        make.left.right.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(K_Width/4);
    }];
    
    [self.jumpBgView addSubview:self.moreCollectionView];
    [_moreCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.jumpBgView);
    }];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(K_Width/4+(self.textViewHeight ? self.textViewHeight : defaultHeight));
            make.bottom.mas_equalTo(self.superview).offset(0);
        }];
    }];
}

//关闭
- (void)closeJumpView {
    self.moreIsShow = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.bottom.mas_equalTo(strongSelf.superview).offset(0);
            make.height.mas_equalTo(self.textViewHeight ? self.textViewHeight : defaultHeight);
        }];
    }];
    [self.jumpBgView removeFromSuperview];
    self.jumpBgView = nil;
    [self.moreCollectionView removeFromSuperview];
    self.moreCollectionView = nil;
}

#pragma mark - getter -

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.borderWidth = 1;
        _bgView.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.89 alpha:1.00].CGColor;
    }
    return _bgView;
}


- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:(UIControlStateNormal)];
    }
    return _moreBtn;
}

- (UITextView *)editTextView {
    if (!_editTextView) {
        _editTextView = [[UITextView alloc] init];
        _editTextView.font = [UIFont systemFontOfSize:18];
        _editTextView.delegate = self;
        _editTextView.layer.cornerRadius = 4;
        _editTextView.layer.borderWidth = 1;
        _editTextView.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.89 alpha:1.00].CGColor;
        _editTextView.returnKeyType = UIReturnKeyDone;
    }
    return _editTextView;
}

- (UIButton *)tranformBtn {
    if (!_tranformBtn) {
        _tranformBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_tranformBtn addTarget:self action:@selector(tranformEditingOrVoiceAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _tranformBtn;
}

- (UIButton *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_voiceBtn setTitle:@"按住 说话" forState:(UIControlStateNormal)];
        [_voiceBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        _voiceBtn.layer.cornerRadius = 4;
        _voiceBtn.layer.borderWidth = 1;
        _voiceBtn.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.89 alpha:1].CGColor;
        _voiceBtn.layer.masksToBounds = YES;
        [_voiceBtn addTarget:self action:@selector(voiceBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _voiceBtn;
}

- (UICollectionView *)moreCollectionView {
    if (!_moreCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(K_Width/4, K_Width/4);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _moreCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _moreCollectionView.backgroundColor = [UIColor whiteColor];
        _moreCollectionView.dataSource = self;
        _moreCollectionView.delegate = self;
        [self.moreCollectionView registerClass:[JumpViewCell class] forCellWithReuseIdentifier:cellID];
    }
    return _moreCollectionView;
}

- (UIView *)jumpBgView {
    if (!_jumpBgView) {
        _jumpBgView = [[UIView alloc] init];
    }
    return _jumpBgView;
}

#pragma mark - Setter -
- (void)setIsDefaultVoice:(BOOL)isDefaultVoice {
//    NSLog(@"-----------%d", isDefaultText);
    if (isDefaultVoice) {
        [self.editTextView removeFromSuperview];
        self.editTextView = nil;
        self.tranformBtn.selected = YES;
        [self.tranformBtn setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:(UIControlStateNormal)];
        [self.bgView addSubview:self.voiceBtn];
        [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tranformBtn.mas_right).offset(0);
            make.right.mas_equalTo(self.moreBtn.mas_left).offset(0);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(0);
            make.height.mas_equalTo(defaultHeight);
        }];
    } else {
        [self.voiceBtn removeFromSuperview];
        self.voiceBtn = nil;
        self.tranformBtn.selected = NO;
        [self.tranformBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:(UIControlStateNormal)];
        [self.bgView addSubview:self.editTextView];
        [self.editTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tranformBtn.mas_right).offset(0);
            make.right.mas_equalTo(self.moreBtn.mas_left).offset(0);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(0);
            make.height.mas_equalTo(defaultHeight);
        }];
//        [self.editTextView becomeFirstResponder];
    }
    if (self.textViewHeight>0) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(defaultHeight);
        }];
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
}

#pragma mark - TextView delegate -
- (void)textViewDidChange:(UITextView *)textView {
//    NSLog(@"%@", textView.text);
    CGSize size=[textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.frame), MAXFLOAT)];
    CGRect frame=textView.frame;
//    NSLog(@"%lf", frame.size.height);
    frame.size.height=size.height;
//    NSLog(@"-------%lf", frame.size.height);
    if (frame.size.height >= defaultHeight) {
        self.textViewHeight = frame.size.height;
    } else {
        self.textViewHeight = defaultHeight;
    }
    [textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(self.textViewHeight);
    }];
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(self.textViewHeight);
    }];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(self.textViewHeight);
    }];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
//        NSLog(@"确定---- %@", textView.text);
        [textView resignFirstResponder];
        if (self.delegate && [self.delegate respondsToSelector:@selector(bottomDidEndEditing:)]) {
            [self.delegate bottomDidEndEditing:textView.text];
        }
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JumpViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.iconImageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomViewClick:)]) {
        [self.delegate bottomViewClick:indexPath.row];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


// --------------------------------------------------------------------------------------
#pragma mark - 弹出视图的cell -
@interface JumpViewCell ()

@end
@implementation JumpViewCell



- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.top.mas_equalTo(self.contentView).offset(K_Width/16);
        }];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView).offset(-10);
            make.left.right.mas_equalTo(self.contentView).offset(0);
            make.height.mas_equalTo(20);
        }];
    }
    return _titleLabel;
}


@end



















