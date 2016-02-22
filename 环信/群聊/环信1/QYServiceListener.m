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
    
    
    //监听客户端有没有数据上传 timeout -1 不超时
    [newSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"有%ld 客户端连接到服务器",self.clientSocket.count);
}
#pragma 读取客户端请求的数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //把NSData转成NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //把当前客户端的数据转发给其他的客户端
    for (GCDAsyncSocket *socket in self.clientSocket) {
        if (socket != sock) {
            [socket writeData:data withTimeout:-1 tag:0];
        }
       
    }
    NSLog(@"读取数据 clickSocket %@",str);
    
    //每次读完数据之后都要调用一次监听数据的方法
    [sock readDataWithTimeout:-1 tag:0];
}
@end
