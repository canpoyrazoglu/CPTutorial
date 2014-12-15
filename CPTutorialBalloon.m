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
NSString *const CPTutorialSettingTextColor = @"textColor";
NSString *const CPTutorialSettingDisplaysTip = @"displaysTip";
NSString *const CPTutorialSettingFontSize = @"fontSize";
NSString *const CPTutorialSettingFontName = @"fontName";
NSString *const CPTutorialSettingHorizontalMargin = @"horizontalMargin";

//animation types
NSString *const CPTutorialAnimationTypeNone = @"none";
NSString *const CPTutorialAnimationTypeFade = @"fade";
NSString *const CPTutorialAnimationTypeCollapse = @"collapse";


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
    BOOL dismissedWithoutBeingDisplayed;
    BOOL isHostedInInterfaceBuilder;
    float targetAlpha;
    CGRect lastRect;
    UIColor *fillColor;
    
    //drawing state related
    TutorialDrawMode targetDrawMode;
    CGSize tip;
    CGPoint targetCenter;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    fillColor = backgroundColor;
}

-(UIView *)tutorialView{
    return self;
}

-(CGSize)tipSizeForDisplay{
    if(CGSizeEqualToSize(self.tipSize, CGSizeZero)){
        return CGSizeMake(18, 14);
    }else{
        return self.tipSize;
    }
}

-(void)setBalloonState:(TutorialBalloonState)balloonState{
    _balloonState = balloonState;
    if(isHostedInInterfaceBuilder){
        _balloonState = TutorialBalloonStateDesignMode;
    }
}

-(CGRect)frameForAttachingToFrame:(CGRect)targetFrame{
    //find below or not.
    //NSLog(@"targetFrame %@", NSStringFromCGRect(targetFrame));
    BOOL isOtherViewAtTheBottomHalfOfScreen = targetFrame.origin.y + (targetFrame.size.height / 2) >= (CPTUTORIAL_SCREEN_HEIGHT / 2);
    CGRect rect = CGRectMake(self.horizontalMargin, isOtherViewAtTheBottomHalfOfScreen ? targetFrame.origin.y - 10 : targetFrame.origin.y + targetFrame.size.height + 10, CPTUTORIAL_SCREEN_WIDTH - (self.horizontalMargin * 2), 60);
    float requiredHeight = [textLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)].height + self.contentPadding * 2 + [self tipSizeForDisplay].height;
    if(isOtherViewAtTheBottomHalfOfScreen){
        rect.origin.y -= requiredHeight;
    }
    rect.size.height = requiredHeight;
    return rect;
}


-(void)setCornerRadius:(float)cornerRadius{
    _cornerRadius = cornerRadius;
    if(_cornerRadius){
        self.opaque = NO;
    }
}

-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    [self setNeedsDisplay];
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
       CPTutorialSettingFillColor: [UIColor colorWithWhite:1 alpha:0.95],
       CPTutorialSettingManualTipPosition: @(NO),
       CPTutorialSettingTipAboveBalloon: @(NO),
       CPTutorialSettingTipSize: [NSValue valueWithCGSize:CGSizeMake(18, 14)],
       CPTutorialSettingContentPadding: @(10.0f),
       CPTutorialSettingTextColor: [UIColor blackColor],
       CPTutorialSettingDisplaysTip: @(YES),
       CPTutorialSettingFontName: @"HelveticaNeue",
       CPTutorialSettingFontSize: @(14),
       CPTutorialSettingHorizontalMargin: @(20)
       } mutableCopy];
}

