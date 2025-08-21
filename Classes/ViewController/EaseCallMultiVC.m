//
//  EaseCallMultiVC.m
//  EaseCallKit
//
//  Created by 杨剑 on 2025/7/24.
//

#import "EaseCallMultiVC.h"
#import "EaseCallManager+Private.h"
#import <Masonry/Masonry.h>
#import "UIImage+Ext.h"
#import "EaseCallLocalizable.h"

#import "EaseCallStreamView.h"
#import "EaseCallPlaceholderView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import "EaseCallLocalizable.h"

@interface EaseCallMultiVC ()
<EaseCallStreamViewDelegate>
@property (nonatomic) UIButton* inviteButton;
@property (nonatomic) UILabel* statusLable;
@property (nonatomic) BOOL isJoined;
@property (nonatomic) EaseCallStreamView* bigView;
@property (nonatomic) NSMutableDictionary* placeHolderViewsDic;
@property (atomic) BOOL isNeedLayout;

@end

@implementation EaseCallMultiVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setubSubViews];
    self.speakerButton.selected = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersInfoUpdated) name:@"EaseCallUserUpdated" object:nil];
    
    // Do any additional setup after loading the view.
    [self setupSubViews];
    [self updateViewPos];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setubSubViews
{
    int size = 60;
    
    [self.view addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
//        if (@available(iOS 11,*)) {
//            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
//            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
//            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
//            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
//        }else {
//            make.edges.equalTo(self.view);
//         }
    }];
    
    
    
    
    
    self.miniButton = [[UIButton alloc] init];
    self.miniButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.miniButton setImage:[UIImage imageNamedFromBundle:@"mini"] forState:UIControlStateNormal];
    [self.miniButton addTarget:self action:@selector(miniAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.miniButton];
    [self.miniButton setTintColor:[UIColor whiteColor]];
    [self.miniButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(@8);
        make.width.height.equalTo(@44);
    }];
    
