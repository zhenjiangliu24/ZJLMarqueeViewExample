//
//  ZJLMarQueeView.h
//  ZJLMarqueeViewExample
//
//  Created by ZhongZhongzhong on 16/6/16.
//  Copyright © 2016年 ZhongZhongzhong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^loadImageComplete)(UIImage *image, NSUInteger index);
typedef void (^loadImageFailed)(NSError *error);

@interface ZJLMarQueeView : UIView
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)array placeholder:(UIImage *)placeholder;
@end
