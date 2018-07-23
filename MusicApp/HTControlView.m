//
//  HTControlView.m
//  MusicApp
//
//  Created by 王浩田 on 2018/7/22.
//  Copyright © 2018年 MusicApp. All rights reserved.
//

#import "HTControlView.h"

@implementation HTControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI{
    self.sliderView = [[UISlider alloc]initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, 20)];
    [self addSubview:self.sliderView];
    self.sliderView.thumbTintColor = [UIColor yellowColor];
    self.sliderView.minimumTrackTintColor = [UIColor redColor];
    self.sliderView.maximumTrackTintColor = [UIColor blueColor];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(self.frame.size.width/2-30, 60, 60, 60);
    [self addSubview:self.playBtn];
    self.playBtn.backgroundColor = [UIColor redColor];
    [self.playBtn setTitle:@"播" forState:UIControlStateNormal];
    [self.playBtn setTitle:@"停" forState:UIControlStateSelected];
    
    self.preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.preBtn.frame = CGRectMake(20, 60, 60, 60);
    [self addSubview:self.preBtn];
    self.preBtn.backgroundColor = [UIColor redColor];
    [self.preBtn setTitle:@"上" forState:UIControlStateNormal];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.frame = CGRectMake(self.frame.size.width -60-20, 60, 60, 60);
    [self addSubview:self.nextBtn];
    self.nextBtn.backgroundColor = [UIColor redColor];
    [self.nextBtn setTitle:@"下" forState:UIControlStateNormal];
}
@end
