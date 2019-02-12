//
//  Watchdog.m
//  iOS_freeze_detecting
//
//  Created by Jacky on 2019/2/12.
//  Copyright © 2019 Xiangyang. All rights reserved.
//

#import "Watchdog.h"
#import <objc/objc-sync.h>

@interface PingThread : NSThread

@property (assign, nonatomic) NSTimeInterval threshold;
@property (assign, nonatomic) BOOL pingTaskIsRunning;
@property (strong, nonatomic) NSObject *pingTaskIsRunningLock;
@property (copy, nonatomic) Handler handler;

@end


@implementation PingThread {
    BOOL _pingTaskIsRunning;
    dispatch_semaphore_t _semaphore;
}

@synthesize pingTaskIsRunning;

- (BOOL)pingTaskIsRunning {
    /** Equal
     @synchronized(_pingTaskIsRunningLock) {
        BOOL pingTaskIsRunning = _pingTaskIsRunning;
     }
     return pingTaskIsRunning;
     */
    objc_sync_enter(_pingTaskIsRunningLock);
    BOOL pingTaskIsRunning = _pingTaskIsRunning;
    objc_sync_exit(_pingTaskIsRunningLock);
    return pingTaskIsRunning;
}

- (void)setPingTaskIsRunning:(BOOL)pingTaskIsRunning {
    /** Equal
     @synchronized(_pingTaskIsRunningLock) {
        _pingTaskIsRunning = pingTaskIsRunning;
     }
     */
    objc_sync_enter(_pingTaskIsRunningLock);
    _pingTaskIsRunning = pingTaskIsRunning;
    objc_sync_exit(_pingTaskIsRunningLock);
}

- (instancetype)initWithThreshold:(NSTimeInterval)threshold handler:(void(^)(void))hander {
    self = [super init];
    self.threshold = threshold;
    self.handler = hander;
    self->_semaphore = dispatch_semaphore_create(0);
    self.name = @"Watchdog";
    return self;
}

/**
 * 线程任务的入口
 */
- (void)main {
    while (!self.isCancelled) {
        _pingTaskIsRunning = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pingTaskIsRunning = NO;
            // 将 semaphore 计数增加1。如果有通过 dispatch_semaphore_wait 函数等待信号计数值增加的线程，则优先执行最先等待的线程。
            dispatch_semaphore_signal(self->_semaphore);
        });
        
        [NSThread sleepForTimeInterval:self.threshold];
        if (self.pingTaskIsRunning) {
            _handler ? _handler() : NULL;
        }
        
        // 线程等待，直至 semaphore 计数大于或等于1。当 semaphore 计数大于或等于1时，将 semaphore 计数减去1.
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end

@interface Watchdog ()
@property (strong, nonatomic) PingThread *pingThred;
@end

@implementation Watchdog

- (instancetype)initWithThreshold:(NSTimeInterval)threshold {
    return [self initWithThreshold:threshold handler:^{
        NSLog(@"👮 Main thread was blocked for more than %.2f s 👮", threshold);
    }];
}

- (instancetype)initWithThreshold:(NSTimeInterval)threshold handler:(Handler)hander {
    self = [super init];
    self.pingThred = [[PingThread alloc] initWithThreshold:threshold handler:hander];
    
    // 执行线程任务
    [self.pingThred start];
    return self;
}

@end
