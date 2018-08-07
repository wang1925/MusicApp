//
//  HTMusicViewController.m
//  MusicApp
//
//  Created by 王浩田 on 2018/7/21.
//  Copyright © 2018年 MusicApp. All rights reserved.
//

#import "HTMusicViewController.h"
#import "HTControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "wslAnalyzer.h"
#import "wslLrcEach.h"
#import <notify.h>

#define SONGNAME @"多幸运"
@interface HTMusicViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    id _playerTimeObserver;
    BOOL _isDragging;
    UIImage *_lastImage;//最后一次锁屏之后的歌词海报
}
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HTControlView *controlView;
@property (nonatomic, assign) NSInteger songIndex;
@property (nonatomic, strong) NSMutableArray *songArr;
//歌词数组
@property (nonatomic, strong) NSMutableArray *lrcArray;
//当前歌词所在位置
@property (nonatomic,assign)  NSInteger currentRow;
//用来显示锁屏歌词
@property (nonatomic, strong) UITableView *lockScreenTableView;
//锁屏图片视图,用来绘制带歌词的image
@property (nonatomic, strong) UIImageView *lrcImageView;

@end

@implementation HTMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.songIndex = 0;
    
//    [self getLrcArray];
    [self configUI];
    [self configPlayer];
//    [self.player play];
    self.controlView.playBtn.selected = YES;
    
    [self configBackgroundAudioSetting];
    [self createRemoteCommandCenterStyleNormal];
}
#pragma mark- Player
- (void)configPlayer{
    [self getLrcArray];
    
    NSDictionary *currentSong = self.songArr[self.songIndex];
    self.title = currentSong[@"name"];
    
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:currentSong[@"name"] ofType:@"mp3"];
    self.player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:pathStr]];
    
    [self.player play];
    [self playControlAndObserver];
}
//获得歌词数组
- (void)getLrcArray{
    NSDictionary *currentSong = self.songArr[self.songIndex];
    
    wslAnalyzer *analyzer = [[wslAnalyzer alloc] init];
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:currentSong[@"name"] ofType:@"txt"];
    self.lrcArray = [analyzer analyzerLrcBylrcString:[NSString stringWithContentsOfFile:pathStr encoding:NSUTF8StringEncoding error:nil]];
    
    self.currentRow = 0;
    [self.tableView reloadData];
}
#pragma mark- UI
- (void)configUI{
    self.controlView = [[HTControlView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height -150, self.view.frame.size.width, 150)];
    [self.view addSubview:self.controlView];
    [self.controlView.playBtn addTarget:self action:@selector(controlPlayOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.preBtn addTarget:self action:@selector(controlPreviousAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.nextBtn addTarget:self action:@selector(controlNextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.sliderView addTarget:self action:@selector(controlSliderBeginAction:) forControlEvents:UIControlEventTouchDown];
    [self.controlView.sliderView addTarget:self action:@selector(controlSliderEndAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-150) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"backgroundImage5.jpg"];
    self.tableView.backgroundView = imageView;
    self.tableView.separatorStyle = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}
#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _lrcArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    wslLrcEach * lrcEach = _lrcArray[indexPath.row];
    cell.textLabel.text = lrcEach.lrc;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    if (self.currentRow == indexPath.row) {
        cell.textLabel.textColor = [UIColor greenColor];
    }else{
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isDragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _isDragging = NO;
}
#pragma mark- 锁屏界面开启和监控远程控制事件
/* iOS 7.1之前 */
- (void)createRemoteCommandCenterStyleOld{
    //让App开始接收远程控制事件, 该方法属于UIApplication类
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //结束远程控制,需要的时候关闭
    //     [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    //处理控制台的暂停/播放、上/下一首事件
    [[NSNotificationCenter defaultCenter] addObserverForName:@"songRemoteControlNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

        NSInteger  eventSubtype = [notification.userInfo[@"eventSubtype"] integerValue];
        switch (eventSubtype) {
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"下一首");
            break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"上一首");
            break;
            case  UIEventSubtypeRemoteControlPause:
                [self.player pause];
            break;
            case  UIEventSubtypeRemoteControlPlay:
                [self.player play];
            break;
            //耳机上的播放暂停
            case  UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"播放或暂停");
            break;
            //后退
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
            break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                NSLog(@"后退");
            break;
            //快进
            case UIEventSubtypeRemoteControlBeginSeekingForward:
            break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
                NSLog(@"前进");
            break;
            default:
            break;
        }
    }];
}
/**
 *  iOS 7.1之后
 *  详情看官方文档：https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter
 */
