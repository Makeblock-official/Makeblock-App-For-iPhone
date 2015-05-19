//
//  MWUpdateFirmwareViewController.m
//  Makeblock HD
//
//  Created by Riven on 14-7-11.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import "MWUpdateFirmwareViewController.h"
#import "MWUserManager.h"
#import "MobClick.h"
#import "MWFileManager.h"
#import "MWVersionManager.h"
@interface MWUpdateFirmwareViewController ()

@end

@implementation MWUpdateFirmwareViewController
@synthesize timer,code,hex;

int download_protocol = DOWNLOAD_PROTOCOL_UNKNOW;
int prevCmd,prevCmdSub,state;
#define ARDUINO_PAGE_SIZE 128
int hexptr,pageptr=0,pagelen=0;
char pagebuff[512];
unsigned char hw_version,sw_ver_min,sw_ver_maj;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"UpgradePage"];
    [self.updateButton setTitle:NSLocalizedString(@"Start Update",nil) forState:UIControlStateNormal];
    [self.updateStatus setText:NSLocalizedString(@"",nil) ];
    [self.backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [self.updateProgressbar setProgress:0];
    
    [[BLECentralManager sharedManager] addDelegate:self];
    
    state = ST_NULLDEVICE;
    if(self.updateMessage){
        self.updateStatus.text = self.updateMessage;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"UpgradePage"];
    [self.timer invalidate];
    if([BLECentralManager sharedManager].activePeripheral!=nil){
        [[BLECentralManager sharedManager].activePeripheral setBootloader:NO];
    }
    [[BLECentralManager sharedManager] removeDelegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)skipHandle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startupdateHandler:(id)sender {
    if([[BLECentralManager sharedManager] activePeripheral]==nil){
        [self.updateStatus setText:NSLocalizedString(@"Please connect to peripheral first",nil) ];
        return;
    }
    
    [[MWFileManager sharedManager]start:[MWVersionManager sharedManager].orionURL delegate:self];
}

-(void)loadedFile:(NSData *)data{
    self.hexData = data;
    NSLog(@"hex length:%lu",(unsigned long)_hexData.length);
    if(_hexData.length>1000){
        [[BLECentralManager sharedManager].activePeripheral setBootloader:YES];
        [self startProbeTimer];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Firmware file loaded fail", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles: nil];
        [alert show];
    }
}
-(void)parseCmd:(NSData*)data
{
    char * c = (char*)[data bytes];
    if(prevCmd==STK_GET_SYNC && state==ST_PROBING){
        if(c[0]==0x14 && c[1]==0x10){
            // stop probing
            state = ST_FOUND;
            [timer invalidate];
            NSLog(@"Found UNO");
            
            [MWUserManager sharedManager].isUpdating = YES;
            [_updateButton setEnabled:NO];
//            NSString * mypath = [[NSBundle mainBundle] bundlePath];
//            mypath = [mypath stringByAppendingString:@"/"];
//            mypath = [mypath stringByAppendingString:@"firmware.orion.hex"];
            NSData * tmp = _hexData;
            code = [[NSString alloc] initWithData:tmp encoding:NSASCIIStringEncoding];
            hex = [code componentsSeparatedByString:@"\n"];
            [self sendQuery:QUERY_HW_VER];
            download_protocol = DOWNLOAD_PROTOCOL_UNO;
            return;
        }else if(c[0]=='C' && c[1]=='A'){ // cateria protocol for leonardo
            [MWUserManager sharedManager].isUpdating = YES;
            state = ST_DOWNLOADING;
            [timer invalidate];
            NSLog(@"Found LEONARDO");
            [[self updateStatus]setText:NSLocalizedString(@"Device Found,Downloading",nil)];
            [_updateButton setEnabled:NO];
            NSString * mypath = [[NSBundle mainBundle] bundlePath];
            mypath = [mypath stringByAppendingString:@"/"];
            mypath = [mypath stringByAppendingString:@"Blink.cpp.leo.hex"];
            NSData * tmp = [NSData dataWithContentsOfFile:mypath];
            code = [[NSString alloc] initWithData:tmp encoding:NSASCIIStringEncoding];
            hex = [code componentsSeparatedByString:@"\n"];
            [self sendAddr0_Leonardo];
            download_protocol = DOWNLOAD_PROTOCOL_LEONARDO;
            return;
        }else{
            return;
        }
    }
    if(prevCmd == STK_GET_PARAMETER && download_protocol == DOWNLOAD_PROTOCOL_UNO){
        if(prevCmdSub==QUERY_HW_VER){
            [self sendQuery:QUERY_SW_MINOR];
            hw_version = c[1];
        }else if(prevCmdSub==QUERY_SW_MINOR){
            [self sendQuery:QUERY_SW_MAJOR];
            sw_ver_min = c[1];
        }else if(prevCmdSub==QUERY_SW_MAJOR){
            sw_ver_maj = c[1];
            NSLog(@"hardware version: %d",(int)hw_version);
            NSLog(@"software version: %d.%d",(int)sw_ver_maj,(int)sw_ver_min);
            [MWUserManager sharedManager].isUpdating = YES;
            [_updateButton setEnabled:NO];
            [[self updateStatus]setText:NSLocalizedString(@"Device Found,Downloading",nil)];
            pageptr = 0;
            [self downloadHex];
        }
        return;
    }
    
    if(state==ST_DOWNLOADING && download_protocol == DOWNLOAD_PROTOCOL_UNO){
        if(c[data.length-1]==0x10){ // only accept 0x14 0x10
            if(prevCmd == STK_LOAD_ADDRESS){
                [self sendPage:pagelen];
                return;
            }else if(prevCmd == STK_PROG_PAGE){
                // prepare for a new page or return;
                [self downloadHex];
                return;
            }
        }
    }
    if(state==ST_DOWNLOADING && download_protocol==DOWNLOAD_PROTOCOL_LEONARDO){
        if(prevCmd == CAT_SETADDR){
            if(c[0]=='\r'){
                // start download firmware
                hexptr = 0;
                pageptr = 0;
                [self downloadHexLeonardo];
            }else{
                // don't start sending pages unless we got an confirm
                [self sendAddr0_Leonardo];
            }
        }else if(prevCmd == CAT_WRITE){
            if(c[0]=='\r'){
                [self downloadHexLeonardo];
            }else{
                // shit happens
                NSLog(@"unsync");
            }
        }
    
    }

}

-(void)sendPageLeonardo:(int)len
{
    u_char lenl = len & 0xff;
    u_char lenh = (len>>8) & 0xff;
    char c[4]={CAT_WRITE,lenh,lenl,'F'};
    NSData *cmd = [NSMutableData dataWithBytes:(const void *)c length:4];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    NSData * codepart = [NSData dataWithBytes:pagebuff length:len];
    // there is a delay for page erasing, we wait
    int64_t delaySend = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySend*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:codepart];
    });
    
    prevCmd = CAT_WRITE;
}



