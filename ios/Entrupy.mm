#import "Entrupy.h"
#import <React/RCTUtils.h>
#import <EntrupySDK/EntrupySDK.h>

@interface Entrupy () <EntrupyLoginDelegate, EntrupyCaptureDelegate>
@property (nonatomic, copy) void (^loginResolve)(id result);
@property (nonatomic, copy) void (^loginReject)(NSString *code, NSString *message, NSError *error);
@property (nonatomic, copy) void (^captureResolve)(id result);
@property (nonatomic, copy) void (^captureReject)(NSString *code, NSString *message, NSError *error);
@end

@implementation Entrupy

RCT_EXPORT_MODULE()

- (void)generateAuthorizationRequest:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    @try {
        NSString *requestStr = [[EntrupyApp sharedInstance] generateSDKAuthorizationRequest];
        if (requestStr && requestStr.length > 0) {
            resolve(requestStr);
        } else {
            reject(@"GENERATE_FAILED", @"Failed to generate SDK authorization request string", nil);
        }
    } @catch (NSException *exception) {
        reject(@"GENERATE_ERROR", exception.reason, nil);
    }
}

- (void)loginUser:(NSString *)signedRequest resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    self.loginResolve = resolve;
    self.loginReject = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [EntrupyApp sharedInstance].loginDelegate = self;
        [[EntrupyApp sharedInstance] loginUserWithSignedRequest:signedRequest];
    });
}

- (void)startCapture:(NSString *)productCategory brand:(NSString *)brand itemType:(NSString *)itemType itemId:(NSString *)itemId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    if (![[EntrupyApp sharedInstance] isAuthorizationValid]) {
        reject(@"UNAUTHORIZED", @"User is not authorized. Please log in first.", nil);
        return;
    }
    
    self.captureResolve = resolve;
    self.captureReject = reject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = RCTPresentedViewController();
        if (!rootVC) {
            reject(@"NO_VIEW_CONTROLLER", @"Unable to find the root view controller", nil);
            return;
        }
        
        NSMutableDictionary *itemMetadata = [NSMutableDictionary dictionary];
        itemMetadata[@"brand"] = [[brand lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (productCategory.length > 0) {
            itemMetadata[@"product_category"] = [[productCategory lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if (itemType.length > 0) {
            itemMetadata[@"item_type"] = [[itemType lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if (itemId.length > 0) {
            itemMetadata[@"customer_item_id"] = itemId;
        }
        
        [EntrupyApp sharedInstance].captureDelegate = self;
        [[EntrupyApp sharedInstance] startCaptureForItem:itemMetadata viewController:rootVC];
    });
}

// EntrupyLoginDelegate
- (void)didLoginUserSuccessfully:(NSTimeInterval)expirationTime {
    if (self.loginResolve) {
        self.loginResolve(@(YES));
    }
    [self cleanupLoginPromise];
}

- (void)didLoginUserFailWithError:(EntrupyErrorCode)errorCode description:(NSString *)description localizedDescription:(NSString *)localizedDescription {
    if (self.loginReject) {
        self.loginReject([NSString stringWithFormat:@"%ld", (long)errorCode], localizedDescription, nil);
    }
    [self cleanupLoginPromise];
}

- (void)cleanupLoginPromise {
    self.loginResolve = nil;
    self.loginReject = nil;
}

// EntrupyCaptureDelegate
- (void)didCaptureCompleteSuccessfully:(NSDictionary *)result forItem:(NSDictionary *)item {
    if (self.captureResolve) {
        self.captureResolve(@(YES));
    }
    [self cleanupCapturePromise];
}

- (void)didUserCancelCaptureForItem:(NSDictionary *)item {
    if (self.captureReject) {
        self.captureReject(@"USER_CANCELLED", @"User cancelled the capture flow", nil);
    }
    [self cleanupCapturePromise];
}

- (void)didCaptureTimeoutForItem:(NSDictionary *)item {
    if (self.captureReject) {
        self.captureReject(@"TIMEOUT", @"Capture timed out", nil);
    }
    [self cleanupCapturePromise];
}

- (void)didCaptureFailWithError:(EntrupyErrorCode)errorCode description:(NSString *)description localizedDescription:(NSString *)localizedDescription forItem:(NSDictionary *)item {
    if (self.captureReject) {
        self.captureReject([NSString stringWithFormat:@"%ld", (long)errorCode], localizedDescription, nil);
    }
    [self cleanupCapturePromise];
}

- (void)cleanupCapturePromise {
    self.captureResolve = nil;
    self.captureReject = nil;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeEntrupySpecJSI>(params);
}

@end
