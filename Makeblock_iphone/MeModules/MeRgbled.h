//
//  MeRgbled.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModule.h"

@interface MeRgbled : MeModule
@property (weak, nonatomic) IBOutlet UISlider *redSlide;
@property (weak, nonatomic) IBOutlet UISlider *greenSlide;
@property (weak, nonatomic) IBOutlet UISlider *blueSlide;
- (IBAction)rgbValueChanged:(id)sender;


@end