- (void)createRemoteCommandCenterStyleNormal{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    //    commandCenter.togglePlayPauseCommand 耳机线控的暂停/播放
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"上一首");
        [self controlPreviousAction:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"下一首");
        [self controlNextAction:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //在控制台拖动进度条调节进度（仿QQ音乐的效果）
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            CMTime totlaTime = self.player.currentItem.duration;
            MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            [self.player seekToTime:CMTimeMake(totlaTime.value*playbackPositionEvent.positionTime/CMTimeGetSeconds(totlaTime), totlaTime.timescale) completionHandler:^(BOOL finished) {
            }];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    } else {
        // Fallback on earlier versions
    }
}
- (void)createRemoteCommandCenterStyleCustom{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
//    [self setSkipCommand:commandCenter];
//    [self setFeedbackCommand:commandCenter];
    [self setRatingCommand:commandCenter];
//    [self setPlayBackRateCommand:commandCenter];
    
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}
#pragma mark- 快进 Skip Forward&Backward
-(void)setSkipCommand:(MPRemoteCommandCenter *)commandCenter{
    MPSkipIntervalCommand *skipForwardIntervalCommand = [commandCenter skipForwardCommand];
    skipForwardIntervalCommand.preferredIntervals = @[@(15)];  // 快进 最大 99
    [skipForwardIntervalCommand setEnabled:YES];
    [skipForwardIntervalCommand addTarget:self action:@selector(skipForwardEvent:)];
    
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [commandCenter skipBackwardCommand];
    [skipBackwardIntervalCommand setEnabled:YES];
    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
    skipBackwardIntervalCommand.preferredIntervals = @[@(15)];  // 快退
}
-(void)skipForwardEvent:(MPSkipIntervalCommandEvent *)skipEvent{
    NSLog(@"快进了 %f秒", skipEvent.interval);
    
    CMTime totlaTime = self.player.currentItem.duration;
    __weak __typeof(self)weakSelf = self;
    [self.player seekToTime:CMTimeMake(totlaTime.value +skipEvent.interval, totlaTime.timescale) completionHandler:^(BOOL finished) {
        [weakSelf.player play];
    }];
}
-(void)skipBackwardEvent:(MPSkipIntervalCommandEvent *)skipEvent{
    NSLog(@"快退了 %f秒", skipEvent.interval);
    
    CMTime totlaTime = self.player.currentItem.duration;
    __weak __typeof(self)weakSelf = self;
    [self.player seekToTime:CMTimeMake(totlaTime.value -skipEvent.interval, totlaTime.timescale) completionHandler:^(BOOL finished) {
        [weakSelf.player play];
    }];
}
#pragma mark- Feedback列表
-(void)setFeedbackCommand:(MPRemoteCommandCenter *)commandCenter{
    MPFeedbackCommand *likeCommand = [commandCenter likeCommand];
    [likeCommand setEnabled:YES];
    [likeCommand setLocalizedTitle:@"喜欢"];  // can leave this out for default
    [likeCommand addTarget:self action:@selector(likeEvent:)];

    MPFeedbackCommand *dislikeCommand = [commandCenter dislikeCommand];
    [dislikeCommand setEnabled:YES];
    [dislikeCommand setLocalizedTitle:@"不喜欢"]; // can leave this out for default
    [dislikeCommand addTarget:self action:@selector(dislikeEvent:)];

//    BOOL userPreviouslyIndicatedThatTheyDislikedThisItemAndIStoredThat = YES;
//    if (userPreviouslyIndicatedThatTheyDislikedThisItemAndIStoredThat) {
//        [dislikeCommand setActive:YES];
//    }

    MPFeedbackCommand *bookmarkCommand = [commandCenter bookmarkCommand];
    [bookmarkCommand setEnabled:YES];
    [bookmarkCommand setLocalizedTitle:@"标记"]; // can leave this out for default
    [bookmarkCommand addTarget:self action:@selector(bookmarkEvent:)];
}

