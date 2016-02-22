//
//  ViewController.m
//  群聊客户端
//
//  Created by qingyun on 16/2/21.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *uitextFiled;

@property (weak, nonatomic) IBOutlet UITableView *UITableView;
- (IBAction)senderAction:(id)sender;
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //实现聊天室
    //1 连接到群聊服务器
    // 1.1 创建一个客户端的Socket对象
    GCDAsyncSocket *clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    self.clientSocket = clientSocket;
    
    //发送连接请求
    NSError *error = nil;
    [clientSocket connectToHost:@"172.16.3.51" onPort:5288 error:&error];
    if (!error) {
        NSLog(@"%@",error);
    }
    //发送聊天消息和接收聊天消息
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"与服务器连接成功");
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"与服务器断开连接 %@",err);
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    [sock readDataWithTimeout:-1 tag:0];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}
- (IBAction)senderAction:(id)sender {
    NSString *str = self.uitextFiled.text;
    if (str.length == 0) {
        return;
    }
    
    //发数据
    [self.clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

@end
