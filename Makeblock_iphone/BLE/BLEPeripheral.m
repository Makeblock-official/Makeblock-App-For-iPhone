//
//  blePeripheral.m
//  MonitoringCenter
//
//  Created by David ding on 13-1-10.
//
//

#import "BLEPeripheral.h"




#define kConnectedFinish                        YES
#define kDisconnected                           NO


// 数据包长度
#define TRANSMIT_DATA_LENGHT            20

// 消息通知
//==============================================
// 发送消息
#define nPeripheralStateChange                  [[NSNotificationCenter defaultCenter]postNotificationName:@"CBPeripheralStateChange" object:nil];
#define nUpdataShowStringBuffer                 [[NSNotificationCenter defaultCenter]postNotificationName:@"CBUpdataShowStringBuffer" object:nil];

// 接收消息
#define nCBPeripheralStateChange                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CBPeripheralStateChange ) name:@"CBPeripheralStateChange" object:nil];
#define nCBUpdataShowStringBuffer               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CBUpdataShowStringBuffer ) name:@"CBUpdataShowStringBuffer" object:nil];
//==============================================

/****************************************************************************/
/*                      PeripheralDelegateState的类型                        */
/****************************************************************************/
// Peripheral的消息类型
enum {
    BLEPeripheralDelegateStateInit = 0,
    BLEPeripheralDelegateStateDiscoverServices,
    BLEPeripheralDelegateStateDiscoverCharacteristics,
    BLEPeripheralDelegateStateKeepActive,
};
typedef NSInteger BLEPeripheralDelegateState;
@implementation BLEPeripheral

NSMutableData *rxBuf;

#pragma mark -
#pragma mark Init
/******************************************************/
//          类初始化                                   //
/******************************************************/
// 初始化蓝牙
-(id)init{
    self = [super init];
    if (self) {
        [self initPeripheralWithSeviceAndCharacteristic];
        [self initPropert];
        _buffers = [NSMutableArray array];
        rxBuf = [NSMutableData data];
        isDual = NO;
        isFlowControl = YES;
        isBootloader = NO;
        enWrite = NO;
        enNotify = NO;
    }
    return self;
}

-(void)setActivePeripheral:(CBPeripheral *)AP{
    _activePeripheral = AP;
    NSString *aname = [[NSString alloc]initWithFormat:@"%@",_activePeripheral.name];
    NSLog(@"aname:%@",aname);
    if (![aname isEqualToString:@"(null)"]) {
        _nameString = aname;
    }
    else{
        _nameString = @"Error Name";
    }
    if (_activePeripheral.identifier.UUIDString.length >= 36) {
        _uuidString = [_activePeripheral.identifier.UUIDString substringWithRange:NSMakeRange(_activePeripheral.identifier.UUIDString.length-36, 36)];
        NSLog(@"uuidString:%@",_uuidString);
    }
}


-(void)initPeripheralWithSeviceAndCharacteristic{
    // CBPeripheral
    [_activePeripheral setDelegate:nil];
    _activePeripheral = nil;
    // CBService and CBCharacteristic
    _transDataService = nil;
    _resetService = nil;
    _resetCharateristic = nil;
    _transDataCharateristic = nil;
}

-(void)initPropert{
    // Property
    _staticString = @"Init";
    _currentPeripheralState = BLEPeripheralDelegateStateInit;
    nPeripheralStateChange
    _connectedFinish = kDisconnected;
    _receiveData = 0;
    _sendData = 0;
    _txCounter = 0;
    _rxCounter = 0;
    self.showStringBuffer = [NSString string];
}

#pragma mark -
#pragma mark Scanning
/****************************************************************************/
/*						   		Scanning                                    */
/****************************************************************************/
// 按UUID进行扫描
-(void)startPeripheral:(CBPeripheral *)peripheral DiscoverServices:(NSArray *)services{
    if ([peripheral isEqual:_activePeripheral] && peripheral.state==CBPeripheralStateConnected){
        _activePeripheral = peripheral;
        [_activePeripheral setDelegate:(id<CBPeripheralDelegate>)self];
        [_activePeripheral discoverServices:nil];
    }
}

-(void)disconnectPeripheral:(CBPeripheral *)peripheral{
    if ([peripheral isEqual:_activePeripheral]){
        // 内存释放
        [self initPeripheralWithSeviceAndCharacteristic];
        [self initPropert];
    }
}

