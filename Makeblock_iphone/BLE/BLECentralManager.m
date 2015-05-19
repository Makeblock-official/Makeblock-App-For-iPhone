//
//  bleCentralManager.m
//  MonitoringCenter
//
//  Created by David ding on 13-1-10.
//
//

#import "BLECentralManager.h"

@interface BLECentralManager (){
    NSMutableArray *_delegates;
}

@end
/****************************************************************************/
/*                      CentralDelegateState的类型                           */
/****************************************************************************/
enum {
    // 中心设备事件状态
    BLECentralDelegateStateRetrievePeripherals = 0,
    BLECentralDelegateStateRetrieveConnectedPeripherals,
    BLECentralDelegateStateDiscoverPeripheral,
    BLECentralDelegateStateConnectPeripheral,
    BLECentralDelegateStateFailToConnectPeripheral,
    BLECentralDelegateStateDisconnectPeripheral,
    // 中心设备初始状态
    BLECentralDelegateStateCentralManagerResetting,
    BLECentralDelegateStateCentralManagerUnsupported,
    BLECentralDelegateStateCentralManagerUnauthorized,
    BLECentralDelegateStateCentralManagerUnknown,
    BLECentralDelegateStateCentralManagerPoweredOn,
    BLECentralDelegateStateCentralManagerPoweredOff,
};
typedef NSInteger BLECentralDelegateState;

enum {
    BLEPeripheralDelegateStateInit = 0,
    BLEPeripheralDelegateStateDiscoverServices,
    BLEPeripheralDelegateStateDiscoverCharacteristics,
    BLEPeripheralDelegateStateKeepActive,
};
typedef NSInteger BLEPeripheralDelegateState;

// 消息通知
//==============================================
// 发送消息
#define nCentralStateChange                     [[NSNotificationCenter defaultCenter] postNotificationName:@"nCBCentralStateChange"  object:nil];
// 接收消息
#define nCBCentralStateChange                   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CBCentralStateChange:) name:@"nCBCentralStateChange" object:nil];

@implementation BLECentralManager