//    UIStackView *hstack = UIStackView.new;
//    hstack.axis = UILayoutConstraintAxisHorizontal;
//    hstack.alignment = UIStackViewAlignmentCenter;
////    hstack.description = UIStackViewDistributionEqualSpacing;
//    [self.contentView addSubview:hstack];
//    [hstack mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(32);
//        make.right.mas_equalTo(-32);
//        make.height.mas_equalTo(60);
//        make.bottom.mas_equalTo(self.contentView.mas_safeAreaLayoutGuideBottom).offset(-30);
//    }];
//    hstack.backgroundColor = UIColor.yellowColor;
    
    //挂断;
    self.hangupButton = [[UIButton alloc] init];
    self.hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.hangupButton setImage:[UIImage imageNamedFromBundle:@"hangup"] forState:UIControlStateNormal];
    [self.hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.hangupButton];
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_safeAreaLayoutGuideBottom).offset(-32);
        make.left.equalTo(@30);
        make.width.height.equalTo(@60);
        //make.centerX.equalTo(@60);
    }];
    
    //接听;
    self.answerButton = [[UIButton alloc] init];
    self.answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.answerButton setImage:[UIImage imageNamedFromBundle:@"answer"] forState:UIControlStateNormal];
    [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.answerButton];
    [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton);
        make.right.equalTo(self.contentView).offset(-40);
        make.width.height.mas_equalTo(60);
    }];
    
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setImage:[UIImage imageNamedFromBundle:@"switchCamera"] forState:UIControlStateNormal];
    [self.switchCameraButton addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton);
        make.width.height.mas_equalTo(60);
        make.centerX.equalTo(self.contentView).with.multipliedBy(1.5);
    }];
    
    self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.microphoneButton setImage:[UIImage imageNamedFromBundle:@"microphone_disable"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamedFromBundle:@"microphone_enable"] forState:UIControlStateSelected];
    [self.microphoneButton addTarget:self action:@selector(muteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.microphoneButton];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self.speakerButton.mas_right).offset(40);
        make.centerX.equalTo(self.contentView).with.multipliedBy(0.5);
        make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-40);
        make.width.height.equalTo(@(size));
    }];
    self.microphoneButton.selected = NO;
    
    self.speakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.speakerButton setImage:[UIImage imageNamedFromBundle:@"speaker_disable"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamedFromBundle:@"speaker_enable"] forState:UIControlStateSelected];
    [self.speakerButton addTarget:self action:@selector(speakerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.speakerButton];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.microphoneButton);
        //make.left.equalTo(self.switchCameraButton.mas_right).offset(40);
        make.centerX.equalTo(self.contentView);
        make.width.height.equalTo(@(size));
    }];

    self.enableCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enableCameraButton setImage:[UIImage imageNamedFromBundle:@"video_disable"] forState:UIControlStateNormal];
    [self.enableCameraButton setImage:[UIImage imageNamedFromBundle:@"video_enable"] forState:UIControlStateSelected];
    [self.enableCameraButton addTarget:self action:@selector(enableVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.enableCameraButton];
    [self.enableCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self.microphoneButton.mas_right).offset(40);
        make.centerX.equalTo(self.contentView).with.multipliedBy(1.5);
        make.bottom.equalTo(self.microphoneButton);
        make.width.height.equalTo(@(size));
    }];
    
    [self.enableCameraButton setEnabled:NO];
    [self.switchCameraButton setEnabled:NO];
    [self.microphoneButton setEnabled:NO];
    _timeLabel = nil;
    
    self.hangupLabel = [[UILabel alloc] init];
    self.hangupLabel.font = [UIFont systemFontOfSize:11];
    self.hangupLabel.textColor = [UIColor whiteColor];
    self.hangupLabel.textAlignment = NSTextAlignmentCenter;
    self.hangupLabel.text = EaseCallLocalizableString(@"Huangup",nil);
    [self.contentView addSubview:self.hangupLabel];
    [self.hangupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hangupButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.hangupButton);
    }];
    
    self.acceptLabel = [[UILabel alloc] init];
    self.acceptLabel.font = [UIFont systemFontOfSize:11];
    self.acceptLabel.textColor = [UIColor whiteColor];
    self.acceptLabel.textAlignment = NSTextAlignmentCenter;
    self.acceptLabel.text = EaseCallLocalizableString(@"Answer",nil);
    [self.contentView addSubview:self.acceptLabel];
    [self.acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.answerButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.answerButton);
    }];
    
    self.microphoneLabel = [[UILabel alloc] init];
    self.microphoneLabel.font = [UIFont systemFontOfSize:11];
    self.microphoneLabel.textColor = [UIColor whiteColor];
    self.microphoneLabel.textAlignment = NSTextAlignmentCenter;
    self.microphoneLabel.text = EaseCallLocalizableString(@"Mute",nil);
    [self.contentView addSubview:self.microphoneLabel];
    [self.microphoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.microphoneButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.microphoneButton);
    }];
    
    self.speakerLabel = [[UILabel alloc] init];
    self.speakerLabel.font = [UIFont systemFontOfSize:11];
    self.speakerLabel.textColor = [UIColor whiteColor];
    self.speakerLabel.textAlignment = NSTextAlignmentCenter;
    self.speakerLabel.text = EaseCallLocalizableString(@"Hands-free",nil);
    [self.contentView addSubview:self.speakerLabel];
    [self.speakerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.speakerButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.speakerButton);
    }];
    
    self.enableCameraLabel = [[UILabel alloc] init];
    self.enableCameraLabel.font = [UIFont systemFontOfSize:11];
    self.enableCameraLabel.textColor = [UIColor whiteColor];
    self.enableCameraLabel.textAlignment = NSTextAlignmentCenter;
    self.enableCameraLabel.text = EaseCallLocalizableString(@"Camera",nil);
    [self.contentView addSubview:self.enableCameraLabel];
    [self.enableCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.enableCameraButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.enableCameraButton);
    }];
    
    self.switchCameraLabel = [[UILabel alloc] init];
    self.switchCameraLabel.font = [UIFont systemFontOfSize:11];
    self.switchCameraLabel.textColor = [UIColor whiteColor];
    self.switchCameraLabel.textAlignment = NSTextAlignmentCenter;
    self.switchCameraLabel.text = EaseCallLocalizableString(@"SwitchCamera",nil);
    [self.contentView addSubview:self.switchCameraLabel];
    [self.switchCameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.switchCameraButton.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.switchCameraButton);
    }];
}

- (UIView*)contentView
{
    if(!_contentView)
        _contentView = [[UIView alloc] init];
    return _contentView;
}


- (void)hangupAction
{
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    [[EaseCallManager sharedManager] hangupAction];
}

- (void)switchCameraAction
{
    self.switchCameraButton.selected = !self.switchCameraButton.isSelected;
    [[EaseCallManager sharedManager] switchCameraAction];
}

