//
//  MWUpdateFirmwareViewController.h
//  Makeblock HD
//
//  Created by Riven on 14-7-11.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECentralManager.h"
#import "MWFileDelegate.h"

#define STK_OK              0x10
#define STK_FAILED          0x11  // Not used
#define STK_UNKNOWN         0x12  // Not used
#define STK_NODEVICE        0x13  // Not used
#define STK_INSYNC          0x14  // ' '
#define STK_NOSYNC          0x15  // Not used
#define ADC_CHANNEL_ERROR   0x16  // Not used
#define ADC_MEASURE_OK      0x17  // Not used
#define PWM_CHANNEL_ERROR   0x18  // Not used
#define PWM_ADJUST_OK       0x19  // Not used
#define CRC_EOP             0x20  // 'SPACE'
#define STK_GET_SYNC        0x30  // '0'
#define STK_GET_SIGN_ON     0x31  // '1'

#define STK_SET_PARAMETER   0x40  // '@'

#define STK_GET_PARAMETER   0x41  // 'A'

#define STK_SET_DEVICE      0x42  // 'B'
#define STK_SET_DEVICE_EXT  0x45  // 'E'
#define STK_ENTER_PROGMODE  0x50  // 'P'
#define STK_LEAVE_PROGMODE  0x51  // 'Q'
#define STK_CHIP_ERASE      0x52  // 'R'
#define STK_CHECK_AUTOINC   0x53  // 'S'
#define STK_LOAD_ADDRESS    0x55  // 'U'
#define STK_UNIVERSAL       0x56  // 'V'
#define STK_PROG_FLASH      0x60  // '`'
#define STK_PROG_DATA       0x61  // 'a'
#define STK_PROG_FUSE       0x62  // 'b'
#define STK_PROG_LOCK       0x63  // 'c'
#define STK_PROG_PAGE       0x64  // 'd'
#define STK_PROG_FUSE_EXT   0x65  // 'e'
#define STK_READ_FLASH      0x70  // 'p'
#define STK_READ_DATA       0x71  // 'q'
#define STK_READ_FUSE       0x72  // 'r'
#define STK_READ_LOCK       0x73  // 's'
#define STK_READ_PAGE       0x74  // 't'
#define STK_READ_SIGN       0x75  // 'u'
#define STK_READ_OSCCAL     0x76  // 'v'
#define STK_READ_FUSE_EXT   0x77  // 'w'
#define STK_READ_OSCCAL_EXT 0x78  // 'x'

#define CAT_SETADDR 0x41 // 'A'
#define CAT_WRITE 0x42 // 'B'
#define CAT_QUIT 0x45 // 'E'

#define QUERY_HW_VER 0x80
#define QUERY_SW_MAJOR 0x81
#define QUERY_SW_MINOR 0x82

#define DOWNLOAD_SENDADDR 0xE0
#define DOWNLOAD_SENDCODE 0xE1

enum{
    DOWNLOAD_PROTOCOL_UNKNOW=0,
    DOWNLOAD_PROTOCOL_UNO=1,
    DOWNLOAD_PROTOCOL_LEONARDO=2
};

enum{
    ST_NULLDEVICE=0,
    ST_PROBING,
    ST_FOUND,
    ST_DOWNLOADING,
    ST_READ,
};

@interface MWUpdateFirmwareViewController : UIViewController <BLEControllerDelegate,MWFileDelegate>
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIProgressView *updateProgressbar;
@property (weak, nonatomic) IBOutlet UILabel *updateStatus;
@property (nonatomic,strong) NSData *hexData;
@property (nonatomic, copy) NSString *updateMessage;
@property (weak, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property NSString * code;
@property NSArray * hex;
- (IBAction)startupdateHandler:(id)sender;

@end