-(void)dislikeEvent:(MPFeedbackCommandEvent *)feedbackEvent{
    NSLog(@"喜欢");
}
-(void)likeEvent:(MPFeedbackCommandEvent *)feedbackEvent{
    NSLog(@"不喜欢");
}
-(void)bookmarkEvent:(MPFeedbackCommandEvent *)feedbackEvent{
    NSLog(@"标记");
}
#pragma mark- 评分 Rating
-(void)setRatingCommand:(MPRemoteCommandCenter *)commandCenter{
    MPRatingCommand *ratingCommand = [commandCenter ratingCommand];
    [ratingCommand setEnabled:YES];
    [ratingCommand setMinimumRating:0.0];
    [ratingCommand setMaximumRating:5.0];
    [ratingCommand addTarget:self action:@selector(ratingEvent:)];
}
-(void)ratingEvent:(MPRatingCommand *)commd{
    NSLog(@"评分");
}
#pragma mark- 倍速 PlaybackRate
-(void)setPlayBackRateCommand:(MPRemoteCommandCenter *)commandCenter{
    MPChangePlaybackRateCommand *playBackRateCommand = [commandCenter changePlaybackRateCommand];
    [playBackRateCommand setEnabled:YES];
    [playBackRateCommand setSupportedPlaybackRates:@[@(1),@(1.5),@(2)]];
    [playBackRateCommand addTarget:self action:@selector(playbackRateEvent:)];
}
-(void)playbackRateEvent:(MPChangePlaybackRateCommand*)rate{
    NSLog(@"倍速");
}