-(void)makeStyleDefaultForAllBalloons{
    _CPTutorialBalloonDefaults[CPTutorialSettingBorderColor] = self.borderColor;
    _CPTutorialBalloonDefaults[CPTutorialSettingAnimationType] = self.animationType;
    _CPTutorialBalloonDefaults[CPTutorialSettingBorderWidth] = @(self.borderWidth);
    _CPTutorialBalloonDefaults[CPTutorialSettingCornerRadius] = @(self.cornerRadius);
    _CPTutorialBalloonDefaults[CPTutorialSettingDismissOnTouch] = @(self.dismissOnTouch);
    _CPTutorialBalloonDefaults[CPTutorialSettingDisplayDelay] = @(self.displayDelay);
    _CPTutorialBalloonDefaults[CPTutorialSettingDisplaysTip] = @(self.displaysTip);
    _CPTutorialBalloonDefaults[CPTutorialSettingFillColor] = fillColor;
    _CPTutorialBalloonDefaults[CPTutorialSettingFontName] = self.fontName;
    _CPTutorialBalloonDefaults[CPTutorialSettingFontSize] = @(self.fontSize);
    _CPTutorialBalloonDefaults[CPTutorialSettingManualTipPosition] = @(self.manualTipPosition);
    _CPTutorialBalloonDefaults[CPTutorialSettingTextColor] = self.textColor;
    _CPTutorialBalloonDefaults[CPTutorialSettingTipAboveBalloon] = @(self.tipAboveBalloon);
    _CPTutorialBalloonDefaults[CPTutorialSettingTipSize] = [NSValue valueWithCGSize:self.tipSize];
    _CPTutorialBalloonDefaults[CPTutorialSettingContentPadding] = @(self.contentPadding);
    _CPTutorialBalloonDefaults[CPTutorialSettingHorizontalMargin] = @(self.horizontalMargin);
}

-(instancetype)init{
    self = [super init];
    [self initializeDefaultValues];
    return self;
}

