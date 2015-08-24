//
//  seguecodePlugin.h
//  seguecodePlugin
//
//  Created by Ian on 11/4/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface seguecodePlugin : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end