//
//  ViewControllerDefinition.h
//  seguecode
//
//  Created by Ian on 12/10/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RXMLElement;

@interface ViewControllerDefinition : NSObject

+ (instancetype)definitionFrom:(RXMLElement *)definitionElement;

@property (readonly) NSString *viewControllerID;
@property (readonly) NSString *storyboardIdentifier;
@property (readonly) NSString *customClass;
@property (readonly) NSString *customOrDefaultClass;

@property (readonly) NSString *sceneMemberID;

@property (readonly) NSDictionary *segues;

- (NSArray *)segueConstantDeclarations;
- (NSArray *)segueConstantDefinitions;

- (NSString *)categoryDeclarations:(NSString *)categoryName;
- (NSString *)categoryDefinitions:(NSString *)categoryName;

@end
