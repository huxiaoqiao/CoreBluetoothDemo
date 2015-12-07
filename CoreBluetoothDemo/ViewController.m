//
//  ViewController.m
//  CoreBluetoothDemo
//
//  Created by 胡晓桥 on 15/12/7.
//  Copyright © 2015年 胡晓桥. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>//导入蓝牙系统库


//必须要用UUID来唯一标识对应的service和characteristic

#define kServiceUUID @"5C476471-1109-4EBE-A826-45B4F9D74FB9"
#define kCharacteristicHeartRateUUID @"82C7AC0F-6113-4EC9-92D1-5EEF44571398"
#define kCharacteristicBodyLocationUUID @"537B5FD6-1889-4041-9C35-F6949D1CA034"

#define BLE_SERVICE_NAME @"BLE_DEVICE"

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@end

/**
 *  蓝牙开发步骤
 1.创建中心角色
 2.扫描外设
 3.连接外设
 4.扫描外设中的服务和特征
 5.与外设进行数据交互
 */


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //2.扫描外设
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - centralManager代理方法
//中心设备状态发生改变时调用该方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

//3.连接外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([peripheral.name isEqualToString:BLE_SERVICE_NAME]) {
        [self connect:peripheral];
    }
}

- (void)connect:(CBPeripheral *)peripheral
{
    self.peripheral = peripheral;
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@(YES)}];
}
//4.扫描外设中的服务和特征
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

#pragma mark - peripheral代理方法
//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *sevice in peripheral.services) {
        //发现服务
        if ([sevice.UUID.UUIDString isEqualToString:kServiceUUID]) {
            [peripheral discoverCharacteristics:nil forService:sevice];
            break;
        }
    }
}

//发现服务中的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:kCharacteristicHeartRateUUID]) {
            //监听特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

//5.与外设进行数据交互
//读取数据：
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self decodeData:characteristic.value];
}

- (void)decodeData:(NSData *)data
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataStr);
}
//写数据
- (void)writeToPeriperalWithData:(NSData *)data characteristic:(CBCharacteristic *)characteristic
{
    [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}


#pragma mark - 懒加载代码
//1.创建中心角色
- (CBCentralManager *)centralManager
{
    if (_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:nil];
    }
    return _centralManager;
}


@end
