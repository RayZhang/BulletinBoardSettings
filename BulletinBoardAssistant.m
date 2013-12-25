//
//  BulletinBoardAssistant.m
//  qBatteryDoctor
//
//  Created by Ray Zhang on 13-8-27.
//
//

#import "BulletinBoardAssistant.h"

#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBBehaviorOverride.h>
#import <BulletinBoard/BBSettingsGateway.h>

#define SECTION_INFO_FILE_PATH  @"/var/mobile/Library/BulletinBoard/SectionInfo.plist"

#define SECTION_ORDER_FILE_PATH @"/var/mobile/Library/BulletinBoard/SectionOrder.plist"
#define SECTION_ORDER_IDENTIFIERS   @"SectionOrderIDs"
#define SECTION_ORDER_CHRONOLOGICAL_IDENTIFIERS @"BBSectionOrderChronologicalIDs"
#define SECTION_ORDER_DEFAULT_IDENTIFIERS   @"BBSectionOrderDefaultIDs"
#define SECTION_ORDER_RULE  @"SectionOrderRule"

#define BEHAVIOR_OVERRIDES_FILE_PATH    @"/var/mobile/Library/BulletinBoard/BehaviorOverrides.plist"
#define OVERRIDES   @"overrides"
#define OVERRIDE_STATUS  @"overrideStatus"
#define OVERRIDE_STATUS_LAST_CALCULATED_TIME    @"overrideStatusLastCalculatedTime"
#define PRIVILEGED_SENDER_TYPES   @"privilegedSenderTypes"

@implementation BulletinBoardAssistant

+ (BOOL)isWeeAppPluginOnWithSectionIdetifier:(NSString *)identifier {
    BOOL retVal = NO;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:SECTION_INFO_FILE_PATH]) {
        NSDictionary *sectionInfoDic = [[NSDictionary alloc] initWithContentsOfFile:SECTION_INFO_FILE_PATH];
        NSData *sectionInfoData = [sectionInfoDic objectForKey:identifier];
        BBSectionInfo *sectionInfo = [NSKeyedUnarchiver unarchiveObjectWithData:sectionInfoData];
        retVal = sectionInfo.showsInNotificationCenter;
        [sectionInfoDic release];
    }
    return retVal;
}

+ (void)setWeeAppPluginOn:(BOOL)on withSectionIdetifier:(NSString *)identifier {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BBSettingsGateway *settingsGateway = [[BBSettingsGateway alloc] init];
    if ([defaultManager fileExistsAtPath:SECTION_INFO_FILE_PATH]) {
        NSDictionary *sectionInfoDic = [[NSDictionary alloc] initWithContentsOfFile:SECTION_INFO_FILE_PATH];
        NSData *sectionInfoData = [sectionInfoDic objectForKey:identifier];
        BBSectionInfo *sectionInfo = [NSKeyedUnarchiver unarchiveObjectWithData:sectionInfoData];
        sectionInfo.showsInNotificationCenter = on;
        [settingsGateway setSectionInfo:sectionInfo forSectionID:identifier];
        [sectionInfoDic release];
    } else {
        [settingsGateway getSectionInfoWithCompletion:^(NSArray *sectionInfos){
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithCapacity:7];
            for (BBSectionInfo *info in sectionInfos) {
                NSString *key = [[NSString alloc] initWithString:info.sectionID];
                NSData *object = [[NSData alloc] initWithData:[NSKeyedArchiver archivedDataWithRootObject:info]];
                [mutableDic setObject:object forKey:key];
                [key release];
                [object release];
            }
            [mutableDic writeToFile:SECTION_INFO_FILE_PATH atomically:YES];
            
            NSData *sectionInfoData = [mutableDic objectForKey:identifier];
            BBSectionInfo *sectionInfo = [NSKeyedUnarchiver unarchiveObjectWithData:sectionInfoData];
            sectionInfo.showsInNotificationCenter = on;
            [settingsGateway setSectionInfo:sectionInfo forSectionID:identifier];
            [mutableDic release];
        }];
    }
    [settingsGateway release];
}

