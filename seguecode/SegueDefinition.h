//
//  SegueDefinition.h
//  seguecode
//
//  Created by Ian on 12/10/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RXMLElement;

@class ViewControllerDefinition;

@interface SegueDefinition : NSObject

+ (instancetype)definitionFrom:(RXMLElement *)definitionElement andSource:(ViewControllerDefinition *)source;
- (void)setupDestinationFrom:(NSMutableDictionary *)destinationDefinitions;

@property (readonly) NSString *id;
@property (readonly) NSString *identifier;
@property (weak, readonly) ViewControllerDefinition *source;
@property (readonly) NSString *destinationID;
@property (weak, readonly) ViewControllerDefinition *destination;
@property (readonly) NSString *kind;
@property (readonly) NSString *customClass;

@end