#pragma mark -
#pragma mark CBPeripheral
/****************************************************************************/
/*                              CBPeripheral								*/
/****************************************************************************/
// 扫描服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error)
    {
        if ([peripheral isEqual:_activePeripheral]){
            // 新建服务数组
            NSArray *services = [peripheral services];
            if (!services || ![services count])
            {
                NSLog(@"发现错误的服务 %@\r\n", peripheral.services);
            }
            else
            {
                // 开始扫描服务
                _staticString = @"Discover services";
                _currentPeripheralState = BLEPeripheralDelegateStateDiscoverServices;
                nPeripheralStateChange
                for (CBService *service in peripheral.services)
                {
                    NSLog(@"发现服务UUID: %@\r\n", service.UUID);
                    //================== TransmitMoudel =====================
                    if ([[service UUID] isEqual:[CBUUID UUIDWithString:kTransDataServiceUUID]])
                    {
                        // 扫描接收数据服务特征值
                        _transDataService = service;
                        [peripheral discoverCharacteristics:nil forService:_transDataService];
                    }else if([[service UUID] isEqual:[CBUUID UUIDWithString:kTransDataDualServiceUUID]]){
                        _transDataService = service;
                        [peripheral discoverCharacteristics:nil forService:_transDataService];
                        isDual = YES;
                    }else if([[service UUID] isEqual:[CBUUID UUIDWithString:kDualResetServiceUUID]]){
                        _resetService = service;
                        [peripheral discoverCharacteristics:nil forService:_resetService];
                    }
                    //======================== END =========================
                }
            }
        }
    }
}

// 从服务中扫描特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (!error) {
        if ([peripheral isEqual:_activePeripheral]){
            // 开始扫描特征值
            _staticString = @"Discover characteristics";
            _currentPeripheralState = BLEPeripheralDelegateStateDiscoverCharacteristics;
            nPeripheralStateChange
            // 新建特征值数组
            NSArray *characteristics = [service characteristics];
            CBCharacteristic *characteristic;
            //================== TransmitMoudel =====================//
            if ([[service UUID] isEqual:[CBUUID UUIDWithString:isDual?kTransDataDualServiceUUID:kTransDataServiceUUID]])
            {
                for (characteristic in characteristics)
                {
                    NSLog(@"发现特值UUID: %@ - %@\n", [characteristic UUID],service);
                    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:isDual?kTransDataDualCharateristicUUID:kTransDataCharateristicUUID]])
                    {
                        _transDataCharateristic = characteristic;
                        enWrite = YES;
                        if(enNotify){
                            [self finishConnected];
                        }
                    }else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:isDual?kNofityDataDualCharateristicUUID:kNofityDataCharateristicUUID]]){
                        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                        enNotify = YES;
                        if(enWrite){
                            [self finishConnected];
                        }

                    }
                }
            }else if([[service UUID] isEqual:[CBUUID UUIDWithString:kDualResetServiceUUID]]){
                for (characteristic in characteristics)
                {
                    NSLog(@"发现特值UUID: %@ - %@\n", [characteristic UUID],service);
                    if([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kDualResetCharateristicUUID]]){
                        _resetCharateristic = characteristic;
                    }
                }
            }
            //======================== END =========================
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    
}

// 更新特征值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([error code] == 0) {
        //NSLog(@"char value %@, new value: %@, error: %@", characteristic.UUID, [[NSString alloc] initWithData:[characteristic value] encoding:NSASCIIStringEncoding], error);
        if ([peripheral isEqual:_activePeripheral]){
            
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:isDual?kNofityDataDualCharateristicUUID:kNofityDataCharateristicUUID]]){
                //_receiveData = characteristic.value;
                //[self receiveData:_receiveData];
                NSData * rx =characteristic.value;
                if(isBootloader){
                    [self receiveData:rx];
                }else{

                [rxBuf appendData:rx];
                char * b = (char *)[rxBuf bytes];
                if(b[rxBuf.length-1]=='\r'||b[rxBuf.length-1]=='\n'){
                    [self receiveData:rxBuf];
                    rxBuf = [NSMutableData data];
                }
                }
            }
            //======================== END =========================
      }
    }
    else{
        //NSLog(@"参数更新出错: %d",[error code]);
    }
}

