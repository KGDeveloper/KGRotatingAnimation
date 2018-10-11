# KGRotatingAnimation
简单的一个iOS旋转木马效果

下面介绍下实现调用方法:
1.首先调用头文件：#import "CustomView.h"
2.然后遵守代理方法：<CustomViewDataSource,CustomViewDelegate>
3.创建对象
@property (nonatomic,strong) CustomView *animationView;
// MARK: --创建动画视图--
- (void)setAnimationView{
    self.animationView = [[CustomView alloc]initWithFrame:self.view.bounds];
    self.animationView.dataSource = self;
    self.animationView.delegate = self;
    [self.view addSubview:self.animationView];
    [self.animationView reloadAnimationView];
}
然后实现数据源代理方法
// MARK: --CustomViewDataSource--
- (NSInteger)numberOfAnimationWithView:(CustomView *)view{
    return self.dataSource.count;
}
- (UIView *)itemsWtihAnimationView:(NSInteger)index animationView:(CustomView *)animationView{
    UIButton *tmp = [UIButton buttonWithType:UIButtonTypeCustom];
    tmp.frame = CGRectMake(0, 0, 50, 50);
    [tmp setImage:self.dataSource[index] forState:UIControlStateNormal];
    return tmp;
}
然后实现代理方法
// MARK: --CustomViewDelegate--
- (void)didSelectItem:(NSInteger)index animationView:(CustomView *)animationView{
    
}
我想这样应该可以看明白了吧？
