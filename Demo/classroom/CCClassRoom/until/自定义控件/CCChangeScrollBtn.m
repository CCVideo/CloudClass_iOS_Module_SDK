//
//  CCChangeScrollBtn.m
//  CCClassRoom
//
//  Created by 刘强强 on 2020/4/1.
//  Copyright © 2020 cc. All rights reserved.
//

#import "CCChangeScrollBtn.h"
#import "HDSDocManager.h"
#import "CCDragView.h"


@interface CCChangeScrollBtn ()

///文档缩放----暂时就这么写了,不封装单独的view\了
@property(nonatomic,strong)UIButton *changeScrollBtn;
@property(nonatomic,strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,assign) CGPoint startPoint;
/**
 拖曳的方向，默认为any，任意方向
 */
@property (nonatomic,assign) WMDragDirection dragDirection;
/**
 活动范围，默认为父视图的frame范围内（因为拖出父视图后无法点击，也没意义）
 如果设置了，则会在给定的范围内活动
 如果没设置，则会在父视图范围内活动
 注意：设置的frame不要大于父视图范围
 注意：设置的frame为0，0，0，0表示活动的范围为默认的父视图frame，如果想要不能活动，请设置dragEnable这个属性为NO
 */
@property (nonatomic,assign) CGRect freeRect;
@property(nonatomic,strong)CCDocVideoView *ccVideoView;

@end

@implementation CCChangeScrollBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;
    HDSDocManager *hdsM = [HDSDocManager sharedDoc];
    self.ccVideoView = [hdsM hdsDocView];
    
    [self addSubview:self.changeScrollBtn];
    [self.changeScrollBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //添加移动手势可以拖动
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
}

///文档缩放------
-(UIButton *)changeScrollBtn {
    if (!_changeScrollBtn) {
        _changeScrollBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_changeScrollBtn setTitle:@"手势模式" forState:UIControlStateNormal];
        _changeScrollBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_changeScrollBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _changeScrollBtn.backgroundColor = UIColor.clearColor;//[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.3];
        _changeScrollBtn.layer.cornerRadius = 5;
        _changeScrollBtn.layer.masksToBounds = YES;
        [_changeScrollBtn addTarget:self action:@selector(changeScrollBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.ccVideoView setDocEditable:NO];

        [self.ccVideoView setHiddenSlider:NO];
    }
    return _changeScrollBtn;
}
-(void)changeScrollBtnAction:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    if (!btn.isSelected) {
        
        [btn setTitle:@"手势模式" forState:UIControlStateNormal];
        [self.ccVideoView setHiddenSlider:YES];
        [self.ccVideoView setDocEditable:NO];
    }else {
        [btn setTitle:@"绘制模式" forState:UIControlStateNormal];
        [self.ccVideoView setHiddenSlider:NO];
        [self.ccVideoView setDocEditable:YES];
    }
}
/**
 拖动事件
 @param pan 拖动手势
 */
-(void)dragAction:(UIPanGestureRecognizer *)pan{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{///开始拖动
            
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self.superview];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self.superview];
            //该view置于最前
            [self.superview bringSubviewToFront:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{///拖动中
            //计算位移 = 当前位置 - 起始位置
            
            CGPoint point = [pan translationInView:self.superview];
            float dx;
            float dy;
            switch (self.dragDirection) {
                case WMDragDirectionAny:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case WMDragDirectionHorizontal:
                    dx = point.x - self.startPoint.x;
                    dy = 0;
                    break;
                case WMDragDirectionVertical:
                    dx = 0;
                    dy = point.y - self.startPoint.y;
                    break;
                default:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self.superview];
            break;
        }
        case UIGestureRecognizerStateEnded:{///拖动结束
            [self keepBounds];
            
            break;
        }
        default:
            break;
    }
}
- (void)keepBounds{
    //中心点判断
    self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.frame.size.width)/2;
    CGRect rect = self.frame;
    if (self.frame.origin.x< centerX) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"leftMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.x = self.freeRect.origin.x;
        self.frame = rect;
        [UIView commitAnimations];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"rightMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
        self.frame = rect;
        [UIView commitAnimations];
    }
    
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}

@end
