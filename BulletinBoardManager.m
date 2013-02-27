//
//  BulletinBoardManager.m
//  Entitlements
//
//  Created by Ray Zhang on 13-2-26.
//  Copyright (c) 2013年 Ray Zhang. All rights reserved.
//

#import "BulletinBoardManager.h"

#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBSettingsGateway.h>

#define SECTION_INFO_IDENTIFIER_KEY @"_sectionInfoByID"

static BulletinBoardManager *manager = nil;

@implementation BulletinBoardManager

+ (id)sharedManager {
    @synchronized(self) {
        if (manager == nil) {
            manager = [[super alloc] init];
        }
    }
    return manager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (manager == nil) {
            manager = [super allocWithZone:zone];
            return manager;
        }
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (id)retain {
    return self;
}

- (oneway void)release {
    return;
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

#pragma mark - protocol NSCopying
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWeeAppPluginOnWithSectionIdetifier:(NSString *)identifier {
    BOOL retVal = NO;
    BBServer *server = [[BBServer alloc] init];
    [server _loadSavedSectionInfo];
    
    NSMutableDictionary *sectionInfoByID = [server valueForKey:SECTION_INFO_IDENTIFIER_KEY];
    BBSectionInfo *sectionInfo = [sectionInfoByID objectForKey:identifier];
    if (sectionInfo) {
        retVal = sectionInfo.showsInNotificationCenter;
    }
    [server release];
    return retVal;
}

- (void)setWeeAppPluginOn:(BOOL)on withSectionIdetifier:(NSString *)identifier {
    BBServer *server = [[BBServer alloc] init];
    [server _loadSavedSectionInfo];
    
    NSDictionary *sectionInfoByID = [server valueForKey:SECTION_INFO_IDENTIFIER_KEY];
    BBSectionInfo *bsSectionInfo = [sectionInfoByID objectForKey:identifier];
    if (bsSectionInfo == nil) {
        [server _loadAllWeeAppSections];
        bsSectionInfo = [server _sectionInfoForSectionID:identifier effective:YES];
    }

    if (bsSectionInfo) {
        bsSectionInfo.showsInNotificationCenter = on;
        BBSettingsGateway *gateway = [[BBSettingsGateway alloc] init];
        [gateway setSectionInfo:bsSectionInfo forSectionID:bsSectionInfo.sectionID];
        [gateway release];
    }
    
    [server release];
}

- (void)sortWeeAppToTopWithIdentifier:(NSString *)identifier {
    BBServer *server = [[BBServer alloc] init];
    
    NSMutableArray *savedSectionOrder = nil;
    [server _readSavedSectionOrder:&savedSectionOrder andRule:0];
    
    if ([savedSectionOrder containsObject:identifier]) {
        [savedSectionOrder removeObject:identifier];
    }
    
    [savedSectionOrder insertObject:identifier atIndex:0];
    
    if (savedSectionOrder) {
        BBSettingsGateway *gateway = [[BBSettingsGateway alloc] init];
        [gateway setOrderedSectionIDs:savedSectionOrder];
        [gateway release];
    }
    
    [server release];
}

- (void)sortWeeAppToBottomWithIdentifier:(NSString *)identifier {
    BBServer *server = [[BBServer alloc] init];
    
    NSMutableArray *savedSectionOrder = nil;
    [server _readSavedSectionOrder:&savedSectionOrder andRule:0];
    
    if ([savedSectionOrder containsObject:identifier]) {
        [savedSectionOrder removeObject:identifier];
    }
    
    [savedSectionOrder addObject:identifier];
    
    if (savedSectionOrder) {
        BBSettingsGateway *gateway = [[BBSettingsGateway alloc] init];
        [gateway setOrderedSectionIDs:savedSectionOrder];
        [gateway release];
    }
    
    [server release];
}

@end
