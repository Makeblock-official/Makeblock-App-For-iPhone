//
//  bleCentralManager.h
//  MonitoringCenter
//
//  Created by David ding on 13-1-10.
//
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheral.h"
#import "BLEControllerDelegate.h"

//==============================================

@interface BLECentralManager : NSObject
//======================================================
// CBCentralManager
@property(strong, nonatomic)    CBCentralManager        *activeCentralManager;
//======================================================
// NSMutableArray
@property(strong, nonatomic)    NSMutableArray          *peripherals;            // blePeripheral
@property(strong, nonatomic)    NSMutableDictionary     *rssiDict;            // blePeripheral
@property(strong, nonatomic)    BLEPeripheral           *activePeripheral;            // blePeripheral
//======================================================
// Property
@property(readonly)             NSUInteger              currentCentralManagerState;
//======================================================

// method
-(void)startScanning;
-(void)stopScanning;
-(void)resetScanning;

-(void)addDelegate:(id<BLEControllerDelegate>)delegate;
-(void)removeDelegate:(id<BLEControllerDelegate>)delegate;

-(void)connectPeripheral:(CBPeripheral*)peripheral;
-(void)disconnectPeripheral:(CBPeripheral*)peripheral;
+(BLECentralManager*)sharedManager;
@end


