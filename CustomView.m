//
//  CustomView.m
//  文艺星球
//
//  Created by 文艺星球 on 2018/10/9.
//  Copyright © 2018年 KG丿轩帝. All rights reserved.
//

#import "CustomView.h"

#define KGWidth [UIScreen mainScreen].bounds.size.width
#define KGHeight [UIScreen mainScreen].bounds.size.height

@interface CustomView (){
    NSTimer *_timer;
}
//:--保存对象--
@property (nonatomic,strong) NSMutableArray *items;
//:--保存原始数据--
@property (nonatomic,copy) NSArray *originalItems;
//:--是否开始下一个小球运动--
@property (nonatomic,assign) BOOL isMovement;
//:--是否是默认运动方向--
@property (nonatomic,assign) BOOL isDefaultMovement;

@end

@implementation CustomView

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftAction)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:leftSwipe];
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightAction)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:rightSwipe];
        
        self.isDefaultMovement = YES;
        
    }
    return self;
}
// MARK: --左滑收拾--
- (void)leftAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeMovementStare" object:@{@"stare":@"left"}];
    self.isDefaultMovement = YES;
}
// MARK: --右滑收拾--
- (void)rightAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeMovementStare" object:@{@"stare":@"right"}];
    self.isDefaultMovement = NO;
}
// MARK: --刷新页面--
- (void)reloadAnimationView{
    self.items = [NSMutableArray array];
    
    self.isMovement = YES;
    //:--首先获取到有多少item--
    NSInteger count = [self.dataSource numberOfAnimationWithView:self];
    if (count > 0) {
        for (int i = 0; i < count; i++) {
            //:--将对象添加到数组中--
            [self.items addObject:[self.dataSource itemsWtihAnimationView:i animationView:self]];
        }
    }
    self.originalItems = self.items.copy;
    [self addItemsToFatherView];
}
// MARK: --添加items到显示视图--
- (void)addItemsToFatherView{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(changeImagePoint) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
// MARK: --创建运动小球--
- (void)changeImagePoint{
    if (self.isMovement == YES) {
        UIView *animation;
        CustomAnimationView *animationView;
        if (self.isDefaultMovement == YES) {
            animation = [self.items firstObject];
            animationView = [[CustomAnimationView alloc]initWithFrame:CGRectMake(0, 70, 50, 50) items:animation direction:MovementDirectionLeft];
        }else{
            animation = [self.items lastObject];
            animationView = [[CustomAnimationView alloc]initWithFrame:CGRectMake(0, 70, 50, 50) items:animation direction:MovementDirectionRight];
        }
        [self addSubview:animationView];
        [self.items removeObject:animation];
        self.isMovement = NO;
        __weak typeof(self) weakSelf = self;
        //:--当小球运动结束，从视图中移除，然后添加到数据中--
        animationView.moveEndSendItem = ^(UIView * _Nonnull item) {
            [weakSelf.items addObject:item];
        };
        //:--当小球运动到一定位置，开始下一个小球运动--
        animationView.moveStarSendItem = ^{
            if (weakSelf.isMovement == NO) {
                weakSelf.isMovement = YES;
            }
        };
        //:--点击小球消息传递--
        animationView.didSelectItem = ^(UIView * _Nonnull item) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectItem:animationView:)]) {
                [weakSelf.originalItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isEqual:item]) {
                        [weakSelf.delegate didSelectItem:idx animationView:weakSelf];
                        *stop = YES;
                    }
                }];
            }
        };
        self.isMovement = NO;
    }
}


@end

@interface CustomAnimationView (){
    NSTimer *_timer;
    CGFloat width;//:--运动起始位置--
    BOOL isReturn;//:--是否开始返回运动--
}

/**
 接受传进来的UIView对象
 */
@property (nonatomic,strong) UIView *animationView;
/**
 控制是否是顺时针旋转
 */
@property (nonatomic,assign) MovementDirection direction;

@end

