//
//  Watchdog.h
//  iOS_freeze_detecting
//
//  Created by Jacky on 2019/2/12.
//  Copyright © 2019 Xiangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Handler)(void);

@interface Watchdog : NSObject

/**
 *

 @param threshold 一个任务执行超过多久认为阻塞了主线程，单位m：秒
 @return Watchdog 实例
 */
- (instancetype)initWithThreshold:(NSTimeInterval)threshold;

@end

NS_ASSUME_NONNULL_END
