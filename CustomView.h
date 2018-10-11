//
//  CustomView.h
//  文艺星球
//
//  Created by 文艺星球 on 2018/10/9.
//  Copyright © 2018年 KG丿轩帝. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CustomView;

@protocol CustomViewDataSource <NSObject>
/**
 获取数据源中对象个数

 @param view 数据加载对象
 @return 返回个数
 */
- (NSInteger)numberOfAnimationWithView:(CustomView *)view;
/**
 获取每个索引对应的对象

 @param index 索引
 @param animationView 数据对象
 @return item显示内容
 */
- (UIView *)itemsWtihAnimationView:(NSInteger)index animationView:(CustomView *)animationView;

@end

@protocol CustomViewDelegate <NSObject>
/*
 点击item后调用
 */
- (void)didSelectItem:(NSInteger)index animationView:(CustomView *)animationView;

@end

@interface CustomView : UIView

@property (nonatomic,weak) id<CustomViewDataSource>dataSource;
@property (nonatomic,weak) id<CustomViewDelegate>delegate;

/**
 刷新
 */
- (void)reloadAnimationView;

@end

typedef NS_ENUM(NSInteger,MovementDirection){
    MovementDirectionLeft = 0,
    MovementDirectionRight,
    MovementDirectionDefault,
};

// MARK: --显示itemView--
@interface CustomAnimationView : UIView

@property (nonatomic,copy) void(^moveEndSendItem)(UIView *item);
@property (nonatomic,copy) void(^moveStarSendItem)(void);
@property (nonatomic,copy) void(^didSelectItem)(UIView *item);

- (instancetype)initWithFrame:(CGRect)frame items:(UIView *)item direction:(MovementDirection)direction;

@end

NS_ASSUME_NONNULL_END