#pragma mark- 移除观察者
- (void)removeRemoteCommandCenterObserver{
    [self.player removeTimeObserver:_playerTimeObserver];
    _playerTimeObserver = nil;
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.likeCommand removeTarget:self];
    [commandCenter.dislikeCommand removeTarget:self];
    [commandCenter.bookmarkCommand removeTarget:self];
    [commandCenter.nextTrackCommand removeTarget:self];
    [commandCenter.skipForwardCommand removeTarget:self];
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand removeTarget:self];
    } else {
        // Fallback on earlier versions
    }
}
#pragma mark - Help Methods
//在具体的控制器或其它类中捕获处理远程控制事件,当远程控制事件发生时触发该方法, 该方法属于UIResponder类，iOS 7.1 之前经常用
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    NSLog(@"%ld",event.type);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"songRemoteControlNotification" object:self userInfo:@{@"eventSubtype":@(event.subtype)}];
}
//后台播放音频设置,需要在Capabilities->Background Modes中勾选Audio,Airplay,and Picture in Picture
- (void)configBackgroundAudioSetting{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}
//播放控制和监测
- (void)playControlAndObserver{
    __weak HTMusicViewController * weakSelf = self;
    _playerTimeObserver = [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMake(0.1*30, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        CGFloat currentTime = CMTimeGetSeconds(time);
        
        CMTime total = weakSelf.player.currentItem.duration;
        CGFloat totalTime = CMTimeGetSeconds(total);
        
        if (!_isDragging) {
            
            //歌词滚动显示
            for ( int i = (int)(self.lrcArray.count - 1); i >= 0 ;i--) {
                wslLrcEach * lrc = self.lrcArray[i];
                if (lrc.time < currentTime) {
                    self.currentRow = i;
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: self.currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    [self.tableView reloadData];
                    [self.lockScreenTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: self. currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    [self.lockScreenTableView reloadData];
                    break;
                }
            }
            
        }
        
        //监听锁屏状态 lock=1则为锁屏状态
        uint64_t locked;
        __block int token = 0;
        notify_register_dispatch("com.apple.springboard.lockstate",&token,dispatch_get_main_queue(),^(int t){
        });
        notify_get_state(token, &locked);
        
        //监听屏幕点亮状态 screenLight = 1则为变暗关闭状态
        uint64_t screenLight;
        __block int lightToken = 0;
        notify_register_dispatch("com.apple.springboard.hasBlankedScreen",&lightToken,dispatch_get_main_queue(),^(int t){
        });
        notify_get_state(lightToken, &screenLight);
        
        BOOL isShowLyricsPoster = NO;
        // NSLog(@"screenLight=%llu locked=%llu",screenLight,locked);
        if (screenLight == 0 && locked == 1) {
            //点亮且锁屏时
            isShowLyricsPoster = YES;
        }else if(screenLight){
            return;
        }
        
        //展示锁屏歌曲信息，上面监听屏幕锁屏和点亮状态的目的是为了提高效率
        [self updateLockScreenTotaltime:totalTime andCurrentTime:currentTime andLyricsPoster:isShowLyricsPoster];
    }];
}

//展示锁屏歌曲信息：图片、歌词、进度、演唱者
- (void)updateLockScreenTotaltime:(float)totalTime andCurrentTime:(float)currentTime andLyricsPoster:(BOOL)isShow{
    self.controlView.sliderView.value = currentTime/totalTime;
    NSDictionary *currentSong = self.songArr[self.songIndex];
    
    NSMutableDictionary *songDict = [[NSMutableDictionary alloc] init];
    //设置歌曲题目
    [songDict setObject:currentSong[@"name"] forKey:MPMediaItemPropertyTitle];
    //设置歌手名
    [songDict setObject:currentSong[@"artist"] forKey:MPMediaItemPropertyArtist];
    //设置专辑名
    [songDict setObject:currentSong[@"album"] forKey:MPMediaItemPropertyAlbumTitle];
    //设置歌曲时长
    [songDict setObject:[NSNumber numberWithDouble:totalTime]  forKey:MPMediaItemPropertyPlaybackDuration];
    //设置已经播放时长
    [songDict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    UIImage * lrcImage = [UIImage imageNamed:@"backgroundImage5.jpg"];
    if (isShow) {
        //制作带歌词的海报
        if (!_lrcImageView) {
            _lrcImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480,800)];
        }
        if (!_lockScreenTableView) {
            _lockScreenTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 800 - 44 * 7 + 20, 480, 44 * 3) style:UITableViewStyleGrouped];
            _lockScreenTableView.dataSource = self;
            _lockScreenTableView.delegate = self;
            _lockScreenTableView.separatorStyle = NO;
            _lockScreenTableView.backgroundColor = [UIColor clearColor];
            [_lockScreenTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
        }
        //主要为了把歌词绘制到图片上，已达到更新歌词的目的
        [_lrcImageView addSubview:self.lockScreenTableView];
        _lrcImageView.image = lrcImage;
        _lrcImageView.backgroundColor = [UIColor blackColor];
        
        //获取添加了歌词数据的海报图片
        UIGraphicsBeginImageContextWithOptions(_lrcImageView.frame.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [_lrcImageView.layer renderInContext:context];
        lrcImage = UIGraphicsGetImageFromCurrentImageContext();
        _lastImage = lrcImage;
        UIGraphicsEndImageContext();
    }else{
        if (_lastImage) {
            lrcImage = _lastImage;
        }
    }
    //设置显示的海报图片
    [songDict setObject:[[MPMediaItemArtwork alloc] initWithImage:lrcImage] forKey:MPMediaItemPropertyArtwork];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songDict];
}
#pragma mark- ControlView Action
- (void)controlPlayOrPauseAction:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.player play];
    }else{
        [self.player pause];
    }
}
- (void)controlPreviousAction:(UIButton *)sender{
    NSLog(@"上一曲");
    [self.player pause];
    [self changeSongIndexWithMode:NO];
    [self configPlayer];
}
- (void)controlNextAction:(UIButton *)sender{
    NSLog(@"下一曲");
    [self.player pause];
    [self changeSongIndexWithMode:YES];
    [self configPlayer];
}
- (void)changeSongIndexWithMode:(BOOL)next{
    NSInteger index = self.songIndex;
    if (next) {
        index = self.songIndex +1 <= self.songArr.count ?self.songIndex +1 :self.songArr.count-1;
    }else{
        index = self.songIndex -1 > 0 ?self.songIndex -1 :0;
    }
    self.songIndex = index;
}
- (void)controlSliderBeginAction:(UISlider *)sender{
    NSLog(@"进度条滑动开始");
    [self.player pause];
}
- (void)controlSliderEndAction:(UISlider *)sender{
    NSLog(@"进度条滑动结束");
    
    CMTime totlaTime = self.player.currentItem.duration;
    __weak __typeof(self)weakSelf = self;
    [self.player seekToTime:CMTimeMake(totlaTime.value*sender.value, totlaTime.timescale) completionHandler:^(BOOL finished) {
        [weakSelf.player play];
    }];
}
#pragma mark - Getter
- (NSMutableArray *)songArr{
    if (_songArr == nil) {
        NSArray *tmpArr = @[@{@"name":@"多幸运",@"artist":@"韩安旭",@"album":@"专辑名"},
                            @{@"name":@"父亲",@"artist":@"筷子兄弟",@"album":@"专辑名"}];
        _songArr = [NSMutableArray arrayWithArray:tmpArr];
    }
    return _songArr;
}
#pragma mark-
- (void)dealloc{
    [self removeRemoteCommandCenterObserver];
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; //只支持这一个方向(正常的方向)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
