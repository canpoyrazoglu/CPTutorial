//
//  CPTutorialInvisibleProxyView.m
//
//  Created by Can Poyrazoğlu on 29.11.14.
//

#import "CPTutorialInvisibleProxyView.h"

@implementation CPTutorialInvisibleProxyView


-(void)drawRect:(CGRect)rect{
    //empty implementation
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
}


-(void)setOpaque:(BOOL)opaque{
    [super setOpaque:NO];
}

+(instancetype)proxyView{
    CPTutorialInvisibleProxyView *view = [[CPTutorialInvisibleProxyView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    view.opaque = NO;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.contentMode = UIViewContentModeRedraw;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DBL_EPSILON * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect globalFrame = [view.superview.superview convertRect:view.superview.frame toView:[[view.delegate tutorialView] superview]];
        //NSLog(@"after 2 sec %@", NSStringFromCGRect(globalFrame));
        if([view.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
            [view.delegate attachedViewFrameDidChange:globalFrame];
        }
    });
    return view;
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    //NSLog(@"observe %@", NSStringFromCGRect(globalFrame));
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
}

-(void)didMoveToSuperview{
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    NSLog(@"didmove to super: %@ %@", self.superview, NSStringFromCGRect(globalFrame));
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
    UIView *view = self.superview;
    if(!view){
        
    }
    while (view) {
        //[view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        //[view addObserver:self forKeyPath:@"superview" options:NSKeyValueObservingOptionNew context:nil];
        view = view.superview;
    }
}

-(void)didMoveToWindow{
    NSLog(@"did move to window: %@", self.window);
    [self.delegate setHidden:!self.window];
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[[self.delegate tutorialView] superview]];
    //NSLog(@"didmove to win %@", NSStringFromCGRect(globalFrame));
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
    UIView *view = self.superview;
    while (view) {
        //[view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        //[view addObserver:self forKeyPath:@"superview" options:NSKeyValueObservingOptionNew context:nil];
        view = view.superview;
    }
}

-(void)setFrame:(CGRect)frame{
    //[super setFrame:frame];
    //find global frame
    CGRect globalFrame = [self.superview.superview convertRect:self.superview.frame toView:[self.delegate tutorialView]];
    //NSLog(@"setframe %@", NSStringFromCGRect(globalFrame));
    if([self.delegate respondsToSelector:@selector(attachedViewFrameDidChange:)]){
        [self.delegate attachedViewFrameDidChange:globalFrame];
    }
    
}

@end
