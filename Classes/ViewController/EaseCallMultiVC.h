//
//  EaseCallMultiVC.h
//  EaseCallKit
//
//  Created by 杨剑 on 2025/7/24.
//

#import <UIKit/UIKit.h>
#import "EaseCallStreamView.h"
#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseCallMultiVC : UIViewController
@property (nonatomic,strong) UIButton* microphoneButton;
@property (nonatomic,strong) UIButton* enableCameraButton;
@property (nonatomic,strong) UIButton* switchCameraButton;
@property (nonatomic,strong) UIButton* speakerButton;
@property (nonatomic,strong) UIButton* hangupButton;
@property (nonatomic,strong) UIButton* answerButton;
@property (nonatomic,strong) UILabel* timeLabel;
@property (strong, nonatomic) NSTimer *timeTimer;
@property (nonatomic, assign) int timeLength;
@property (nonatomic,strong) UILabel* microphoneLabel;
@property (nonatomic,strong) UILabel* enableCameraLabel;
@property (nonatomic,strong) UILabel* switchCameraLabel;
@property (nonatomic,strong) UILabel* speakerLabel;
@property (nonatomic,strong) UILabel* hangupLabel;
@property (nonatomic,strong) UILabel* acceptLabel;
@property (nonatomic,strong) UIButton* miniButton;
@property (nonatomic,strong) UIView* contentView;
@property (nonatomic) EaseCallStreamView* floatingView;
@property (nonatomic) BOOL isMini;

@property (nonatomic,strong) UILabel* remoteNameLable;
@property (nonatomic,strong) NSString* inviterId;
@property (nonatomic,strong) UIImageView* remoteHeadView;
@property (nonatomic) EaseCallStreamView* localView;
@property (nonatomic) NSMutableDictionary* streamViewsDic;

- (void)hangupAction;
- (void)muteAction;
- (void)enableVideoAction;
- (void)startTimer;
- (void)answerAction;
- (void)miniAction;
- (void)usersInfoUpdated;


- (void)addRemoteView:(UIView*)remoteView member:(NSNumber*)uId enableVideo:(BOOL)aEnableVideo;
- (void)removeRemoteViewForUser:(NSNumber*)uId;
- (void)setRemoteMute:(BOOL)aMuted uid:(NSNumber*)uId;
- (void)setRemoteEnableVideo:(BOOL)aEnabled uId:(NSNumber*)uId;
- (void)setLocalVideoView:(UIView*)localView enableVideo:(BOOL)aEnableVideo;
- (void)setRemoteViewNickname:(NSString*)aNickname headImage:(NSURL*)url uId:(NSNumber*)aUid;
- (UIView*) getViewByUid:(NSNumber*)uId;
- (void)setPlaceHolderUrl:(NSURL*)url member:(NSString*)uId;
- (void)removePlaceHolderForMember:(NSString*)uId;

@end

NS_ASSUME_NONNULL_END