-(UIFont*)resolvedFontWithName:(NSString*)fontName size:(float)fontSize{
    //e.g. "Helvetica Neue UltraLight" should resolve to "HelveticaNeue-UltraLight" (case insensitive)
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if(!font){
        //go advanced
        static NSArray *fontModifiers;
        if(!fontModifiers){
            fontModifiers = @[ @"light", @"thin", @"ultralight", @"bold", @"condensed", @"wide", @"extrablack", @"italic", @"regular", @"oblique", @"medium", @"black", @"semibold", @"demibold" ];
        }
        NSString *lowerFontName = [fontName lowercaseString];
        NSUInteger locationOfFirstModifier = NSNotFound;
        for (NSString *token in fontModifiers) {
            NSUInteger currentLocation = [lowerFontName rangeOfString:token].location;
            if(currentLocation != NSNotFound && currentLocation < locationOfFirstModifier){
                locationOfFirstModifier = currentLocation;
            }
        }
        if(locationOfFirstModifier != NSNotFound){
            NSString *stringBefore = [[fontName substringToIndex:locationOfFirstModifier] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *stringAfter = [[fontName substringFromIndex:locationOfFirstModifier] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            stringBefore = [stringBefore stringByReplacingOccurrencesOfString:@" " withString:@""];
            stringAfter = [stringAfter stringByReplacingOccurrencesOfString:@" " withString:@""];
            //now join them, apparently capitalization doesn't matter so HelveticaNeue == heLveticaneuE
            //but we need the dash in between
            NSString *resultFontName = [NSString stringWithFormat:@"%@-%@", stringBefore, stringAfter];
            //now search for that font
            font = [UIFont fontWithName:resultFontName size:fontSize];
        }
        
    }
    return font;
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

-(void)attachedViewFrameDidChange:(CGRect)newFrame{
    self.frame = [self frameForAttachingToFrame:newFrame];
}

-(void)setContentMode:(UIViewContentMode)contentMode{
    [super setContentMode:UIViewContentModeRedraw];
}

-(void)initializeDefaultValues{
    if(self.balloonState == TutorialBalloonStateDesignMode){
        self.balloonState = TutorialBalloonStateWaitingForSignal;
    }
    self.contentMode = UIViewContentModeRedraw;
    self.borderColor = _CPTutorialBalloonDefaults[CPTutorialSettingBorderColor];
    self.animationType = _CPTutorialBalloonDefaults[CPTutorialSettingAnimationType];
    self.borderWidth = [_CPTutorialBalloonDefaults[CPTutorialSettingBorderWidth] floatValue];
    self.cornerRadius = [_CPTutorialBalloonDefaults[CPTutorialSettingCornerRadius] floatValue];
    self.dismissOnTouch = [_CPTutorialBalloonDefaults[CPTutorialSettingDismissOnTouch] boolValue];
    self.displayDelay = [_CPTutorialBalloonDefaults[CPTutorialSettingDisplayDelay] floatValue];
    if(!self.backgroundColor){
        self.backgroundColor = _CPTutorialBalloonDefaults[CPTutorialSettingFillColor];
    }
    self.manualTipPosition = [_CPTutorialBalloonDefaults[CPTutorialSettingManualTipPosition] boolValue];
    self.tipAboveBalloon = [_CPTutorialBalloonDefaults[CPTutorialSettingTipAboveBalloon] boolValue];
    self.tipSize = [_CPTutorialBalloonDefaults[CPTutorialSettingTipSize] CGSizeValue];
    self.contentPadding = [_CPTutorialBalloonDefaults[CPTutorialSettingContentPadding] floatValue];
    self.textColor = _CPTutorialBalloonDefaults[CPTutorialSettingTextColor];
    self.displaysTip = [_CPTutorialBalloonDefaults[CPTutorialSettingDisplaysTip] boolValue];
    self.fontName = _CPTutorialBalloonDefaults[CPTutorialSettingFontName];
    self.fontSize = [_CPTutorialBalloonDefaults[CPTutorialSettingFontSize] floatValue];
    self.horizontalMargin = [_CPTutorialBalloonDefaults[CPTutorialSettingHorizontalMargin] floatValue];
}

-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    textLabel.textColor = textColor;
}

-(void)setText:(NSString *)text{
    if(!textLabel){
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        textLabel.numberOfLines = 0;
        textLabel.textColor = self.textColor;
        textLabel.preferredMaxLayoutWidth = 280;
        textLabel.font = [self resolvedFontWithName:self.fontName size:self.fontSize];
        [self addSubview:textLabel];
    }
    textLabel.text = text;
}

-(NSString *)text{
    return textLabel.text;
}

-(UILabel *)textLabel{
    return textLabel;
}

-(void)setTargetView:(UIView *)targetView{
    _targetView = targetView;
    if(targetView){
        //check if at upper or lower half, checking the center-Y looks nice for this job
        //calculate the center-Y of the target view
        float centerY = targetView.frame.origin.y + targetView.frame.size.height / 2;
        BOOL aboveScreen = (centerY < targetView.superview.frame.size.height / 2);
        drawMode = (aboveScreen ? TutorialDrawModeBelowTargetView : TutorialDrawModeAboveTargetView);
    }else{
        drawMode = TutorialDrawModeNoTargetView;
    }
}

-(void)setFontName:(NSString *)fontName{
    _fontName = fontName;
    textLabel.font = [self resolvedFontWithName:fontName size:self.fontSize];
}

-(void)setFontSize:(float)fontSize{
    _fontSize = fontSize;
    textLabel.font = [self resolvedFontWithName:self.fontName size:fontSize];
}

-(void)setHorizontalMargin:(float)horizontalMargin{
    _horizontalMargin = horizontalMargin;
    [self recalculateViews];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if(self.dismissOnTouch){
        [self dismiss];
    }
}

-(void)removeFromSuperview{
    [super removeFromSuperview];
    if(self.dismissHandler){
        if(!dismissedWithoutBeingDisplayed || self.shouldFireDismissHandlerEvenIfDisplayIsSkipped){
            self.dismissHandler();
        }
    }
    if(!self.shouldHoldAfterBeingDismissed){
        [self.tutorial step];
        [self.tutorial resume];
    }
}

-(CPTutorialBalloon*)delay:(float)delayInSeconds{
    self.displayDelay = delayInSeconds;
    return self;
}

-(void)setDisplayDelay:(float)displayDelay{
    _displayDelay = displayDelay;
    if(displayDelay && self.balloonState == TutorialBalloonStateWaitingForDelay){
        [self hold];
        [self signal]; //[re]start timer
    }
}

-(instancetype)dismiss{
    dismissedWithoutBeingDisplayed = YES;
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
        CGAffineTransform targetTransform;
        switch (targetDrawMode) {
            case TutorialDrawModeNoTargetView:
                targetTransform = CGAffineTransformIdentity;
                break;
            case TutorialDrawModeAboveTargetView:
                targetTransform = CGAffineTransformMakeTranslation(0, self.frame.size.height / 2);
                break;
            case TutorialDrawModeBelowTargetView:
                targetTransform = CGAffineTransformMakeTranslation(0, -self.frame.size.height / 2);
            default:
                break;
        }
        targetTransform = CGAffineTransformScale(targetTransform, 0.1, 0.001);
        [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = targetTransform;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    return self;
}

-(void)prepareForInterfaceBuilder{
    self.displayDelay = 0;
    isHostedInInterfaceBuilder = YES;
    self.balloonState = TutorialBalloonStateDesignMode;
}

-(void)setTutorial:(CPTutorial *)tutorial{
    _tutorial = tutorial;
    [_tutorial addBalloon:self];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    if(!self.borderColor){
        self.borderColor = [UIColor grayColor];
    }
    self.layer.masksToBounds = NO;
}

-(instancetype)signal{
    if(self.balloonState == TutorialBalloonStateDesignMode){
        [self present];
        return self;
    }else{
        self.balloonState = TutorialBalloonStateWaitingForDelay;
        [self performSelector:@selector(present) withObject:nil afterDelay:self.displayDelay];
        return self;
    }
}

-(void)present{
    if(self.balloonState != TutorialBalloonStateWaitingForDelay && self.balloonState != TutorialBalloonStateWaitingForSignal && self.balloonState != TutorialBalloonStateDesignMode){
        return;
    }
    if(self.definesStyle){
        [self makeStyleDefaultForAllBalloons];
    }
    self.balloonState = TutorialBalloonStateAnimatingIn;
    self.hidden = NO;
    self.alpha = 0;
    if([self.animationType isEqualToString:@"fade"]){
        self.alpha = 0;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            self.balloonState = TutorialBalloonStateDisplaying;
        }];
    }else if([self.animationType isEqualToString:@"none"]){
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
        self.balloonState = TutorialBalloonStateDisplaying;
    }else{
        //default: collapse
        CGAffineTransform targetTransform;
        self.alpha = 1;
        switch (targetDrawMode) {
            case TutorialDrawModeNoTargetView:
                targetTransform = CGAffineTransformIdentity;
                break;
            case TutorialDrawModeAboveTargetView:
                targetTransform = CGAffineTransformMakeTranslation(0, self.frame.size.height / 2);
                break;
            case TutorialDrawModeBelowTargetView:
                targetTransform = CGAffineTransformMakeTranslation(0, -self.frame.size.height / 2);
            default:
                break;
        }
        targetTransform = CGAffineTransformScale(targetTransform, 0.1, 0.001);
        self.transform = targetTransform;
        [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.balloonState = TutorialBalloonStateDisplaying;
        }];
    }
    [self setNeedsDisplay];
}

