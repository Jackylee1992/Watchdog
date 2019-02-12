//
//  ViewController.m
//  iOS_freeze_detecting
//
//  Created by Jacky on 2019/2/12.
//  Copyright © 2019 Xiangyang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NSThread sleepForTimeInterval:5];
}

@end
