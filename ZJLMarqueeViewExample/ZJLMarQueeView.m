//
//  ZJLMarQueeView.m
//  ZJLMarqueeViewExample
//
//  Created by ZhongZhongzhong on 16/6/16.
//  Copyright © 2016年 ZhongZhongzhong. All rights reserved.
//

#import "ZJLMarQueeView.h"
#import "NSString+MD5.h"

static const CGFloat PAGE_CONTROL_HEIGHT = 30.0f;

@interface ZJLMarQueeView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *frontImageView;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic, strong) UIImageView *endImageView;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, copy) NSArray *imageURLs;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger currentIndex;
@end

@implementation ZJLMarQueeView
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)array placeholder:(UIImage *)placeholder
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageWidth = frame.size.width;
        _imageHeight = frame.size.height;
        _imageURLs = array;
        _placeholder = placeholder;
        [self initView];
        [self initImages];
        [self startTimer];
    }
    return self;
}

- (void)initView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _imageWidth, _imageHeight)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    _frontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageWidth, _imageHeight)];
    _frontImageView.image = _placeholder;
    [_scrollView addSubview:_frontImageView];
    
    _currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_imageWidth, 0, _imageWidth, _imageHeight)];
    _currentImageView.image = _placeholder;
    [_scrollView addSubview:_currentImageView];
    
    _endImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_imageWidth*2, 0, _imageWidth, _imageHeight)];
    _endImageView.image = _placeholder;
    [_scrollView addSubview:_endImageView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _imageHeight-PAGE_CONTROL_HEIGHT, _imageWidth, PAGE_CONTROL_HEIGHT)];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = _images.count;
    _pageControl.hidden = NO;
    [self addSubview:_pageControl];
    
    [_scrollView setContentSize:CGSizeMake(3*_imageWidth, _imageHeight)];
    [_scrollView setContentOffset:CGPointMake(_imageWidth, 0) animated:YES];
    
}


- (void)initImages
{
    _images = [NSMutableArray arrayWithCapacity:self.imageURLs.count];
    [_imageURLs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_images addObject:_placeholder];
        NSString *urlString = (NSString *)obj;
        [self getImageWithURLString:urlString index:idx complete:^(UIImage *image, NSUInteger index) {
            [_images replaceObjectAtIndex:index withObject:image];
        }];
    }];
}

- (void)getImageWithURLString:(NSString *)urlString index:(NSUInteger)index complete:(loadImageComplete)complete{
    NSString *md5String = [urlString MD5String];
    NSString *cacheString = [self cachePathWithMD5:md5String];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:cacheString];
    if (isExist) {
        NSData *data = [NSData dataWithContentsOfFile:cacheString];
        UIImage *image = [UIImage imageWithData:data];
        complete(image,index);
        if (index==0) {
            _currentImageView.image = image;
        }else if (index==1){
            _endImageView.image = image;
        }
    }else{
        [self downloadImageWithURLString:urlString index:index complete:^(UIImage *image, NSUInteger index) {
            if (image) {
                complete(image,index);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (index==0) {
                        _currentImageView.image = image;
                    }else if (index==1){
                        _endImageView.image = image;
                    }
                });
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = UIImagePNGRepresentation(image);
                    [data writeToFile:cacheString atomically:YES];
                });
            }
        } error:^(NSError *error) {
            NSLog(@"error %@",error);
        }];
    }
}

- (void)downloadImageWithURLString:(NSString *)urlString index:(NSUInteger)index complete:(loadImageComplete)complete error:(loadImageFailed)failed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                complete(image,index);
            }
            if (error) {
                failed(error);
            }
        }] resume];
    });
}

- (NSString *)cachePathWithMD5:(NSString *)md5String
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [path[0] stringByAppendingString:md5String];
    return cachePath;
}

- (void)startTimer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(startAnimateImage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)startAnimateImage
{
    [_scrollView setContentOffset:CGPointMake(2*_imageWidth, 0) animated:YES];
}

#pragma mark - scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = _scrollView.contentOffset.x;
    if (offset>=2*_imageWidth){
        _currentIndex++;
        _scrollView.contentOffset = CGPointMake(_imageWidth, 0);
        if (_currentIndex == _imageURLs.count-1) {
            _frontImageView.image = _images[_currentIndex-1];
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images[0];
            _pageControl.currentPage = _currentIndex;
            _currentIndex = -1;
        }else if (_currentIndex == _imageURLs.count){
            _frontImageView.image = _images.lastObject;
            _currentImageView.image = _images.firstObject;
            _endImageView.image = _images[1];
            _pageControl.currentPage = 0;
            _currentIndex = 0;
        }else if (_currentIndex == 0){
            _frontImageView.image = _images.lastObject;
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images[_currentIndex+1];
            _pageControl.currentPage = _currentIndex;
        }else{
            _frontImageView.image = _images[_currentIndex-1];
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images[_currentIndex+1];
            _pageControl.currentPage = _currentIndex;
        }
    }else if (offset<=0){
        _currentIndex--;
        _scrollView.contentOffset = CGPointMake(_imageWidth, 0);
        if (_currentIndex == -2) {
            _currentIndex = _images.count-2;
            _frontImageView.image = _images[_images.count-1];
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images.firstObject;
        }else if (_currentIndex == -1) {
            _currentIndex = _images.count-1;
            _frontImageView.image = _images[_currentIndex-1];
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images.firstObject;
        }else if (_currentIndex == 0){
            _frontImageView.image = _images.lastObject;
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images[_currentIndex +1];
        }else{
            _frontImageView.image = _images[_currentIndex -1];
            _currentImageView.image = _images[_currentIndex];
            _endImageView.image = _images[_currentIndex +1];
        }
        _pageControl.currentPage = _currentIndex;
    }
}
@end