-(instancetype)hold{
    if(self.balloonState == TutorialBalloonStateDesignMode){
        return self;
    }
    self.alpha = 0;
    self.balloonState = TutorialBalloonStateWaitingForSignal;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    return self;
}



-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    if(self.balloonState == TutorialBalloonStateDesignMode){
        return;
    }
    if(self.isManagedExternally){
        self.balloonState = TutorialBalloonStateWaitingForSignal;
    }else{
        [self signal];
    }
    if(![CPTutorial shouldDisplayTutorialWithName:self.tipName]){
        [self removeFromSuperview];
    }
}

-(void)setTipName:(NSString *)tipName{
    _tipName = tipName;
    if(self.superview && ![CPTutorial shouldDisplayTutorialWithName:tipName]){
        [self removeFromSuperview];
    }
}

-(TutorialDrawMode)targetDrawMode{
    if(self.manualTipPosition){
        if(self.tipAboveBalloon){
            targetDrawMode = TutorialDrawModeBelowTargetView;
        }else{
            targetDrawMode = TutorialDrawModeAboveTargetView;
        }
    }
    return targetDrawMode;
}

-(void)setShouldResizeItselfAccordingToContents:(BOOL)shouldResizeItselfAccordingToContents{
    _shouldResizeItselfAccordingToContents = shouldResizeItselfAccordingToContents;
    if(shouldResizeItselfAccordingToContents){
        [self sizeToFit];
    }
}