-(void)sendPage:(int)len
{
    const char fin[2]=" ";
    u_char lenl = len & 0xff;
    u_char lenh = (len>>8) & 0xff;
    char c[4]={STK_PROG_PAGE,lenh,lenl,'F'};
    NSMutableData *cmd = [NSMutableData dataWithBytes:(const void *)c length:4];
    [cmd appendBytes:pagebuff length:len];
    [cmd appendBytes:fin length:1];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    prevCmd = STK_PROG_PAGE;
}

-(void)downloadHex
{
    int len = 0;
    uint addr;
    if(state!=ST_DOWNLOADING){
        if(state!=ST_FOUND) return;
        hexptr = 0;
		pageptr = 0;
    }
    
	if(hexptr>=hex.count){
        NSLog(@"Update Finished");
        
        [MobClick event:@"upgrade"];
        [MWUserManager sharedManager].isUpdating = NO;
        
        [[MWVersionManager sharedManager]updateVersion:[MWVersionManager sharedManager].orionVer];
        [[self updateStatus]setText:NSLocalizedString(@"Update Finished",nil)];
        [self sendQuit];
        state = ST_FOUND;
        return;
    }
	state = ST_DOWNLOADING;
	memset(pagebuff,0,512);
    // read a page to buffer
    
    
    while(len<ARDUINO_PAGE_SIZE){
        char * t = pagebuff+len;
        //QByteArray b = hex.at(hexptr).toLatin1().data();
        const char * b = [[[hex objectAtIndex:hexptr] dataUsingEncoding:NSUTF8StringEncoding] bytes];
        if(b[8]=='1'){
			hexptr=(int)hex.count; // the final code line
            break;
        }
        len+=parseHexLine(&addr,t,b);
        hexptr++;
    }
    [[self updateProgressbar]setProgress:(float)hexptr/hex.count];
    [self.updateStatus setText:[NSString stringWithFormat:@"%@ %.2f%%",NSLocalizedString(@"Device Found,Downloading",nil),(float)hexptr*100.0/hex.count]];
    [self sendAddr:pageptr/2];
    pagelen = len;
	pageptr+=len;
    prevCmdSub = DOWNLOAD_SENDADDR;

}

