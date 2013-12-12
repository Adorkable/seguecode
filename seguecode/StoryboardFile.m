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

#import "Utility.h"

@interface StoryboardFile ()
{
    NSMutableDictionary *_viewControllers;
}

@end

@implementation StoryboardFile
    
    @synthesize viewControllers = _viewControllers;

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
        if (self)
        {
            self.name = [ [pathFileName lastPathComponent] stringByDeletingPathExtension];
            NSLog(@"Loaded Storyboard with name %@", self.name);
        }
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
    
    _viewControllers = [NSMutableDictionary dictionary];
    
    [root iterateWithRootXPath:@"/document/scenes/scene/objects/viewController" usingBlock:^(RXMLElement *viewController)
    {
        ViewControllerDefinition *definition = [ViewControllerDefinition definitionFrom:viewController];
        if (definition)
        {
            [_viewControllers setObject:definition forKey:definition.id];
        }
    }];
    
    for (id object in [_viewControllers allValues] )
    {
        if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *vcDefinition = (ViewControllerDefinition *)object;
            for (id segueObject in [ [vcDefinition segues] allValues] )
            {
                if ( [segueObject isKindOfClass:[SegueDefinition class] ] )
                {
                    SegueDefinition *segueDefinition = (SegueDefinition *)segueObject;
                    [segueDefinition setupDestinationFrom:_viewControllers];
                }
            }
        }
    }
}
    
- (void)exportTo:(NSString *)outputPath
withTemplateHeader:(NSString *)templateHeader
       andSource:(NSString *)templateSource
{
    NSError *error;
    [ [NSFileManager defaultManager] createDirectoryAtPath:outputPath
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:&error];
    if (error)
    {
        NSLog(@"Error when trying to create output directory %@: %@", outputPath, error);
    //    result = NO;
    }
    
    NSDictionary *templateMap = [self templateMap];
    NSString *header = [templateHeader segueCodeTemplateFromDict:templateMap];
    NSString *source = [templateSource segueCodeTemplateFromDict:templateMap];
    
    NSString *headerPathFileName = [NSString stringWithFormat:@"%@/%@.h", outputPath, self.name];
    [header writeToFile:headerPathFileName
             atomically:NO
               encoding:NSUTF8StringEncoding
                  error:&error];
    if (error)
    {
        NSLog(@"Error when exporting header for %@: %@", self.name, error);
    }
    
    NSString *sourcePathFileName = [NSString stringWithFormat:@"%@/%@.m", outputPath, self.name];
    [source writeToFile:sourcePathFileName
             atomically:NO
               encoding:NSUTF8StringEncoding
                  error:&error];
    if (error)
    {
        NSLog(@"Error when exporting source for %@: %@", self.name, error);
    }
    NSLog(@"Exported files for %@ to %@", self.name, outputPath);
}
    
- (NSString *)segueConstantDeclarations
{
    NSMutableString *result = [NSMutableString string];
    
    for (id object in [_viewControllers allValues] )
    {
        if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *vcDefinition = (ViewControllerDefinition *)object;
            NSArray *constantDeclarations = [vcDefinition segueConstantDeclarations];
            NSString *constantDeclarationsString = [constantDeclarations componentsJoinedByString:@"\n"];
            if ( [result length] == 0)
            {
                [result appendString:constantDeclarationsString];
            } else
            {
                [result appendFormat:@"\n%@", constantDeclarationsString];
            }
        }
    }
    
    return result;
}
    
- (NSString *)segueConstantDefinitions
{
    NSMutableString *result = [NSMutableString string];
    
    for (id object in [_viewControllers allValues] )
    {
        if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *vcDefinition = (ViewControllerDefinition *)object;
            NSArray *constantDefinitions = [vcDefinition segueConstantDefinitions];
            NSString *constantDefinitionsString = [constantDefinitions componentsJoinedByString:@"\n"];
            if ( [result length] == 0)
            {
                [result appendString:constantDefinitionsString];
            } else
            {
                [result appendFormat:@"\n%@", constantDefinitionsString];
            }
        }
    }
    
    return result;
}
    
- (NSDictionary *)templateMap
{
    return @{
             @"StoryboardName" : self.name,
             @"SegueConstantDeclarations" : self.segueConstantDeclarations,
             @"SegueConstantDefinitions" : self.segueConstantDefinitions
             };
}

@end
