//
//  BulletinBoardManager.h
//  Entitlements
//
//  Created by Ray Zhang on 13-2-26.
//  Copyright (c) 2013年 Ray Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BulletinBoardManager : NSObject

+ (id)sharedManager;

- (BOOL)isWeeAppPluginOnWithSectionIdetifier:(NSString *)identifier;
- (void)setWeeAppPluginOn:(BOOL)on withSectionIdetifier:(NSString *)identifier;

- (void)sortWeeAppToTopWithIdentifier:(NSString *)identifier;
- (void)sortWeeAppToBottomWithIdentifier:(NSString *)identifier;

@end