-(CGSize)intrinsicContentSize{
    if(self.shouldResizeItselfAccordingToContents){
        float requiredHeight = [textLabel sizeThatFits:CGSizeMake(CPTUTORIAL_SCREEN_WIDTH - (self.horizontalMargin * 2) - self.contentPadding * 2, MAXFLOAT)].height;
        return CGSizeMake(CPTUTORIAL_SCREEN_WIDTH - (self.horizontalMargin * 2), requiredHeight + self.contentPadding * 2 + [self tipSizeForDisplay].height);
    }else{
        return [super intrinsicContentSize];
    }
}

-(void)recalculateViews{
    targetDrawMode = [self targetDrawMode];
    tip = [self tipSizeForDisplay];
    if(self.shouldResizeItselfAccordingToContents){
        CGRect currentFrame = self.frame;
        currentFrame.size = [self intrinsicContentSize];
        self.frame = currentFrame;
    }
    CGRect targetTextLabelFrame;
    switch (targetDrawMode) {
        case TutorialDrawModeAboveTargetView:
            //textLabelTopConstraint.constant = self.contentPadding;
            //textLabelBottomConstraint.constant = -(self.contentPadding + tip.height);
            targetTextLabelFrame = CGRectMake(self.contentPadding, self.contentPadding, self.frame.size.width - self.contentPadding * 2, self.frame.size.height - self.contentPadding * 2 - tip.height);
            break;
        case TutorialDrawModeBelowTargetView:
            //textLabelTopConstraint.constant = self.contentPadding + tip.height;
            //textLabelBottomConstraint.constant = -(self.contentPadding);
            targetTextLabelFrame = CGRectMake(self.contentPadding, self.contentPadding + tip.height, self.frame.size.width - self.contentPadding * 2, self.frame.size.height - self.contentPadding * 2 - tip.height);
            break;
        case TutorialDrawModeNoTargetView:
            //textLabelTopConstraint.constant = self.contentPadding;
            //textLabelBottomConstraint.constant = -(self.contentPadding);
            targetTextLabelFrame = CGRectMake(self.contentPadding, self.contentPadding, self.frame.size.width - self.contentPadding * 2, self.frame.size.height - self.contentPadding * 2);
            break;
        default:
            break;
    }
    textLabel.frame = targetTextLabelFrame;
    textLabel.preferredMaxLayoutWidth = targetTextLabelFrame.size.width;
    //calculate the center of the target view, if any
    if(self.manualTipPosition){
        targetCenter = CGPointMake(self.frame.origin.x + self.frame.size.width / 2, 0);
    }
    if(self.isManagedExternally && self.targetView){
        CGRect targetViewFrameInOurSuperview = [self.targetView.superview convertRect:self.targetView.frame toView:self];
        targetCenter = CGPointMake(targetViewFrameInOurSuperview.origin.x
                                   + targetViewFrameInOurSuperview.size.width / 2,
                                   targetViewFrameInOurSuperview.origin.y
                                   + targetViewFrameInOurSuperview.size.height / 2
                                   );
    }
}

- (void)drawRect:(CGRect)rect {
    lastRect = rect;
    [self recalculateViews];
    [super drawRect:rect];
    if(self.balloonState != TutorialBalloonStateDisplaying &&
       self.balloonState != TutorialBalloonStateAnimatingIn &&
       self.balloonState != TutorialBalloonStateAnimatingOut &&
       self.balloonState != TutorialBalloonStateDesignMode){
        self.alpha = 0;
        return;
    }
    
    if(!fillColor){
        fillColor = [UIColor clearColor];
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
    if(targetDrawMode == TutorialDrawModeAboveTargetView && self.displaysTip){
        //we should add balloon tip
        //find the X location of the parent view on the screen
        float targetXLocation = targetCenter.x;// - self.frame.origin.x;
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
    if(targetDrawMode == TutorialDrawModeBelowTargetView && self.displaysTip){
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
