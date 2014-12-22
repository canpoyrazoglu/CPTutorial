//
//  CPTutorialInvisibleProxyView.m
//
//  Created by Can Poyrazoğlu on 29.11.14.
//

#import "CPTutorialInvisibleProxyView.h"

@implementation CPTutorialInvisibleProxyView{
    CGRect lastFrame;
}


-(void)drawRect:(CGRect)rect{
    //empty implementation. we shouldn't draw.
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
}


-(void)setOpaque:(BOOL)opaque{
    [super setOpaque:NO];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [super setOpaque:NO];
    return self;
}

+(instancetype)proxyView{
    CPTutorialInvisibleProxyView *view = [[CPTutorialInvisibleProxyView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.contentMode = UIViewContentModeRedraw;
    //immediately calling sequentially results in incorrect frame for some reason. this works though. yeah, a bit ugly code but it works nice. just don't open Pandora's "black" box :)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DBL_EPSILON * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect globalFrame = [view.superview.superview convertRect:view.superview.frame toView:[[view.delegate tutorialView] superview]];
        if([view.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
            [view.delegate attachedViewFrameDidChange:globalFrame];
        }
    });
    return view;
    
    
}

-(void)didMoveToSuperview{
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    [self.superview sendSubviewToBack:self];
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
}

-(void)didMoveToWindow{
    [self.delegate setHidden:!self.window];
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if(self.superview){
        CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[self.delegate tutorialView]];
        if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
            [self.delegate attachedViewFrameDidChange:globalFrame];
        }
    }
}

@end
