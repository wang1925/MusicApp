//
//  HTListViewController.m
//  MusicApp
//
//  Created by 王浩田 on 2018/7/21.
//  Copyright © 2018年 MusicApp. All rights reserved.
//

#import "HTListViewController.h"
#import "HTMusicViewController.h"

@interface HTListViewController ()
@property (nonatomic, strong) UIButton *musicBtn;

@end

@implementation HTListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Home";
    [self configUI];
}

- (void)configUI{
    self.musicBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.view addSubview:self.musicBtn];
    self.musicBtn.center = self.view.center;
    self.musicBtn.backgroundColor = [UIColor redColor];
    [self.musicBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.musicBtn setTitle:@"Play" forState:UIControlStateNormal];
    [self.musicBtn addTarget:self action:@selector(jumpToMusicPage) forControlEvents:UIControlEventTouchUpInside];
}
- (void)jumpToMusicPage{
    HTMusicViewController *controller = [[HTMusicViewController alloc]init];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
