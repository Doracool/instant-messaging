//
//  main.m
//  环信1
//
//  Created by qingyun on 16/2/21.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYServiceListener.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        //1 、创建一个服务监听对象
        QYServiceListener *listener = [[QYServiceListener alloc] init];
        //2 、开启监听
        [listener start];
    }
    return 0;
}
