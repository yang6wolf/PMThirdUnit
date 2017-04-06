//
//  NLDManualTool.m
//  Pods
//
//  Created by wangkaird on 2016/10/20.
//
//

#import "NLDManualTool.h"
#import "NLDImageUploader.h"
#import "UIViewController+NLDInternalMethod.h"

#pragma mark - @protocol NLDManualFloatingWindowProtocol
@protocol NLDManualFloatingWindowProtocol <NSObject>
- (BOOL)shouldHandleEvent:(UIEvent *)event atPoint:(CGPoint)point;
@end

#pragma mark - @class NLDManualFloatingWindow

@interface NLDManualFloatingWindow : UIWindow
@property (nonatomic, weak) id<NLDManualFloatingWindowProtocol> delegate;
@end

@implementation NLDManualFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 1;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL ret = NO;
    if ([self.delegate shouldHandleEvent:event atPoint:point]) {
        ret = [super pointInside:point withEvent:event];
    }
    return ret;
}
@end

#pragma mark - @class NLDManualFloatingView

@interface NLDManualFloatingView : UIView

@end

@interface NLDManualFloatingView ()
@property (nonatomic, assign) CGPoint beginPoint;
@end

@implementation NLDManualFloatingView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];

    CGFloat offsetX = currentPoint.x - self.beginPoint.x;
    CGFloat offsetY = currentPoint.y - self.beginPoint.y;
    int positionX = self.center.x + offsetX;
    int positionY = self.center.y + offsetY;

    self.center = CGPointMake(positionX, positionY);
}

@end

#pragma mark - @class NLDManualFloatingViewController

static CGFloat const kFloatingViewWidth = 100.0f;
static CGFloat const kFloatingViewHeight = 50.0f;
static CGFloat const kVerticalMargin = 2.5f;
static CGFloat const kVerticalGap = 5.0f;
static CGFloat const kInputTextFieldHeight = 30.0f;

#define kManualButtonNormalColor [UIColor colorWithRed:0.788 green:0.765 blue:0.675 alpha:1.00]
#define kManualButtonHighlightColor [UIColor whiteColor]
#define kManualFloatingViewBackgroundColor [UIColor blackColor]


@interface NLDManualFloatingViewController : UIViewController
@property (nonatomic, weak) UIWindow *baseWindow;

+ (instancetype)new NS_UNAVAILABLE;
- (void)showManualFloatingViewController;
- (void)dismissManualFloatingViewController;
@end

@interface NLDManualFloatingViewController () <NLDManualFloatingWindowProtocol>
@property (nonatomic, strong) NLDManualFloatingWindow *window;
@property (nonatomic, strong) NLDManualFloatingView *floatingView;
@property (nonatomic, strong) UITextField   *inputTextFiled;
@property (nonatomic, strong) UIView        *button;
@property (nonatomic, assign) BOOL          showing;
@end

@implementation NLDManualFloatingViewController
- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)showManualFloatingViewController {
    if (self.showing) {
        return;
    }

    self.window.rootViewController = self;
    self.window.delegate = self;
    self.showing = YES;
    self.window.hidden = NO;
}

- (void)dismissManualFloatingViewController {
    if (!self.showing) {
        return;
    }

    [self.baseWindow makeKeyWindow];
    self.window.hidden = YES;
    self.window.rootViewController = nil;
    self.window.delegate = nil;
    self.showing = NO;
}

