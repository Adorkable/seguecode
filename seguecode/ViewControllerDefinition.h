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

@property (readonly) NSString *id;
@property (readonly) NSString *storyboardIdentifier;
@property (readonly) NSString *customClass;

@property (readonly) NSString *sceneMemberID;

@property (readonly) NSDictionary *segues;

@end