+ (void)sortWeeAppToPosition:(BBWeeAppPosition)position withSectionIdetifier:(NSString *)identifier {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BBSettingsGateway *settingsGateway = [[BBSettingsGateway alloc] init];
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *arrayIdentifier = SECTION_ORDER_CHRONOLOGICAL_IDENTIFIERS;
    NSUInteger index = 1;
    if (systemVersion < 7.0) {
        arrayIdentifier = SECTION_ORDER_IDENTIFIERS;
        index = 0;
    }
    if ([defaultManager fileExistsAtPath:SECTION_ORDER_FILE_PATH]) {
        NSDictionary *sectionOrderDic = [[NSDictionary alloc] initWithContentsOfFile:SECTION_ORDER_FILE_PATH];
        NSMutableArray *sectionOrders = [[NSMutableArray alloc] initWithArray:[sectionOrderDic objectForKey:arrayIdentifier]];
        [sectionOrders removeObject:identifier];
        switch (position) {
            case BBWeeAppPositionTop:
                [sectionOrders insertObject:identifier atIndex:index];
                break;
            case BBWeeAppPositionBottom:
                [sectionOrders addObject:identifier];
            default:
                break;
        }
        if (systemVersion < 7.0) {
            [settingsGateway setOrderedSectionIDs:sectionOrders];
        } else {
            [settingsGateway setOrderedSectionIDs:sectionOrders forCategory:index];
        }
        [sectionOrderDic release];
        [sectionOrders release];
    } else {
        if (systemVersion < 7.0) {
            [settingsGateway getSectionInfoWithCompletion:^(NSArray *sectionInfos) {
                NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:[sectionInfos count]];
                for (BBSectionInfo *info in sectionInfos) {
                    NSString *key = [[NSString alloc] initWithString:info.sectionID];
                    [mutableArray addObject:key];
                    [key release];
                }
                NSDictionary *sectionOrderDic = [[NSDictionary alloc] initWithObjectsAndKeys:mutableArray, arrayIdentifier, [NSNumber numberWithInteger:0], SECTION_ORDER_RULE, nil];
                [sectionOrderDic writeToFile:SECTION_ORDER_FILE_PATH atomically:YES];
                [mutableArray removeObject:identifier];
                switch (position) {
                    case BBWeeAppPositionTop:
                        [mutableArray insertObject:identifier atIndex:index];
                        break;
                    case BBWeeAppPositionBottom:
                        [mutableArray addObject:identifier];
                    default:
                        break;
                }
                [settingsGateway setOrderedSectionIDs:mutableArray];
                [mutableArray release];
            }];
        } else {
            [settingsGateway getSectionInfoForCategory:index withCompletion:^(NSArray *sectionInfos) {
                NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:[sectionInfos count]];
                for (BBSectionInfo *info in sectionInfos) {
                    NSString *key = [[NSString alloc] initWithString:info.sectionID];
                    [mutableArray addObject:key];
                    [key release];
                }
                NSDictionary *sectionOrderDic = [[NSDictionary alloc] initWithObjectsAndKeys:mutableArray, arrayIdentifier, [NSNumber numberWithInteger:0], SECTION_ORDER_RULE, nil];
                [sectionOrderDic writeToFile:SECTION_ORDER_FILE_PATH atomically:YES];
                [mutableArray removeObject:identifier];
                switch (position) {
                    case BBWeeAppPositionTop:
                        [mutableArray insertObject:identifier atIndex:index];
                        break;
                    case BBWeeAppPositionBottom:
                        [mutableArray addObject:identifier];
                    default:
                        break;
                }
                [settingsGateway setOrderedSectionIDs:mutableArray forCategory:index];
                [mutableArray release];
            }];
        }
    }
    [settingsGateway release];
}

+ (BOOL)isDNDEnabled {
    BOOL retVal = NO;
    NSDictionary *behaviorOverrides = [[NSDictionary alloc] initWithContentsOfFile:BEHAVIOR_OVERRIDES_FILE_PATH];
    if (behaviorOverrides) {
        NSData *overrideData = [[NSData alloc] initWithData:[[behaviorOverrides objectForKey:OVERRIDES] lastObject]];
        if (overrideData) {
            BBBehaviorOverride *override = [NSKeyedUnarchiver unarchiveObjectWithData:overrideData];
            if ([override isActiveForDate:[NSDate date]]) {
                retVal = ![[behaviorOverrides objectForKey:OVERRIDE_STATUS] integerValue];
            } else {
                NSInteger status = [[behaviorOverrides objectForKey:OVERRIDE_STATUS] integerValue];
                if (status > 1) {
                    status = 0;
                }
                retVal = status;
            }
            [overrideData release];
        }
        [behaviorOverrides release];
    }
    return retVal;
}

+ (void)setDNDEnabled:(BOOL)enabled {
    BBSettingsGateway *settingsGateway = [[BBSettingsGateway alloc] init];
    [settingsGateway getBehaviorOverridesWithCompletion:^(NSArray *overrides) {
        if (overrides) {
            int status = 0;
            BBBehaviorOverride *override = [overrides lastObject];
            if (enabled) {
                if ([override isActiveForDate:[NSDate date]]) {
                    if (override.mode) {
                        status = 0;
                    } else {
                        status = 1;
                    }
                } else {
                    status = 1;
                }
            } else {
                if ([override isActiveForDate:[NSDate date]]) {
                    if (override.mode) {
                        status = 2;
                    } else {
                        status = 0;
                    }
                } else {
                    status = 0;
                }
            }
            [settingsGateway setBehaviorOverrideStatus:status];
        }
        [settingsGateway release];
    }];
}

@end
