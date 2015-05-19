//
//  blePeripheral.h
//  MonitoringCenter
//
//  Created by David ding on 13-1-10.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


// 指定扫描广播UUID
#define kConnectedServiceUUID     @"FFF0"//
#define kConnectedDualServiceUUID @"FFE1"
//================== TransmitMoudel =====================
// TransmitMoudel Receive Data Service UUID
#define kTransDataServiceUUID                    @"FFF0"
#define kTransDataDualServiceUUID                @"FFE1"
#define kDualResetServiceUUID           @"FFE4"
// TransmitMoudel characteristics UUID
#define kTransDataCharateristicUUID         @"FFF1"
#define kTransDataDualCharateristicUUID     @"FFE3"
#define kNofityDataCharateristicUUID        @"FFF4"
#define kNofityDataDualCharateristicUUID        @"FFE2"

#define kDualResetCharateristicUUID         @"FFE5"

@interface BLEPeripheral : NSObject{
    BOOL isDual;
    BOOL isFlowControl;
    BOOL isBootloader;
    BOOL enWrite;
    BOOL enNotify;
    BOOL isSending;
    NSTimeInterval lastTimeStamp;
}
//======================================================
// CBPeripheral
@property(strong, nonatomic)    CBPeripheral            *activePeripheral;
//======================================================
// CBService and CBCharacteristic
@property(readonly)             CBService               *transDataService;
@property(readonly)             CBService               *resetService;
@property(readonly)             CBCharacteristic        *transDataCharateristic;
@property(readonly)             CBCharacteristic        *resetCharateristic;

//======================================================
// Property
@property(readonly)             NSUInteger              currentPeripheralState;
@property(readonly)             NSString                *nameString;
@property(readonly)             NSString                *uuidString;
@property(readwrite)            NSString                *staticString;

@property(readonly)             BOOL                    connectedFinish;
@property(readonly)             NSData                  *receiveData;
@property(nonatomic)            NSData                  *sendData;
@property(readwrite)            uint                    txCounter;
@property(readwrite)            uint                    rxCounter;
@property(readwrite)            NSString                *showStringBuffer;

@property(nonatomic,retain)NSMutableArray *buffers;

//======================================================

// method
-(void)startPeripheral:(CBPeripheral *)peripheral DiscoverServices:(NSArray *)services;
-(void)disconnectPeripheral:(CBPeripheral *)peripheral;
-(void)initPeripheralWithSeviceAndCharacteristic;
-(void)initPropert;
-(void)sendData:(NSData *)data;
-(void)sendDataMandatory:(NSData *)data;
-(void)resetIO;
-(void)readData;
-(BOOL)getBleMode;
-(void)setFlowControl:(BOOL)onoff;
-(void)setBootloader:(BOOL)onoff;
-(BOOL)getBootloader;
@end
