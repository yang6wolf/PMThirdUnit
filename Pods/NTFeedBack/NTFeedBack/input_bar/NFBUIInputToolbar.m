/*
 *  UIInputToolbar.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "NFBUIInputToolbar.h"
#import "NFBAppearanceProxy.h"
#import "NFBUtil.h"

@implementation InputField



-(CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x, bounds.origin.y+3, bounds.size.width, bounds.size.height);//更好理解些
    if ([UIDevice currentDevice].systemVersion.integerValue >= 7) {
        inset = CGRectMake(bounds.origin.x, bounds.origin.y+8, bounds.size.width, bounds.size.height);
    }
    return inset;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    //[[UIFactory grayTextColor] setFill];
    //[[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:12.0f]];
}

@end

@interface NFBUIInputToolbar()
@property (nonatomic,assign) BOOL textInputStatus;
@end

@implementation NFBUIInputToolbar

@synthesize textInput;
@synthesize inputButton;

#define TEXT_SIZE 14.0
#define PLACEHOLDER_TEXT @"请输入您的意见"
#define MAX_INPUTTEXT_COUNT 1000

-(void)inputButtonPressed {
    if (!self.textInputStatus) {
        [NFBUtil alertView:@"不能发送空内容"];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(inputButtonPressed:)]) {
        [self.delegate inputButtonPressed:self.textInput.text];
    }
    
    /* Remove the keyboard and clear the text */
    [self.textInput resignFirstResponder];
    [self resetTextView];
}

-(void)imageButtonPressed {
    [self.textInput resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(imageButtonPressed)]) {
        [self.delegate imageButtonPressed];
    }
}

-(void)setupToolbar {
    self.userInteractionEnabled = YES;
    self.image =  [[NFBAppearanceProxy sharedAppearance] toolBarBackgroundImage];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setBackgroundImage:[[NFBAppearanceProxy sharedAppearance] toolBarConfirmButtonImage] forState:UIControlStateNormal];
    button.frame = CGRectMake(SCREEN_WIDTH - 65, 7, 60, 30);
    [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
    inputButton = button;
    [self addSubview:button];
    
    _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 7, 65, 30)];
    [_imageButton setTitle:@"图片" forState:UIControlStateNormal];
    [_imageButton setImage:[[NFBAppearanceProxy sharedAppearance] toolBarPlusButtonImage] forState:UIControlStateNormal];
    [_imageButton addTarget:self action:@selector(imageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_imageButton];
    
    
    UIImageView *inputBackgroundImgV = [[UIImageView alloc] initWithFrame:CGRectMake(70, 5, SCREEN_WIDTH - 140, 34)];
    inputBackgroundImgV.image = [[NFBAppearanceProxy sharedAppearance] inputFieldImage];
    inputBackgroundImgV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:inputBackgroundImgV];
    
    
    self.textInput = [[InputField alloc] initWithFrame:CGRectMake(75, 7, SCREEN_WIDTH - 150, 30)];
    self.textInput.backgroundColor = [UIColor clearColor];
    //self.textInput.borderStyle = UITextBorderStyleNone;
    self.textInput.textColor = [UIColor lightGrayColor];
    //self.textInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textInput.font = [UIFont systemFontOfSize:TEXT_SIZE];
    self.textInput.text = PLACEHOLDER_TEXT;
    self.textInput.returnKeyType = UIReturnKeySend;
    //self.textInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textInput.delegate = self;
    self.textInputStatus = NO;
    [self addSubview:self.textInput];
}

- (void)setTextViewPlaceholder:(NSString *)placeholder {
    self.textInput.text = placeholder;
    self.textInput.textColor = [UIColor lightGrayColor];
    self.textInputStatus = NO;
}

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar];
    }
    return self;
}

- (BOOL)resignFirstResponder {
    return [self.textInput resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [self.textInput becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return [self.textInput canBecomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [self.textInput canResignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACEHOLDER_TEXT]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
        self.textInputStatus = YES;
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [self resetTextView];
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *inputText = textView.text;
    CGSize maxContentSize = CGSizeMake(self.textInput.bounds.size.width - 10  , INFINITY);
    CGSize contentSize = [inputText sizeWithFont:[UIFont systemFontOfSize:TEXT_SIZE] constrainedToSize:maxContentSize lineBreakMode:NSLineBreakByWordWrapping];

    [self changeInputHeight:contentSize.height];


}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [self inputButtonPressed];
        
        return NO;
        
    }
    if (textView.text.length> MAX_INPUTTEXT_COUNT) {
        [NFBUtil alertView:@"你发的字数太多了,客服MM看不过来啦.."];
        return NO;
    }
    
    return YES;    
    
}

-(void)changeInputHeight:(CGFloat)height{
    if (height < 18) { //当只有一行时高度为toolbar初始高度
        height = 18;
    }
    if (height > 120) { //再大就要超出3.5屏幕了
        return;
    }
    CGRect inputBounds = self.textInput.frame;
    inputBounds.size.height = height + 12;
    self.textInput.frame = inputBounds;
    
    CGRect oldframe = self.frame;
    oldframe.size.height = height + 26;
    self.frame = oldframe;
    
    if ([_delegate respondsToSelector:@selector(inputToolbarHeightChanged:)]) {
        [_delegate inputToolbarHeightChanged:CGRectGetHeight(self.bounds) ];
    }
}

-(void)resetTextView
{
    self.textInput.text = PLACEHOLDER_TEXT;
    self.textInput.textColor = [UIColor lightGrayColor];
    self.textInputStatus = NO;
    [self changeInputHeight:18];
}


@end