static BLECentralManager*_instance;
#pragma mark -
#pragma mark Init
/******************************************************/
//          类初始化                                   //
/******************************************************/
// 初始化蓝牙
-(id)init{
    self = [super init];
    if (self) {
        self.activeCentralManager = [[CBCentralManager alloc] initWithDelegate:(id<CBCentralManagerDelegate>)self queue:dispatch_get_main_queue()];
        _delegates = [[NSMutableArray alloc]init];
        [self initProperty];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CBCentralStateChange:) name:@"nCBCentralStateChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CBUpdataShowStringBuffer:) name:@"CBUpdataShowStringBuffer" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CBPeripheralStateChange: ) name:@"CBPeripheralStateChange" object:nil];
    }
    return self;
}
-(void)addDelegate:(id<BLEControllerDelegate>)delegate{
    if(![_delegates containsObject:delegate]){
        [_delegates addObject:delegate];
    }
}
-(void)removeDelegate:(id<BLEControllerDelegate>)delegate{
    if([_delegates containsObject:delegate]){
        [_delegates removeObject:delegate];
    }
}
-(void)stateChanged{
    for (id<BLEControllerDelegate> delegate in _delegates) {
        if([delegate respondsToSelector:@selector(bleStateChanged)]){
            [delegate bleStateChanged];
        }
    }
}
-(void)peripheralConnected{
    for (id<BLEControllerDelegate> delegate in _delegates) {
        if([delegate respondsToSelector:@selector(bleConnected)]){
            [delegate bleConnected];
        }
    }
}
-(void)peripheralDisconnected{
    _activePeripheral = nil;
    // todo: delegate maybe null
    for (int i=0;i<_delegates.count;i++) {
        id delegate = [_delegates objectAtIndex:i];
        if([delegate respondsToSelector:@selector(bleDisconnected)]){
            [delegate bleDisconnected];
        }
    }
}
-(void)receivedData:(NSData*)data{
    for (id<BLEControllerDelegate> delegate in _delegates) {
        if([delegate respondsToSelector:@selector(bleReceivedData:)]){
            [delegate bleReceivedData:data];
        }
    }
}
-(void)CBCentralStateChange:(NSNotification*)notification{
    [self stateChanged];
}
-(void)CBUpdataShowStringBuffer:(NSNotification*)notification{
    [self receivedData:[notification.userInfo objectForKey:@"data"]];
}
-(void)CBPeripheralStateChange:(NSNotification*)notification{
/*
    if(_activePeripheral.currentPeripheralState==BLEPeripheralDelegateStateKeepActive){
        //[self peripheralDisconnected];
    }else{
        [self peripheralConnected];
    }
 */
    if(_activePeripheral.currentPeripheralState==BLEPeripheralDelegateStateKeepActive){
        [self peripheralConnected];
    }
}
-(void)initProperty{
    self.peripherals = [NSMutableArray array];
    self.rssiDict = [NSMutableDictionary dictionaryWithCapacity:10];
}
+(BLECentralManager*)sharedManager{
    if(_instance==nil){
        _instance = [[BLECentralManager alloc]init];
    }
    return _instance;
}
#pragma mark -
#pragma mark Scanning
/****************************************************************************/
/*						   		Scanning                                    */
/****************************************************************************/
// 按UUID进行扫描
-(void)startScanning{
    // CBCentralManagerScanOptionAllowDuplicatesKey | CBConnectPeripheralOptionNotifyOnConnectionKey | CBConnectPeripheralOptionNotifyOnDisconnectionKey | CBConnectPeripheralOptionNotifyOnNotificationKey
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
	[_activeCentralManager scanForPeripheralsWithServices:nil options:options];
    //[[self peripherals] removeAllObjects]; // yzj, is necessary here?
    NSLog(@"startScanning...");
}

// 停止扫描
-(void)stopScanning{
	[_activeCentralManager stopScan];
}

// 扫描复位
-(void)resetScanning{
    [self stopScanning];
    [self startScanning];
}

#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
// 开始连接
-(void)connectPeripheral:(CBPeripheral*)peripheral
{
	if (peripheral.state!=CBPeripheralStateConnected){
        // 连接设备
        [_activeCentralManager connectPeripheral:peripheral options:nil];
	}
    else{
        // 检测已连接Peripherals
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 6.0){
            [_activeCentralManager retrieveConnectedPeripheralsWithServices:nil];
        }
    }
}

// 断开连接
-(void)disconnectPeripheral:(CBPeripheral*)peripheral
{
    // 主动断开
    [_activeCentralManager cancelPeripheralConnection:peripheral];
    [self resetScanning];
}

