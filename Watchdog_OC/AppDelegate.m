//
//  AppDelegate.m
//  iOS_freeze_detecting
//
//  Created by Jacky on 2019/2/12.
//  Copyright © 2019 Xiangyang. All rights reserved.
//

#import "AppDelegate.h"
#import "Watchdog.h"

@interface PingConfig : NSObject
{
@public
    CFRunLoopActivity activity;
    dispatch_semaphore_t semaphore;
}
@end

@implementation PingConfig

@end

@interface AppDelegate ()

@end

@implementation AppDelegate {
    Watchdog *watchdog;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    watchdog = [[Watchdog alloc] initWithThreshold:0.5];
    return YES;
}

- (void)registerObserver {
    PingConfig *config = [PingConfig new];
    // 创建信号
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    config->semaphore = semaphore;
    
    CFRunLoopObserverContext context = {0,(__bridge void*)config,NULL,NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    __block uint8_t timeoutCount = 0;
    
    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            // 假定连续5次超时50ms认为卡顿(当然也包含了单次超时250ms)
            long st = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC));
            if (st != 0) {
                //                NSLog(@"循环中--%ld",config->activity);
                if (config->activity==kCFRunLoopBeforeSources || config->activity==kCFRunLoopAfterWaiting) {
                    if (++timeoutCount < 5){
                        continue;
                    } else {
                        NSLog(@"卡顿了");
                    }
                }
            }
            timeoutCount = 0;
        }
    });
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    PingConfig *object = (__bridge PingConfig*)info;
    
    // 记录状态值
    object->activity = activity;
    
    // 发送信号
    dispatch_semaphore_t semaphore = object->semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
