//
//  StoryboardFile.m
//  seguecode
//
//  Created by Ian on 12/10/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "StoryboardFile.h"

#import <RaptureXML/RXMLElement.h>

#import "ViewControllerDefinition.h"
#import "SegueDefinition.h"

@implementation StoryboardFile

- (instancetype)initWithXMLRoot:(RXMLElement *)root
{
    NSString *version = [StoryboardFile getValidStoryboardVersion:root];
    if ( [version isEqualToString:@"3.0"] ) // currently only supported version
    {
        self = [self init];
        [self parseDocument:root];
    } else
    {
        NSLog(@"seguecode does not support storyboards of version %@", version);
        self = nil;
    }
    
    return self;
}

- (instancetype)initWithPathFileName:(NSString *)pathFileName
{
    if ( [ [NSFileManager defaultManager] fileExistsAtPath:pathFileName] )
    {
        RXMLElement *rootXML = [ [RXMLElement alloc] initFromXMLFilePath:pathFileName];

        self = [self initWithXMLRoot:rootXML];
    } else
    {
        NSLog(@"Unable to find storyboard file %@", pathFileName);
        self = nil;
    }
    return self;
}

+ (instancetype)storyboardFileAtPathFileName:(NSString *)pathFileName
{
    return [ [StoryboardFile alloc] initWithPathFileName:pathFileName];
}

+ (NSString *)getValidStoryboardVersion:(RXMLElement *)root
{
    NSString *result;
    
    if ( [root.tag isEqualToString:@"document"] &&
        [ [root attribute:@"type"] isEqualToString:@"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"] )
    {
        result = [root attribute:@"version"];
    }
    
    return result;
}

- (void)parseDocument:(RXMLElement *)root
{
/*    [root iterateWithRootXPath:@"/scenes/scene" usingBlock:^(RXMLElement *scene)
    {
        [self parseScene:scene];
    }];*/
    
    __block NSMutableDictionary *viewControllers = [NSMutableDictionary dictionary];
    
    [root iterateWithRootXPath:@"/document/scenes/scene/objects/viewController" usingBlock:^(RXMLElement *viewController)
    {
        ViewControllerDefinition *definition = [ViewControllerDefinition definitionFrom:viewController];
        if (definition)
        {
            [viewControllers setObject:definition forKey:definition.id];
        }
    }];
    
    for (id object in [viewControllers allValues] )
    {
        if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *vcDefinition = (ViewControllerDefinition *)object;
            for (id segueObject in [ [vcDefinition segues] allValues] )
            {
                if ( [segueObject isKindOfClass:[SegueDefinition class] ] )
                {
                    SegueDefinition *segueDefinition = (SegueDefinition *)segueObject;
                    [segueDefinition setupDestinationFrom:viewControllers];
                }
            }
        }
    }
}

@end
