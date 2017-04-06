//
//  NLDImageUploader.m
//  Pods
//
//  Created by 高振伟 on 16/6/14.
//
//

#import "NLDImageUploader.h"
#import "NLDMacroDef.h"
#import "NSString+NLDAddition.h"

@implementation NLDImageUploader

+ (instancetype)sharedUploader
{
    static NLDImageUploader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableUpload = NO;
    }
    return self;
}

- (void)uploadImage:(nonnull UIImage *)image fileName:(nonnull NSString *)fileName type:(NLDScreenshotType)type
{
    fileName = [fileName NLD_removeSwiftModule];
    NSString *urlString = [NSString stringWithFormat:@"%@img/upload", _domain];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSData *bodyData = [self requestBodyWithImage:image boundary:BoundaryConstant fileName:fileName];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *dataTask = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            LDECLog(@"image: %@ upload failed: %@", fileName,error);
            if ([_delegate respondsToSelector:@selector(presentAlertWithTitle:message:)]) {
                if (type == NLDAutoScreenshot) {
                    [_delegate presentAlertWithTitle:@"自动截屏上传失败" message:@""];
                }
                else if (type == NLDManualScreenshot) {
                    [_delegate presentAlertWithTitle:@"手动截屏上传失败" message:@""];
                }
            }
        } else {
            LDECLog(@"image: %@ upload successed: %@", fileName,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if ([_delegate respondsToSelector:@selector(presentAlertWithTitle:message:)]) {
                if (type == NLDAutoScreenshot) {
                    [_delegate presentAlertWithTitle:@"自动截屏已上传" message:fileName];
                }
                else if (type == NLDManualScreenshot) {
                    [_delegate presentAlertWithTitle:@"手动截屏成功" message:fileName];
                }            }
        }
    }];
    [dataTask resume];
}

#pragma mark - private method

- (NSData *)requestBodyWithImage:(UIImage *)image boundary:(NSString *)boundaryString fileName:(NSString *)fileName
{
    NSMutableString *bodyString = [NSMutableString string];
    [bodyString appendFormat:@"--%@\r\n", boundaryString];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"app\"\r\n\r\n"];
    [bodyString appendFormat:@"%@\r\n", self.appKey];
    
    [bodyString appendFormat:@"--%@\r\n", boundaryString];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"os\"\r\n\r\n"];
    [bodyString appendFormat:@"ios\r\n"];
    
    [bodyString appendFormat:@"--%@\r\n", boundaryString];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"version\"\r\n\r\n"];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [bodyString appendFormat:@"%@\r\n", appVersion];
    
    [bodyString appendFormat:@"--%@\r\n", boundaryString];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.png\"\r\n", fileName];
    [bodyString appendFormat:@"Content-Type: image/png\r\n\r\n"];

    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *imageData = UIImagePNGRepresentation(image);
    [bodyData appendData:imageData];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bodyData;
}

@end
