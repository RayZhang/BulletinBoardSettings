//
//  BulletinBoardAssistant.h
//  qBatteryDoctor
//
//  Created by Ray Zhang on 13-8-27.
//
//

#import <Foundation/Foundation.h>

#define BATTERY_IDETIFIER @"net.qihoo.BatteryView"

typedef enum {
    BBWeeAppPositionTop = 0,
    BBWeeAppPositionBottom
} BBWeeAppPosition;

@interface BulletinBoardAssistant : NSObject

+ (BOOL)isWeeAppPluginOnWithSectionIdetifier:(NSString *)identifier;
+ (void)setWeeAppPluginOn:(BOOL)on withSectionIdetifier:(NSString *)identifier;

+ (void)sortWeeAppToPosition:(BBWeeAppPosition)position withSectionIdetifier:(NSString *)identifier;

+ (BOOL)isDNDEnabled;
+ (void)setDNDEnabled:(BOOL)enabled;

@end