@implementation CustomAnimationView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangeMovementStare" object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame items:(nonnull UIView *)item direction:(MovementDirection)direction{
    if (self = [super initWithFrame:frame]) {
        
        width = 0;
        isReturn = NO;
        self.direction = direction;
        self.animationView = item;
        self.animationView.userInteractionEnabled = NO;
        [self addSubview:self.animationView];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(changeImagePoint) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMovementStare:) name:@"ChangeMovementStare" object:nil];
        
    }
    return self;
}
- (void)changeMovementStare:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    if ([dic[@"stare"] isEqualToString:@"left"]) {
        self.direction = MovementDirectionLeft;
    }else{
        self.direction = MovementDirectionRight;
    }
}
// MARK: --改变中心点--
- (void)changeImagePoint{
    if (self.direction == MovementDirectionLeft || self.direction == MovementDirectionDefault) {
        [self starTurnLeft];
    }else{
        [self starTurnRight];
    }
}
// MARK: --开始顺时针转动--
- (void)starTurnLeft{
    if (isReturn == NO) {//:--如果刚开始运动--
        NSNumber *a = [NSNumber numberWithFloat:width];
        NSNumber *b = [NSNumber numberWithFloat:250.0f];
        if ([a compare:b] == NSOrderedAscending) {
            width = width + 0.1;
            NSNumber *c = [NSNumber numberWithFloat:70.0f];
            if ([a compare:c] == NSOrderedSame) {//:--如果a==c，想父视图发送通知，开始下一个运动--
                if (self.moveStarSendItem) {
                    self.moveStarSendItem();
                }
            }
        }else{
            width = width - 0.1;
            isReturn = YES;
        }
    }else{//:--开始返回运动--
        NSNumber *a = [NSNumber numberWithFloat:width];
        NSNumber *b = [NSNumber numberWithFloat:-25.0f];
        if ([b compare:a] == NSOrderedAscending) {
            width = width - 0.1;
        }else{
            [_timer invalidate];
            _timer = nil;
            [self removeFromSuperview];
            if (self.moveEndSendItem) {//:--如果运动结束，从父视图移除，然后x发送通知到父视图--
                self.moveEndSendItem(self.animationView);
            }
        }
    }
    CGFloat result = 1 - powf(width, 2)/powf(250, 2);
    CGFloat height;
    if (isReturn == NO) {
        height = -sqrtf(result)*100 + KGHeight/2;
    }else{
        height = sqrtf(result)*100 + KGHeight/2;
    }
    self.center = CGPointMake(width, height);
}
// MARK: --开始逆时针转动--
- (void)starTurnRight{
    if (isReturn == NO) {//:--如果刚开始运动--
        NSNumber *a = [NSNumber numberWithFloat:width];
        NSNumber *b = [NSNumber numberWithFloat:250.0f];
        if ([a compare:b] == NSOrderedAscending) {
            width = width + 0.1;
            NSNumber *c = [NSNumber numberWithFloat:70.0f];
            if ([a compare:c] == NSOrderedSame) {//:--如果a==c，想父视图发送通知，开始下一个运动--
                if (self.moveStarSendItem) {
                    self.moveStarSendItem();
                }
            }
        }else{
            width = width - 0.1;
            isReturn = YES;
        }
    }else{//:--开始返回运动--
        NSNumber *a = [NSNumber numberWithFloat:width];
        NSNumber *b = [NSNumber numberWithFloat:-25.0f];
        if ([b compare:a] == NSOrderedAscending) {
            width = width - 0.1;
        }else{
            [_timer invalidate];
            _timer = nil;
            [self removeFromSuperview];
            if (self.moveEndSendItem) {//:--如果运动结束，从父视图移除，然后x发送通知到父视图--
                self.moveEndSendItem(self.animationView);
            }
        }
    }
    CGFloat result = 1 - powf(width, 2)/powf(250, 2);
    CGFloat height;
    if (isReturn == NO) {
        height = sqrtf(result)*100 + KGHeight/2;
    }else{
        height = -sqrtf(result)*100 + KGHeight/2;
    }
    self.center = CGPointMake(width, height);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.didSelectItem) {
        self.didSelectItem(self.animationView);
    }
}

@end