-(void)downloadHexLeonardo
{
    int len = 0;
    uint addr;
    if(state!=ST_DOWNLOADING){
        if(state!=ST_FOUND) return;
        hexptr = 0;
		pageptr = 0;
    }
    if(hexptr>=hex.count){
        NSLog(@"Update Finished");
        [MWUserManager sharedManager].isUpdating = NO;
        [[MWVersionManager sharedManager]updateVersion:[MWVersionManager sharedManager].orionVer];
        [[self updateStatus]setText:NSLocalizedString(@"Update Finished",nil)];
        [self sendQuitLeonardo];
        state = ST_FOUND;
        return;
    }
    state = ST_DOWNLOADING;
	memset(pagebuff,0,512);
    // read a page to buffer
    while(len<ARDUINO_PAGE_SIZE){
        char * t = pagebuff+len;
        //QByteArray b = hex.at(hexptr).toLatin1().data();
        const char * b = [[[hex objectAtIndex:hexptr] dataUsingEncoding:NSUTF8StringEncoding] bytes];
        if(b[8]=='1'){
			hexptr=(int)hex.count; // the final code line
            break;
        }
        len+=parseHexLine(&addr,t,b);
        hexptr++;
    }
    [[self updateProgressbar]setProgress:(float)hexptr/hex.count];
    pagelen = len;
	pageptr+=len;
    [self sendPageLeonardo:pagelen];
}

-(void)sendQuery:(int)query
{
    char c[3]={STK_GET_PARAMETER,query,CRC_EOP};
    NSData *data = [NSData dataWithBytes:(const void *)c length:3];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
    prevCmd = STK_GET_PARAMETER;
    prevCmdSub = query;
}

-(void)sendAddr0_Leonardo
{
    char c[3]={CAT_SETADDR,0,0};
    NSData *data = [NSData dataWithBytes:(const void *)c length:3];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
    prevCmd = CAT_SETADDR;
}

-(void)sendAddr:(int)addr
{
    u_char addrl = addr & 0xff;
    u_char addrh = (addr>>8) & 0xff;
    char c[4]={STK_LOAD_ADDRESS,addrl,addrh,CRC_EOP};
    NSData *data = [NSData dataWithBytes:(const void *)c length:4];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
    prevCmd = STK_LOAD_ADDRESS;
}

-(void)sendQuit
{
    char c[2]={STK_LEAVE_PROGMODE,CRC_EOP};
    NSData *data = [NSData dataWithBytes:(const void *)c length:2];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
    prevCmd = STK_LEAVE_PROGMODE;
}

-(void)sendQuitLeonardo
{
    char c[1]={CAT_QUIT};
    NSData *data = [NSData dataWithBytes:(const void *)c length:1];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
    prevCmd = CAT_QUIT;
}

-(void)bleReceivedData:(NSData*)data
{
    [self parseCmd:data];
}

-(void)startProbeTimer
{
    [MWUserManager sharedManager].isUpdating = NO;
    [[self updateStatus]setText:NSLocalizedString(@"Please Reset Arduino",nil)];
    state = ST_PROBING;
    [[BLECentralManager sharedManager].activePeripheral resetIO];
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(sendProbe) userInfo:nil repeats:YES];
}

-(void)sendProbe
{
//    [[BLECentralManager sharedManager].activePeripheral resetIO];

//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        char c[2] = {STK_GET_SYNC,CRC_EOP};
        NSData *data = [NSData dataWithBytes:(const void *)c length:2];
        [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
                 
        prevCmd = STK_GET_SYNC;
//    });

}

int atoh(char *p)
{
    int ret=0;
    char h = p[0];
    char l = p[1];
    if ( h >= '0' && h <= '9' ) h -= 48;
    else if ( h >= 'A' && h <= 'Z' ) h -= 55;
    else return -1;
    
    if ( l >= '0' && l <= '9' ) l -= 48;
    else if ( l >= 'A' && l <= 'Z' ) l -= 55;
    else return -1;
    
    ret = (h<<4)+l;
    return ret;
}

int parseHexLine(unsigned int * addr, char * code, const char * input)
{
    char tmp;
    int i,len,type;
    char * t = (char *)input;
    if(*t++!=':') return -1;
    len = atoh(t);t+=2;
    *addr = atoh(t);t+=2;
    *addr += (atoh(t)*256);t+=2;
    type = atoh(t);t+=2;
    for(i=0;i<len;i++){
        tmp = atoh(t);t+=2;
        code[i] = tmp;
    }
    return len;
}

@end
