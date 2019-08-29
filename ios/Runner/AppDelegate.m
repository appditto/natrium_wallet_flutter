#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (void)lc_setAlternateIconName:(NSString*)iconName
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(supportsAlternateIcons)] &&
        [[UIApplication sharedApplication] supportsAlternateIcons])
    {
        NSMutableString *selectorString = [[NSMutableString alloc] initWithCapacity:40];
        [selectorString appendString:@"_setAlternate"];
        [selectorString appendString:@"IconName:"];
        [selectorString appendString:@"completionHandler:"];
        
        SEL selector = NSSelectorFromString(selectorString);
        IMP imp = [[UIApplication sharedApplication] methodForSelector:selector];
        void (*func)(id, SEL, id, id) = (void *)imp;
        if (func)
        {
            func([UIApplication sharedApplication], selector, iconName, ^(NSError * _Nullable error) {});
        }
    }
}

-(void)clearClipboard {
    [UIPasteboard generalPasteboard].string = @"";
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* appChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"fappchannel"
                                        binaryMessenger:controller];
    
    [appChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"changeIcon" isEqualToString:call.method]) {
            NSDictionary *arguments = [call arguments];
            NSString *icon = arguments[@"icon"];
            if (icon == NULL || icon.length == 0) {
                result([FlutterError errorWithCode:@"error"
                                           message:@"Icon is required"
                                           details:nil]);
                return;
            }
            if ([@"natrium" isEqualToString:icon ]) {
                [self lc_setAlternateIconName:nil];
            } else if ([@"titanium" isEqualToString:icon]) {
                [self lc_setAlternateIconName:@"titanium"];
            } else if ([@"indium" isEqualToString:icon]) {
                [self lc_setAlternateIconName:@"indium"];
            } else if ([@"neptunium" isEqualToString:icon]) {
                [self lc_setAlternateIconName:@"neptunium"];
            } else if ([@"thorium" isEqualToString:icon]) {
                [self lc_setAlternateIconName:@"thorium"];
            }
        } else if ([@"clearClipboardAlarm" isEqualToString:call.method]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearClipboard) object:nil];
            [self performSelector:@selector(clearClipboard) withObject:nil afterDelay:120.0];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
