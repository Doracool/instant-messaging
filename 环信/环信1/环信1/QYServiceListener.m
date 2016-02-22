//
//  QYServiceListener.m
//  环信1
//
//  Created by qingyun on 16/2/21.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import "QYServiceListener.h"
#import "GCDAsyncSocket.h"

@interface QYServiceListener ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *severSocket;
@property (nonatomic, strong) NSMutableArray *clientSocket;//保存所有的客户端的Socket对象
@end
@implementation QYServiceListener

-(NSMutableArray *)clientSocket
{
    if (!_clientSocket) {
        _clientSocket = [NSMutableArray array];
    }
    return _clientSocket;
}

-(void)start
{
    //开启10086服务
    //创建一个Socket对象(服务端的 只监听有没有客户端请求连接)
    GCDAsyncSocket *SeverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    self.severSocket = SeverSocket;
    //绑定端口,并开启监听 代表我10086服务开启
    NSError *error = nil;
    [SeverSocket acceptOnPort:5288 error:&error];
    if (!error) {
        NSLog(@"服务开启成功");
    }else{
        NSLog(@"服务开启失败%@",error);
    }
    
    //开启主运行循环 让服务不能停
    [[NSRunLoop mainRunLoop] run];
}

#pragma 有客户端的Socket连接到服务器
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"%@",sock);
    NSLog(@"%@",newSocket);
    //保存客户端的额Socket
    [self.clientSocket addObject:newSocket];
    
    //提供服务
    NSMutableString *serverStr = [NSMutableString string];
    [serverStr appendString:@"欢迎来到10086 请选择你需要的服务\n"];
    [serverStr appendString:@"[0]在线充值\n"];
    [serverStr appendString:@"[1]在线投诉\n"];
    [serverStr appendString:@"[2]优惠信息\n"];
    [serverStr appendString:@"[3]特殊服务\n"];
    [serverStr appendString:@"[4]退出\n"];
    [newSocket writeData:[serverStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    //监听客户端有没有数据上传 timeout -1 不超时
    [newSocket readDataWithTimeout:-1 tag:0];
}
#pragma 读取客户端请求的数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //把NSData转成NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"读取数据 clickSocket %@",str);
    
    //字符串转数字
    NSInteger code = [str integerValue];
    NSString *responseStr = nil;
    switch (code) {
        case 0:
            responseStr = @"充值服务暂时关闭\n";
            break;
        case 1:
            responseStr = @"投诉服务暂时关闭\n";
            break;
        case 2:
            responseStr = @"没有优惠服务\n";
            break;
        case 3:
            responseStr = @"没有特殊服务\n";
            break;
        case 4:
            responseStr = @"成功退出\n";
            break;
            
        default:
            break;
    }
    //处理请求 返回数据给客户端
    [sock writeData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    if (code == 4) {
        [self.clientSocket removeObject:sock];
    }
    //每次读完数据之后都要调用一次监听数据的方法
    [sock readDataWithTimeout:-1 tag:0];
}
@end