- (void)speakerAction
{
    self.speakerButton.selected = !self.speakerButton.isSelected;
    [[EaseCallManager sharedManager] speakeOut:self.speakerButton.selected];
}




- (EaseCallStreamView*)floatingView
{
    if(!_floatingView)
    {
        _floatingView = [[EaseCallStreamView alloc] init];
        _floatingView.backgroundColor = [UIColor grayColor];
        _floatingView.bgView.image = [UIImage imageNamedFromBundle:@"floating_voice"];
        [_floatingView.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@55);
        }];
    }
    return _floatingView;
}


#pragma mark - timer

- (void)startTimer
{
    if(!_timeLabel) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:25];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.text = @"00:00";
        [self.contentView addSubview:self.timeLabel];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-20);
            make.centerX.equalTo(self.contentView);
        }];
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
    }
    
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int m = (_timeLength) / 60;
    int s = _timeLength - m * 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", m, s];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupSubViews
{
    self.bigView = nil;
    self.isNeedLayout = NO;
    self.contentView.backgroundColor = [UIColor grayColor];
    [self.timeLabel setHidden:YES];
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inviteButton setImage:[UIImage imageNamedFromBundle:@"invite"] forState:UIControlStateNormal];
    [self.inviteButton addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.inviteButton];
    [self.inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop);
        make.right.equalTo(self.contentView).offset(-8);
        make.width.height.equalTo(@44);
    }];
    [self.contentView bringSubviewToFront:self.inviteButton];
    [self.inviteButton setHidden:YES];
    [self setLocalVideoView:[UIView new] enableVideo:NO];
    {
        if([self.inviterId length] > 0) {
            NSURL* remoteUrl = [[EaseCallManager sharedManager] getHeadImageByUserName:self.inviterId];
            self.remoteHeadView = [[UIImageView alloc] init];
            [self.contentView addSubview:self.remoteHeadView];
            [self.remoteHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@80);
                make.centerX.equalTo(self.contentView);
                make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(40);
            }];
            [self.remoteHeadView sd_setImageWithURL:remoteUrl];
            self.remoteNameLable = [[UILabel alloc] init];
            self.remoteNameLable.backgroundColor = [UIColor clearColor];
            //self.remoteNameLable.font = [UIFont systemFontOfSize:19];
            self.remoteNameLable.textColor = [UIColor whiteColor];
            self.remoteNameLable.textAlignment = NSTextAlignmentRight;
            self.remoteNameLable.font = [UIFont systemFontOfSize:24];
            self.remoteNameLable.text = [[EaseCallManager sharedManager] getNicknameByUserName:self.inviterId];
            [self.timeLabel setHidden:YES];
            [self.contentView addSubview:self.remoteNameLable];
            [self.remoteNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.remoteHeadView.mas_bottom).offset(20);
                make.centerX.equalTo(self.contentView);
            }];
            self.statusLable = [[UILabel alloc] init];
            self.statusLable.backgroundColor = [UIColor clearColor];
            self.statusLable.font = [UIFont systemFontOfSize:15];
            self.statusLable.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            self.statusLable.textAlignment = NSTextAlignmentRight;
            self.statusLable.text = EaseCallLocalizableString(@"receiveCallInviteprompt",nil);
            self.answerButton.hidden = NO;
            self.acceptLabel.hidden = NO;
            [self.contentView addSubview:self.statusLable];
            [self.statusLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.remoteNameLable.mas_bottom).offset(20);
                make.centerX.equalTo(self.contentView);
            }];
        }else{
            self.answerButton.hidden = YES;
            self.acceptLabel.hidden = YES;
            [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.width.height.equalTo(@60);
                make.bottom.equalTo(self.contentView).with.offset(-40);
            }];
            self.isJoined = YES;
            self.localView.hidden = NO;
            [self enableVideoAction];
            self.inviteButton.hidden = NO;
        }
    }
//    for(int i = 0;i<5;i++) {
//        [self addRemoteView:[UIView new] member:[NSNumber numberWithInt:i] enableVideo:NO];
//    }
    [self updateViewPos];
}

- (NSMutableDictionary*)streamViewsDic
{
    if(!_streamViewsDic) {
        _streamViewsDic = [NSMutableDictionary dictionary];
    }
    return _streamViewsDic;
}

- (NSMutableDictionary*)placeHolderViewsDic
{
    if(!_placeHolderViewsDic) {
        _placeHolderViewsDic = [NSMutableDictionary dictionary];
    }
    return _placeHolderViewsDic;
}

