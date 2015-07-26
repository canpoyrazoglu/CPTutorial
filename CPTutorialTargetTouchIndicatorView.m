//
//  CPTutorialTargetTouchIndicatorView.m
//
//  Created by Can Poyrazoğlu on 20.12.14.
//

#import "CPTutorialTargetTouchIndicatorView.h"

@implementation CPTutorialTargetTouchIndicatorView

-(void)refreshLayout{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 4;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
}

-(void)initializeView{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.userInteractionEnabled = NO;
    [self refreshLayout];
    [self beginAnimating];
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self refreshLayout];
    if(!self.superview){
        [self endAnimating];
    }else{
        [self beginAnimating];
    }
}

-(void)didMoveToWindow{
    [super didMoveToWindow];
    [self refreshLayout];
    if(!self.window){
        [self endAnimating];
    }else{
        [self beginAnimating];
    }
}

-(void)removeFromSuperview{
    [self endAnimating];
    [super removeFromSuperview];
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

-(instancetype)display{
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    [self refreshLayout];
    return self;
}

-(void)animateAfterDelay:(float)delay extraVisible:(BOOL)extraVisible{
    self.opaque = NO;
    self.alpha = extraVisible ? 2 : 1;
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:1.5 delay:delay
                        options:(UIViewAnimationOptionRepeat
                                 | (extraVisible ? UIViewAnimationCurveEaseOut : UIViewAnimationOptionCurveEaseInOut)
                                 | UIViewAnimationOptionTransitionNone) animations:^{
                            self.alpha = 0;
                            self.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished) {
                            if(finished){
                                self.alpha = 1;
                            }
                        }];
}


-(void)beginAnimating{
    [self beginAnimatingAfterDelay:0 extraVisible:NO];
}

-(void)beginAnimatingAfterDelay:(float)delay extraVisible:(BOOL)extraVisible{
    [self refreshLayout];
    [self endAnimating];
    [self animateAfterDelay:delay extraVisible:extraVisible];
}

-(void)endAnimating{
    [self.layer removeAllAnimations];
}

@end
