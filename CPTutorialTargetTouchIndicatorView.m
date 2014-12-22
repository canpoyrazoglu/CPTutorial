//
//  CPTutorialTargetTouchIndicatorView.m
//
//  Created by Can Poyrazoğlu on 20.12.14.
//

#import "CPTutorialTargetTouchIndicatorView.h"

@implementation CPTutorialTargetTouchIndicatorView{
    BOOL shouldStopAnimating;
}

-(void)refreshLayout{
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2;
    self.backgroundColor = [UIColor redColor];
}

-(void)initializeView{
    [self refreshLayout];
    [self beginAnimating];
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self refreshLayout];
}

-(void)didMoveToWindow{
    [super didMoveToWindow];
    [self refreshLayout];
}

-(instancetype)init{
    self = [super init];
    [self initializeView];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self initializeView];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self initializeView];
    return self;
}

-(void)animate{
    if(shouldStopAnimating){
        shouldStopAnimating = NO;
        return;
    }
    [UIView animateWithDuration:1.f animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.4 animations:^{
            self.alpha = 0.5;
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
             [self animate];
        }];
    }];
}

-(void)beginAnimating{
    [self animate];
}

@end
