//
//  NSNotification+Utility.h
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotification (Utility)

- (BOOL)isXcodeEvent;

+ (NSString *)transitionFromOneFileToAnotherName;
- (BOOL)isTransitionFromOneFileToAnother;
- (NSURL *)transitionFromOneFileToAnotherNextDocumentURL;

+ (NSString *)ideEditorDocumentDidSaveName;
- (BOOL)isIDEEditorDocumentDidSave;

@end