- (void)addRemoteView:(UIView*)remoteView member:(NSNumber*)uId enableVideo:(BOOL)aEnableVideo
{
    if([self.streamViewsDic objectForKey:uId])
        return;
    EaseCallStreamView* view = [[EaseCallStreamView alloc] init];
    view.displayView = remoteView;
    view.enableVideo = aEnableVideo;
    view.delegate = self;
    [view addSubview:remoteView];
    [self.contentView addSubview:view];
    [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [view sendSubviewToBack:remoteView];
    [self.contentView sendSubviewToBack:view];
    [self.streamViewsDic setObject:view forKey:uId];
    [self startTimer];
    [self updateViewPos];
}

- (void)setRemoteViewNickname:(NSString*)aNickname headImage:(NSURL*)url uId:(NSNumber*)aUid
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:aUid];
    if(view) {
        view.nameLabel.text = aNickname;
        [view.bgView sd_setImageWithURL:url];
    }
}

- (void)removeRemoteViewForUser:(NSNumber*)uId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:uId];
    if(view) {
        [view removeFromSuperview];
        [self.streamViewsDic removeObjectForKey:uId];
    }
    [self updateViewPos];
}
- (void)setRemoteMute:(BOOL)aMuted uid:(NSNumber*)uId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:uId];
    if(view) {
        view.enableVoice = !aMuted;
    }
}
- (void)setRemoteEnableVideo:(BOOL)aEnabled uId:(NSNumber*)uId
{
    EaseCallStreamView* view = [self.streamViewsDic objectForKey:uId];
    if(view) {
        view.enableVideo = aEnabled;
    }
    if(view == self.bigView && !aEnabled)
        self.bigView = nil;
    [self updateViewPos];
}

- (void)setLocalVideoView:(UIView*)aDisplayView  enableVideo:(BOOL)aEnableVideo
{
    self.localView = [[EaseCallStreamView alloc] init];
    self.localView.displayView = aDisplayView;
    self.localView.enableVideo = aEnableVideo;
    self.localView.delegate = self;
    [self.localView addSubview:aDisplayView];
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.localView);
    }];
    [self.localView sendSubviewToBack:aDisplayView];
    [self.contentView addSubview:self.localView];
    [self showNicknameAndAvartarForUsername:[EMClient sharedClient].currentUsername view:self.localView];
    [self.contentView sendSubviewToBack:self.localView];
    [self updateViewPos];
    self.answerButton.hidden = YES;
    self.acceptLabel.hidden = YES;
    
    [self.enableCameraButton setEnabled:YES];
    self.enableCameraButton.selected = YES;
    [self.switchCameraButton setEnabled:YES];
    [self.microphoneButton setEnabled:YES];
    if([self.inviterId length] > 0) {
        [self.remoteNameLable removeFromSuperview];
        [self.statusLable removeFromSuperview];
        [self.remoteHeadView removeFromSuperview];
    }
    self.localView.hidden = YES;
    [[EaseCallManager sharedManager] enableVideo:aEnableVideo];
}

- (UIView*) getViewByUid:(NSNumber*)uId
{
    EaseCallStreamView*view =  [self.streamViewsDic objectForKey:uId];
    if(view)
        return view.displayView;
    UIView *displayview = [UIView new];
    [self addRemoteView:displayview member:uId enableVideo:YES];
    return displayview;
}