#pragma mark -
#pragma mark read/write/notification
/******************************************************/
//          读写通知等基础函数                           //
/******************************************************/
// 写数据到特征值
-(void) writeValue:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic data:(NSData *)data{
    if ([peripheral isEqual:_activePeripheral] && peripheral.state==CBPeripheralStateConnected)
    {
        if (characteristic != nil) {
//            dLog(@"成功写数据到特征值: %@ 数据:%@\n", characteristic.UUID, data);
//            if([NSDate date].timeIntervalSince1970-lastTimeStamp>0.06){
//                lastTimeStamp = [NSDate date].timeIntervalSince1970;
                [peripheral writeValue:data forCharacteristic:characteristic type:isDual?CBCharacteristicWriteWithoutResponse:CBCharacteristicWriteWithResponse];
//            }
        }
    }
}

// 从特征值读取数据
-(void) readValue:(CBPeripheral *)peripheral characteristicUUID:(CBCharacteristic *)characteristic{
    if ([peripheral isEqual:_activePeripheral] && peripheral.state==CBPeripheralStateConnected)
    {
        if (characteristic != nil) {
            dLog(@"成功从特征值:%@ 读数据\n", characteristic);
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

// 发通知到特征值
-(void) notification:(CBPeripheral *)peripheral characteristicUUID:(CBCharacteristic *)characteristic state:(BOOL)state{
    if ([peripheral isEqual:_activePeripheral] && peripheral.state==CBPeripheralStateConnected)
    {
        if (characteristic != nil) {
            dLog(@"成功发通知到特征值: %@\n", characteristic);
            [peripheral setNotifyValue:state forCharacteristic:characteristic];
        }
    }
}

#pragma mark -
#pragma mark Set property
/******************************************************/
//              BLE属性操作函数                          //
/******************************************************/
-(void)finishConnected{
    // 更新标志
    _connectedFinish = YES;
    _staticString = @"Connected finish";
    _currentPeripheralState = BLEPeripheralDelegateStateKeepActive;
    dLog(@"连接完成\n");
    nPeripheralStateChange

}

-(void)receiveData:(NSData *)data{
    if(data.length==0){
        return;
    }
//    dLog(@"成功接收: %@\n", data);
    //self.staticString = [NSString stringWithFormat:@"Receive:%@",[NSString stringWithUTF8String:data.bytes]];
    isSending = NO;
    [self execute];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CBUpdataShowStringBuffer" object:nil userInfo:@{@"data":data}];
}
-(void)readData{
    [self readValue:_activePeripheral characteristicUUID:_transDataCharateristic];
}
-(void)sendData:(NSData *)data
{
    [_buffers addObject:data];
    [self execute];
}

-(void)sendDataMandatory:(NSData *)data{
//    dLog(@"BLE[M]->%@",[NSString stringWithCString:data.bytes encoding:NSUTF8StringEncoding]);
    [self writeValue:_activePeripheral characteristic:_transDataCharateristic data:data];
}

-(void)resetIO{
    if(_resetCharateristic==nil) return;
 
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after
        char i = 1;
        NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
        [_activePeripheral writeValue:data forCharacteristic:_resetCharateristic type:CBCharacteristicWriteWithResponse];
    });
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, 0.10 * NSEC_PER_SEC);
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after
        
        char i=0;
        NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
        [_activePeripheral writeValue:data forCharacteristic:_resetCharateristic type:CBCharacteristicWriteWithResponse];
    });
    dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, 0.20 * NSEC_PER_SEC);
    dispatch_after(popTime3, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after
        
        char i=1;
        NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
        [_activePeripheral writeValue:data forCharacteristic:_resetCharateristic type:CBCharacteristicWriteWithResponse];
    });
}

-(void)execute{
    //NSLog(@"count:%ld",_buffers.count);
    if(_buffers.count>0){
        NSData *data = [_buffers objectAtIndex:0];
        dLog(@"BLE->%@",[NSString stringWithCString:data.bytes encoding:NSUTF8StringEncoding]);
        [self writeValue:_activePeripheral characteristic:_transDataCharateristic data:data];
        [_buffers removeObjectAtIndex:0];
        isSending = YES;
    }
}

-(BOOL)getBleMode
{
    return isDual;
}

-(void)setFlowControl:(BOOL)onoff
{
    isFlowControl = onoff;
}

-(void)setBootloader:(BOOL)onoff
{
    isBootloader = onoff;
}

-(BOOL)getBootloader
{
    return isBootloader;
}

@end
