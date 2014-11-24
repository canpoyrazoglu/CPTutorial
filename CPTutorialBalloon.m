//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import "CPTutorialBalloon.h"
#import "CPTutorial.h"

#define ADD_NEXT_LINE (CGPathAddLineToPoint(path, nil, next.x, next.y))
#define ADD_NEXT_ARC (CGPathAddArcToPoint(path, nil, control.x, control.y, next.x, next.y, self.cornerRadius))

#define CUSTOM_TIMING_FUNCTION ([CAMediaTimingFunction functionWithControlPoints:.44 :.87 :1 :1])

NSString *const CPTutorialSettingBorderColor = @"borderColor";
NSString *const CPTutorialSettingBorderWidth = @"borderWidth";
NSString *const CPTutorialSettingCornerRadius = @"cornerRadius";
NSString *const CPTutorialSettingTipSize = @"tipSize";
NSString *const CPTutorialSettingFillColor = @"fillColor";
NSString *const CPTutorialSettingManualTipPosition = @"manualTipPosition";
NSString *const CPTutorialSettingTipAboveBalloon = @"tipAboveBalloon";
NSString *const CPTutorialSettingDismissOnTouch= @"dismissOnTouch";
NSString *const CPTutorialSettingAnimationType = @"animationType";
NSString *const CPTutorialSettingDisplayDelay = @"displayDelay";
NSString *const CPTutorialSettingContentPadding = @"contentPadding";

typedef enum{
    TutorialDrawModeNoTargetView = 0,
    TutorialDrawModeAboveTargetView,
    TutorialDrawModeBelowTargetView,
}TutorialDrawMode;

static NSMutableDictionary *_CPTutorialBalloonDefaults;

@implementation CPTutorialBalloon{
    TutorialDrawMode drawMode;
    UILabel *textLabel;
    NSLayoutConstraint *textLabelTopConstraint;
    NSLayoutConstraint *textLabelBottomConstraint;
}

-(void)setCornerRadius:(float)cornerRadius{
    _cornerRadius = cornerRadius;
    if(_cornerRadius){
        self.opaque = NO;
    }
}

+(void)initialize{
    [super initialize];
    _CPTutorialBalloonDefaults =
    [@{
      CPTutorialSettingBorderColor: [UIColor grayColor],
      CPTutorialSettingAnimationType: @"collapse",
      CPTutorialSettingBorderWidth: @(2.0f),
      CPTutorialSettingCornerRadius: @(10.0f),
      CPTutorialSettingDismissOnTouch: @(YES),
      CPTutorialSettingDisplayDelay: @(0.0f),
      CPTutorialSettingFillColor: [UIColor whiteColor],
      CPTutorialSettingManualTipPosition: @(NO),
      CPTutorialSettingTipAboveBalloon: @(NO),
      CPTutorialSettingTipSize: [NSValue valueWithCGSize:CGSizeMake(18, 14)],
      CPTutorialSettingContentPadding: @(10.0f),
      } mutableCopy];
}

-(instancetype)init{
    self = [super init];
    [self initializeDefaultValues];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self initializeDefaultValues];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self initializeDefaultValues];
    return self;
}

+(NSMutableDictionary*)defaultSettings{
    return _CPTutorialBalloonDefaults;
}

-(void)initializeDefaultValues{
    self.borderColor = _CPTutorialBalloonDefaults[CPTutorialSettingBorderColor];
    self.animationType = _CPTutorialBalloonDefaults[CPTutorialSettingAnimationType];
    self.borderWidth = [_CPTutorialBalloonDefaults[CPTutorialSettingBorderWidth] floatValue];
    self.cornerRadius = [_CPTutorialBalloonDefaults[CPTutorialSettingCornerRadius] floatValue];
    self.dismissOnTouch = [_CPTutorialBalloonDefaults[CPTutorialSettingDismissOnTouch] boolValue];
    self.displayDelay = [_CPTutorialBalloonDefaults[CPTutorialSettingDisplayDelay] floatValue];
    self.fillColor = _CPTutorialBalloonDefaults[CPTutorialSettingFillColor];
    self.manualTipPosition = [_CPTutorialBalloonDefaults[CPTutorialSettingManualTipPosition] boolValue];
    self.tipAboveBalloon = [_CPTutorialBalloonDefaults[CPTutorialSettingTipAboveBalloon] boolValue];
    self.tipSize = [_CPTutorialBalloonDefaults[CPTutorialSettingTipSize] CGSizeValue];
    self.contentPadding = [_CPTutorialBalloonDefaults[CPTutorialSettingContentPadding] floatValue];
}