- (void)_refreshViewPos
{
    unsigned long count = self.streamViewsDic.count + self.placeHolderViewsDic.count;
    if(self.localView.displayView)
        count++;
    int index = 0;
    int top = 40;
    int left = 0;
    int right = 0;
    int colSize = 1;
    int colomns = count>6?3:2;
    int bottom = 200;
    int cellwidth = (self.contentView.frame.size.width - left - right - (colomns - 1)*colSize)/colomns ;
    int cellHeight = (self.contentView.frame.size.height - top - bottom)/(count > 6?5:3);
    if(count < 5)
        cellHeight = cellwidth;
    //int cellwidth = (self.contentView.frame.size.width - left - right - (colomns - 1)*colSize)/colomns ;
    //int cellHeight = MIN(cellHeightH, cellWidthV);
    //int cellwidth = cellHeight
    if(self.isJoined) {
        self.microphoneButton.hidden = NO;
        self.microphoneLabel.hidden = NO;
        self.enableCameraButton.hidden = NO;
        self.enableCameraLabel.hidden = NO;
        self.speakerButton.hidden = NO;
        self.speakerLabel.hidden = NO;
        self.switchCameraButton.hidden = NO;
        self.switchCameraLabel.hidden = NO;
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.centerY.equalTo(self.inviteButton);
            make.width.equalTo(@100);
        }];
        if(self.bigView) {
            [self.bigView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(top);
                make.width.equalTo(@(self.contentView.bounds.size.width));
                make.height.equalTo(@(self.contentView.bounds.size.height-top-bottom));
            }];
            if(self.bigView != self.localView) {
                [self.contentView sendSubviewToBack:self.localView];
            }
            NSArray* views = [self.streamViewsDic allValues];
            for(EaseCallStreamView* view in views) {
                if(self.bigView != view) {
                    [self.contentView sendSubviewToBack:view];
                }
            }
        }else{
            [self.localView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(left + index%colomns * (cellwidth + colSize));
                make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(top + index/colomns * (cellHeight + colSize));
                make.width.equalTo(@(cellwidth));
                make.height.equalTo(@(cellHeight));
            }];
            index++;
            NSArray* views = [self.streamViewsDic allValues];
            for(EaseCallStreamView* view in views) {
                [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView).offset(left + index%colomns * (cellwidth + colSize));
                    make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(top + index/colomns * (cellHeight + colSize));
                    make.width.equalTo(@(cellwidth));
                    make.height.equalTo(@(cellHeight));
                }];
                index++;
            }
            NSArray* placeViews = [self.placeHolderViewsDic allValues];
            for(EaseCallStreamView* view in placeViews) {
                [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView).offset(left + index%colomns * (cellwidth + colSize));
                    make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(top + index/colomns * (cellHeight + colSize));
                    make.width.equalTo(@(cellwidth));
                    make.height.equalTo(@(cellHeight));
                }];
                index++;
            }
        }
        
    }else{
        self.microphoneButton.hidden = YES;
        self.microphoneLabel.hidden = YES;
        self.enableCameraButton.hidden = YES;
        self.enableCameraLabel.hidden = YES;
        self.speakerButton.hidden = YES;
        self.speakerLabel.hidden = YES;
        self.switchCameraButton.hidden = YES;
        self.switchCameraLabel.hidden = YES;
    }
}

- (void)updateViewPos
{
    self.isNeedLayout = YES;
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if(weakself.isNeedLayout) {
            weakself.isNeedLayout = NO;
            [weakself _refreshViewPos];
        }
    });
}

- (void)inviteAction
{
    [[EaseCallManager sharedManager] inviteAction];
}

- (void)answerAction
{
    [[EaseCallManager sharedManager] acceptAction];
    self.answerButton.hidden = YES;
    self.acceptLabel.hidden = YES;
    self.statusLable.hidden = YES;
    self.remoteNameLable.hidden = YES;
    self.remoteHeadView.hidden = YES;
    [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.width.height.equalTo(@60);
        make.bottom.equalTo(self.contentView).with.offset(-40);
    }];
    self.isJoined = YES;
    self.localView.hidden = NO;
    self.inviteButton.hidden = NO;
    [self enableVideoAction];
}


- (void)muteAction
{
    self.microphoneButton.selected = !self.microphoneButton.isSelected;
    [[EaseCallManager sharedManager] muteAudio:self.microphoneButton.selected];
    self.localView.enableVoice = !self.microphoneButton.isSelected;
}

- (void)enableVideoAction{
    self.enableCameraButton.selected = !self.enableCameraButton.isSelected;
    [[EaseCallManager sharedManager] enableVideo:self.enableCameraButton.selected];

    self.localView.enableVideo = self.enableCameraButton.isSelected;
    if(self.localView == self.bigView && !self.localView.enableVideo) {
        self.bigView = nil;
        [self updateViewPos];
    }
}

- (void)setPlaceHolderUrl:(NSURL*)url member:(NSString*)uId
{
    EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:uId];
    if(view)
        return;
    EaseCallPlaceholderView* placeHolderView = [[EaseCallPlaceholderView alloc] init];
    [self.contentView addSubview:placeHolderView];
    [placeHolderView.nameLabel setText:[[EaseCallManager sharedManager] getNicknameByUserName:uId]];
//    NSData* data = [NSData dataWithContentsOfURL:url ];
//    [placeHolderView.placeHolder setImage:[UIImage imageWithData:data]];
    [placeHolderView.placeHolder sd_setImageWithURL:url];
    [self.placeHolderViewsDic setObject:placeHolderView forKey:uId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewPos];
    });
    
}

