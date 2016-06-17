//
//  ViewController.m
//  ZJLMarqueeViewExample
//
//  Created by ZhongZhongzhong on 16/6/16.
//  Copyright © 2016年 ZhongZhongzhong. All rights reserved.
//

#import "ViewController.h"
#import "ZJLMarQueeView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *images = @[@"http://img.article.pchome.net/00/43/41/54/pic_lib/wm/3.jpg",
                        @"http://f.hiphotos.baidu.com/image/h%3D200/sign=658bab6a553d269731d30f5d65fab24f/0dd7912397dda1446853fa12b6b7d0a20cf4863c.jpg",
                        @"http://img.shu163.com/uploadfiles/wallpaper/2010/6/2010073106154112.jpg",
                        @"http://c.hiphotos.bdimg.com/album/w%3D2048/sign=a3a806ef6609c93d07f209f7ab05fadc/d50735fae6cd7b89f4ee76620e2442a7d8330e54.jpg",
                        @"http://h.hiphotos.baidu.com/image/pic/item/8694a4c27d1ed21b61797af2ae6eddc451da3f70.jpg"];
    ZJLMarQueeView *MQView = [[ZJLMarQueeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) images:images placeholder:[UIImage imageNamed:@"loading"]];
    [self.view addSubview:MQView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