-(void)addAndCenterItemUsingAutolayout:(UIView*)item{
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTopMargin multiplier:1 constant:10];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottomMargin multiplier:1 constant:-10];
    if(item == textLabel){
        textLabelBottomConstraint = bottomConstraint;
        textLabelTopConstraint = topConstraint;
    }
    [self addSubview:item];
    [self addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
}

-(NSLayoutConstraint*)heightConstraint{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeHeight && constraint.secondItem == nil){
            return constraint;
        }
    }
    UIView *me = self;
    NSLayoutConstraint *heightConstraint = [[NSLayoutConstraint constraintsWithVisualFormat:@"V:[me(100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(me)] firstObject];
    [self addConstraint:heightConstraint];
    [self setNeedsLayout];
    return heightConstraint;
}

-(void)setText:(NSString *)text{
    if(!textLabel){
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addAndCenterItemUsingAutolayout:textLabel];
    }
    
    textLabel.text = text;
    //calculate new size
    float targetWidth = self.frame.size.width;
    if(!targetWidth){
        targetWidth = SCREEN_WIDTH - 60;
    }
    [self heightConstraint].constant = [textLabel sizeThatFits:CGSizeMake(targetWidth, MAXFLOAT)].height + 60;
}

-(NSString *)text{
    return textLabel.text;
}