- (void)removePlaceHolderForMember:(NSString*)aUserName
{
    EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:aUserName];
    if(view)
    {
        [view removeFromSuperview];
        [self.placeHolderViewsDic removeObjectForKey:aUserName];
        [self updateViewPos];
    }
}

- (void)streamViewDidTap:(EaseCallStreamView *)aVideoView
{
    if(aVideoView == self.floatingView) {
        self.isMini = NO;
        [self.floatingView removeFromSuperview];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = window.rootViewController;
        self.modalPresentationStyle = 0;
        [rootViewController presentViewController:self animated:YES completion:nil];
        return;
    }
    if(aVideoView == self.bigView) {
        self.bigView = nil;
        [self updateViewPos];
    }else{
        if(aVideoView.enableVideo)
        {
            self.bigView = aVideoView;
            [self updateViewPos];
        }
    }
}

- (void)miniAction
{
    self.isMini = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.floatingView.frame = CGRectMake(self.contentView.bounds.size.width - 100, 80, 80, 100);
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.floatingView.enableVideo = NO;
    
    self.floatingView.delegate = self;
    if(self.isJoined) {
        self.floatingView.nameLabel.text = EaseCallLocalizableString(@"Call in progress",nil);
    }else{
        self.floatingView.nameLabel.text = EaseCallLocalizableString(@"waitforanswer",nil);
    }
}

- (void)showNicknameAndAvartarForUsername:(NSString*)aUserName view:(UIView*)aView
{
    if([aView isKindOfClass:[EaseCallStreamView class]]) {
        EaseCallStreamView* streamView = (EaseCallStreamView*)aView;
        if(streamView && aUserName.length > 0) {
            streamView.nameLabel.text = [[EaseCallManager sharedManager] getNicknameByUserName:aUserName];
            NSURL* url = [[EaseCallManager sharedManager] getHeadImageByUserName:aUserName];
            NSURL* curUrl = [streamView.bgView sd_imageURL];
            if(!curUrl || (url && ![self isEquivalent:url with:curUrl])) {
                [streamView.bgView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
            }
        }
    }
    if([aView isKindOfClass:[EaseCallPlaceholderView class]]) {
        EaseCallPlaceholderView* placeHolderView = (EaseCallPlaceholderView*)aView;
        if(placeHolderView && aUserName.length > 0) {
            placeHolderView.nameLabel.text = [[EaseCallManager sharedManager] getNicknameByUserName:aUserName];
            NSURL* url = [[EaseCallManager sharedManager] getHeadImageByUserName:aUserName];
            if(url) {
                [placeHolderView.placeHolder sd_setImageWithURL:url completed:nil];
            }
        }
    }
    
}

- (void)usersInfoUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showNicknameAndAvartarForUsername:[EMClient sharedClient].currentUsername view:self.localView];
        for(NSNumber* uid in self.streamViewsDic) {
            NSString * username = [[EaseCallManager sharedManager] getUserNameByUid:uid];
            if(username.length > 0) {
                EaseCallStreamView* view = [self.streamViewsDic objectForKey:uid];
                [self showNicknameAndAvartarForUsername:username view:view];
            }
        }
        for(NSString* username in self.placeHolderViewsDic) {
            EaseCallPlaceholderView* view = [self.placeHolderViewsDic objectForKey:username];
            [self showNicknameAndAvartarForUsername:username view:view];
        }
    });
    
}

- (BOOL)isEquivalent:(NSURL *)aURL1 with:(NSURL *)aURL2 {

    if ([aURL1 isEqual:aURL2]) return YES;
    if ([[aURL1 scheme] caseInsensitiveCompare:[aURL2 scheme]] != NSOrderedSame) return NO;
    if ([[aURL1 host] caseInsensitiveCompare:[aURL2 host]] != NSOrderedSame) return NO;

    // NSURL path is smart about trimming trailing slashes
    // note case-sensitivty here
    if ([[aURL1 path] compare:[aURL2 path]] != NSOrderedSame) return NO;

    // at this point, we've established that the urls are equivalent according to the rfc
    // insofar as scheme, host, and paths match

    // according to rfc2616, port's can weakly match if one is missing and the
    // other is default for the scheme, but for now, let's insist on an explicit match
    if ([aURL1 port] || [aURL2 port]) {
        if (![[aURL1 port] isEqual:[aURL2 port]]) return NO;
        if (![[aURL1 query] isEqual:[aURL2 query]]) return NO;
    }

    // for things like user/pw, fragment, etc., seems sensible to be
    // permissive about these.
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