- (void)setupViewController {
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    NLDManualFloatingWindow *window = [[NLDManualFloatingWindow alloc] initWithFrame:windowFrame];
    _window = window;

    CGFloat windowWidth = CGRectGetWidth(windowFrame);
    CGFloat windowHeight = CGRectGetHeight(windowFrame);
    CGFloat floatX = (windowWidth - kFloatingViewWidth - 20);
    CGFloat floatY = (windowHeight - kFloatingViewHeight) / 2.0;
    NLDManualFloatingView *floatingView = [[NLDManualFloatingView alloc] initWithFrame:CGRectMake(floatX, floatY, kFloatingViewWidth, kFloatingViewHeight)];
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] init];
    [backgroundTap addTarget:self action:@selector(backgroundTapped:)];
    [floatingView addGestureRecognizer:backgroundTap];
    [floatingView setBackgroundColor:kManualFloatingViewBackgroundColor];
    floatingView.alpha = 0.9f;
    _floatingView = floatingView;

    CGFloat horizonMargin = 2.5f;

    CGFloat inputX = horizonMargin;
    CGFloat inputY = kVerticalMargin;
    CGFloat inputWidth = kFloatingViewWidth - horizonMargin * 2;
    UITextField *inputTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(inputX, inputY, inputWidth, kInputTextFieldHeight)];
    inputTextFiled.font = [UIFont systemFontOfSize:10.0f];
    inputTextFiled.placeholder = @"请输入页面类名";
    inputTextFiled.backgroundColor = [UIColor whiteColor];
    inputTextFiled.textColor = [UIColor redColor];
    _inputTextFiled = inputTextFiled;
    _inputTextFiled.hidden = YES;

    CGFloat buttonWidth = 40.0f;
    CGFloat buttonX = (kFloatingViewWidth - buttonWidth) / 2.0f;
    CGFloat buttonY = kVerticalMargin + kVerticalGap;
    CGFloat buttonHeight = buttonWidth;
    UIView *button = [[UIView alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
    button.layer.cornerRadius = buttonWidth / 2.0f;
    button.layer.masksToBounds = YES;
    [button setBackgroundColor:kManualButtonNormalColor];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    longPress.minimumPressDuration = 1.0f;
    [longPress addTarget:self action:@selector(longPressed:)];
    [button addGestureRecognizer:longPress];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapped:)];
    [button addGestureRecognizer:tap];
    _button = button;

    [_floatingView addSubview:_inputTextFiled];
    [_floatingView addSubview:_button];
    [self.view addSubview:_floatingView];
}

- (void)tapped:(UIGestureRecognizer *)gesture {
    self.inputTextFiled.hidden = !self.inputTextFiled.hidden;
    if (self.inputTextFiled.hidden) {
        [self.inputTextFiled resignFirstResponder];
    }
    CGRect frame = self.floatingView.frame;
    frame.size.height = self.inputTextFiled.hidden ? kFloatingViewHeight : kFloatingViewHeight+30;
    self.floatingView.frame = frame;
    
    frame = self.button.frame;
    frame.origin.y = self.inputTextFiled.hidden ? kVerticalMargin+kVerticalGap : kVerticalMargin+kVerticalGap+kInputTextFieldHeight;
    self.button.frame = frame;
}

- (void)longPressed:(UIGestureRecognizer *)gesture {
    NSString *filename = @"";
    if (self.inputTextFiled.hidden) {
        UIViewController *currentVC = [UIViewController currentViewControllerForWindow:self.baseWindow];
        filename = NSStringFromClass([currentVC class]);
    } else {
        filename = self.inputTextFiled.text;
    }
    if (filename.length <= 0) {
        return;
    }

    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.button.backgroundColor = kManualButtonHighlightColor;
        // 截图并上传
        UIImage *screenImage = [UIViewController screenShotForWindow:self.baseWindow];
        if (!screenImage) {
            return ;
        }
        [[NLDImageUploader sharedUploader] uploadImage:screenImage fileName:filename type:NLDManualScreenshot];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.button.backgroundColor = kManualButtonNormalColor;
    }
}

- (void)backgroundTapped:(id)gesture {
    [self.inputTextFiled resignFirstResponder];
    [self.baseWindow makeKeyWindow];
}

- (BOOL)shouldHandleEvent:(UIEvent *)event atPoint:(CGPoint)point {
    BOOL shouldReceiveTouch = NO;
    CGPoint localPoint = [self.view convertPoint:point toView:nil];
    if (CGRectContainsPoint(self.floatingView.frame, localPoint)) {
        shouldReceiveTouch = YES;
    }

    if (!shouldReceiveTouch) {
        [self.inputTextFiled resignFirstResponder];
        [self.baseWindow makeKeyWindow];
    } else {
        [self.window makeKeyWindow];
    }
    return shouldReceiveTouch;
}

@end

#pragma mark - @class NLDManualTool

@interface NLDManualTool ()
@property (nonatomic, strong) NLDManualFloatingViewController *floatingViewController;
@end

@implementation NLDManualTool

+ (instancetype)sharedManualTool {
    static NLDManualTool *manualTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manualTool = [[NLDManualTool alloc] init];
    });

    return manualTool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _floatingViewController = [[NLDManualFloatingViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

- (void)showManualTool {
    [self.floatingViewController showManualFloatingViewController];
}

- (void)hiddenManualTool {
    [self.floatingViewController dismissManualFloatingViewController];
}

- (void)setBaseWindow:(UIWindow *)window {
    if (![window isKindOfClass:[UIWindow class]]) {
        return ;
    }
    self.floatingViewController.baseWindow = window;
}

@end