-(void)setTargetView:(UIView *)targetView{
    _targetView = targetView;
    if(targetView){
        //check if at upper or lower half, checking the center-Y looks nice for this job
        //calculate the center-Y of the target view
        float centerY = targetView.frame.origin.y + targetView.frame.size.height / 2;
        BOOL aboveScreen = (centerY < SCREEN_HEIGHT / 2);
        drawMode = (aboveScreen ? TutorialDrawModeBelowTargetView : TutorialDrawModeAboveTargetView);
    }else{
        drawMode = TutorialDrawModeNoTargetView;
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if(self.dismissOnTouch){
        [self dismiss];
    }
}

-(void)dismiss{
    if(self.tipName){
        [CPTutorial markTipCompletedWithTipName:self.tipName];
    }
    if([self.animationType isEqualToString:@"fade"]){
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else if([self.animationType isEqualToString:@"none"]){
        [self removeFromSuperview];
    }else{
        //default: collapse
        CGAffineTransform targetTransform = CGAffineTransformMakeTranslation(0, self.frame.size.height / 2);
        targetTransform = CGAffineTransformScale(targetTransform, 0.1, 0.001);
        [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = targetTransform;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

-(void)prepareForInterfaceBuilder{
    self.displayDelay = 0;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    if(!self.borderColor){
        self.borderColor = [UIColor grayColor];
    }
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = NO;
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    if(self.tipName && ![CPTutorial shouldDisplayTipWithName:self.tipName]){
        [self removeFromSuperview];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIColor *fillColor;
    TutorialDrawMode targetDrawMode = drawMode;
    if(!self.fillColor){
        fillColor = [UIColor clearColor];
    }else{
        fillColor = self.fillColor;
    }
    CGSize tip;
    if(CGSizeEqualToSize(self.tipSize, CGSizeZero)){
        tip = CGSizeMake(18, 14);
    }else{
        tip = self.tipSize;
    }
    if(self.manualTipPosition){
        if(self.tipAboveBalloon){
            targetDrawMode = TutorialDrawModeBelowTargetView;
        }else{
            targetDrawMode = TutorialDrawModeAboveTargetView;
        }
    }
    switch (targetDrawMode) {
        case TutorialDrawModeAboveTargetView:
            textLabelTopConstraint.constant = self.contentPadding;
            textLabelBottomConstraint.constant = -(self.contentPadding + tip.height);
            break;
        case TutorialDrawModeBelowTargetView:
            textLabelTopConstraint.constant = self.contentPadding + tip.height;
            textLabelBottomConstraint.constant = -(self.contentPadding);
            break;
        case TutorialDrawModeNoTargetView:
            textLabelTopConstraint.constant = self.contentPadding;
            textLabelBottomConstraint.constant = -(self.contentPadding);
            break;
        default:
            break;
    }
    //calculate the center of the target view, if any
    CGPoint targetCenter;
    if(self.manualTipPosition){
        targetCenter = CGPointMake(rect.origin.x + rect.size.width / 2, 0);
    }
    if(self.targetView){
        targetCenter = CGPointMake(self.targetView.frame.origin.x
                                   + self.targetView.frame.size.width / 2,
                                   self.targetView.frame.origin.y
                                   + self.targetView.frame.size.height / 2
                                   );
    }
    if(targetDrawMode == TutorialDrawModeAboveTargetView){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - tip.height);
    }else if(targetDrawMode == TutorialDrawModeBelowTargetView){
        rect = CGRectMake(rect.origin.x, rect.origin.y + tip.height, rect.size.width, rect.size.height - tip.height);
    }
    //modify the rect taking tip into account (we can't draw outside the rect)
    // Drawing code. set context options
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextSetLineWidth(ctx, self.borderWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint next, control;
    //start drawing from top left, after the radius
    next = CGPointMake(rect.origin.x, rect.origin.y + self.cornerRadius);
    CGPathMoveToPoint(path, nil, next.x, next.y);
    //line to bottom left, above corner radius
    next = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - self.cornerRadius);
    ADD_NEXT_LINE;
    //arc to bottom left, drawing the corner radius
    next = CGPointMake(rect.origin.x + self.cornerRadius, rect.origin.y + rect.size.height);
    control = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    ADD_NEXT_ARC;
    if(targetDrawMode == TutorialDrawModeAboveTargetView){
        //we should add balloon tip
        //find the X location of the parent view on the screen
        float targetXLocation = targetCenter.x;
        //check if within correct bounds, if not, clamp it
        if(targetXLocation < rect.origin.x + self.cornerRadius + tip.width / 2){
            targetXLocation = rect.origin.x + self.cornerRadius + tip.width / 2;
        }
        if(targetXLocation > rect.origin.x + rect.size.width - self.cornerRadius - tip.width / 2){
            targetXLocation = rect.origin.x + rect.size.width - self.cornerRadius - tip.width / 2;
        }
        //draw from bottom-left to starting point of the tip on the bottom line
        next = CGPointMake(targetXLocation - tip.width / 2, rect.origin.y + rect.size.height);
        ADD_NEXT_LINE;
        //draw line to the tip of the tip :)
        next = CGPointMake(targetXLocation, rect.origin.y + rect.size.height + tip.height);
        ADD_NEXT_LINE;
        //draw from the tip of the tip back to a point on the bottom line
        next = CGPointMake(targetXLocation + tip.width / 2, rect.origin.y + rect.size.height);
        ADD_NEXT_LINE;
    }
    //line to bottom right, before corner radius
    next = CGPointMake(rect.origin.x + rect.size.width - self.cornerRadius, rect.origin.y + rect.size.height);
    ADD_NEXT_LINE;
    //arc to bottom right, after corner radius
    next = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - self.cornerRadius);
    control = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    ADD_NEXT_ARC;
    //line to top right, before corner radius
    next = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + self.cornerRadius);
    ADD_NEXT_LINE;
    //arc to top right, after corner radius
    next = CGPointMake(rect.origin.x + rect.size.width - self.cornerRadius, rect.origin.y);
    control = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    ADD_NEXT_ARC;
    if(targetDrawMode == TutorialDrawModeBelowTargetView){
        //we should add balloon tip
        //find the X location of the parent view on the screen
        float targetXLocation = targetCenter.x;
        //check if within correct bounds, if not, clamp it
        if(targetXLocation < rect.origin.x + self.cornerRadius + tip.width / 2){
            targetXLocation = rect.origin.x + self.cornerRadius + tip.width / 2;
        }
        if(targetXLocation > rect.origin.x + rect.size.width - self.cornerRadius - tip.width / 2){
            targetXLocation = rect.origin.x + rect.size.width - self.cornerRadius - tip.width / 2;
        }
        //draw from top-right to starting point of the tip on the top line
        next = CGPointMake(targetXLocation + tip.width / 2, rect.origin.y);
        ADD_NEXT_LINE;
        //draw line to the tip of the tip..
        next = CGPointMake(targetXLocation, rect.origin.y - tip.height);
        ADD_NEXT_LINE;
        //draw from the tip of the tip back to a point on the top line
        next = CGPointMake(targetXLocation - tip.width / 2, rect.origin.y);
        ADD_NEXT_LINE;
    }
    //line to top left, before the radius
    next = CGPointMake(rect.origin.x + self.cornerRadius, rect.origin.y);
    ADD_NEXT_LINE;
    //arc to our beginning point
    next = CGPointMake(rect.origin.x, rect.origin.y + self.cornerRadius); //initial point
    control = rect.origin;
    ADD_NEXT_ARC;
    //close the path
    CGPathCloseSubpath(path);
    //add and fill the path
    
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    //re-add and stroke the path
    CGContextAddPath(ctx, path);
    //CGContextClip(ctx);
    CGContextStrokePath(ctx);
}


@end