#pragma mark -
#pragma mark CBCentralManager
/****************************************************************************/
/*							CBCentralManager								*/
/****************************************************************************/
// 中心设备状态更新
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //activeCentralManager = central;
    if ([_activeCentralManager isEqual:central]) {
        switch ([central state]){
                // 掉电状态
            case CBCentralManagerStatePoweredOff:
            {
                // 更新状态
                _currentCentralManagerState = BLECentralDelegateStateCentralManagerPoweredOff;
                nCentralStateChange
                [self resetScanning];
                NSLog(@"CBCentralManagerStatePoweredOff\n");
                break;
            }
                
                // 未经授权的状态
            case CBCentralManagerStateUnauthorized:
            {
                /* Tell user the app is not allowed. */
                // 更新状态
                _currentCentralManagerState = BLECentralDelegateStateCentralManagerUnauthorized;
                nCentralStateChange
                [self resetScanning];
                NSLog(@"CBCentralManagerStateUnauthorized\n");
                break;
            }
                
                // 未知状态
            case CBCentralManagerStateUnknown:
            {
                /* Bad news, let's wait for another event. */
                // 更新状态
                _currentCentralManagerState = BLECentralDelegateStateCentralManagerUnknown;
                nCentralStateChange
                [self resetScanning];
                NSLog(@"CBCentralManagerStateUnknown\n");
                break;
            }
                
            case CBCentralManagerStateUnsupported:
            {
                // 更新状态
                _currentCentralManagerState = BLECentralDelegateStateCentralManagerUnsupported;
                nCentralStateChange
                [self resetScanning];
                NSLog(@"CBCentralManagerStateUnsupported\n");
                break;
            }
                
                // 上电状态
            case CBCentralManagerStatePoweredOn:
            {
                // 更新状态
                _currentCentralManagerState = BLECentralDelegateStateCentralManagerPoweredOn;
                nCentralStateChange
                [self startScanning];
                NSLog(@"CBCentralManagerStatePoweredOn\n");
                break;
            }
                
                // 重置状态
            case CBCentralManagerStateResetting:
            {
                // 更新状态
                _currentCentralManagerState = BLECentralDelegateStateCentralManagerResetting;
                nCentralStateChange
                [self resetScanning];
                NSLog(@"CBCentralManagerStateResetting\n");
                break;
            }
        }
    }
}
// 中心设备连接检索到的外围设备
-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    if ([_activeCentralManager isEqual:central]) {
        
        for (CBPeripheral *aPeripheral in peripherals){
            if(![_peripherals containsObject:aPeripheral]){
                [_peripherals addObject:aPeripheral];
            }
            [central connectPeripheral:aPeripheral options:nil];
        }
        // 更新状态
        _currentCentralManagerState = BLECentralDelegateStateRetrieveConnectedPeripherals;
        nCentralStateChange
    }
}

// 中心设备扫描外围
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([_activeCentralManager isEqual:central]) {
        //dLog(@"didDiscoverPeripheral %@ %@ %@",peripheral.name,peripheral.UUID,RSSI);
        [_rssiDict setObject:RSSI forKey:[peripheral.identifier UUIDString]];
        if(![_peripherals containsObject:peripheral]){
            [_peripherals addObject:peripheral];
        }
        // 更新状态
        _currentCentralManagerState = BLECentralDelegateStateDiscoverPeripheral;
        nCentralStateChange
    }
}

- (void) peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
   dLog(@"%@ %@ %@",peripheral.name,peripheral.name,peripheral.RSSI);
}

// 中心设备连接外围设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if ([_activeCentralManager isEqual:central]) {
        if(![_peripherals containsObject:peripheral]){
            [_peripherals addObject:peripheral];
        }
        if (_activePeripheral == nil) {
            self.activePeripheral = [[BLEPeripheral alloc]init];
        }
        _activePeripheral.activePeripheral = peripheral;
        // 如果当前设备是已连接设备开始扫描服务
        CBUUID	*TransSerUUID     = [CBUUID UUIDWithString:kTransDataServiceUUID];
        NSArray	*serviceArray	= [NSArray arrayWithObjects:TransSerUUID, nil];
        [_activePeripheral startPeripheral:peripheral DiscoverServices:serviceArray];
        
        // 更新状态
        _currentCentralManagerState = BLECentralDelegateStateConnectPeripheral;
        nCentralStateChange
    }
}

// 中心设备断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([_activeCentralManager isEqual:central]) {
    }
    // 更新状态
    NSLog(@"didDisconnectPeripheral domain:%@ userInfo:%@",error.domain, error.userInfo);
    _currentCentralManagerState = BLECentralDelegateStateDisconnectPeripheral;
    //nCentralStateChange
    // don't call delegate when error happens
    [self peripheralDisconnected];
    [[self peripherals] removeAllObjects];
    // restart scan
    [self resetScanning]; // restart scanning
}


/****************************************************************************/
/*                                  END                                     */
/****************************************************************************/
@end
