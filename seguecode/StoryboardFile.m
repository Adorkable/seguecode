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

#define FileNameKey @"FileName"

#define StoryboardNameKey @"StoryboardName"
#define SegueConstantDeclarationsKey @"SegueConstantDeclarations"
#define SegueConstantDefinitionsKey @"SegueConstantDefinitions"

#define ControllerCategoryDeclarationsKey @"ControllerCategoryDeclarations"
#define ControllerCategoryDefinitionsKey @"ControllerCategoryDefinitions"

@interface StoryboardFile ()
{
    NSMutableDictionary *_viewControllersByStoryboardID;
    NSMutableDictionary *_viewControllersByClassName;
}

@end

@implementation StoryboardFile
    
@synthesize viewControllersByStoryboardID = _viewControllersByStoryboardID;
@synthesize viewControllersByClassName = _viewControllersByClassName;

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

+ (NSString *)separateViewControllerFileName:(NSString *)viewControllerName withCategory:(NSString *)category
{
    return [NSString stringWithFormat:@"%@+%@", viewControllerName, category];
}

- (NSString *)categoryName
{
    return self.name;
}

- (void)parseDocument:(RXMLElement *)root
{
    _viewControllersByStoryboardID = [NSMutableDictionary dictionary];
    _viewControllersByClassName = [NSMutableDictionary dictionary];
    
    [root iterateWithRootXPath:@"/document/scenes/scene/objects/viewController" usingBlock:^(RXMLElement *viewController)
    {
        ViewControllerDefinition *definition = [ViewControllerDefinition definitionFrom:viewController];
        if (definition)
        {
            [_viewControllersByStoryboardID setObject:definition forKey:definition.viewControllerID];
            [self addViewControllerByClassName:definition];
        }
    }];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition, BOOL *stop) {
        for (id segueObject in [ [definition segues] allValues] )
        {
            if ( [segueObject isKindOfClass:[SegueDefinition class] ] )
            {
                SegueDefinition *segueDefinition = (SegueDefinition *)segueObject;
                [segueDefinition setupDestinationFrom:_viewControllersByStoryboardID];
            }
        }
    }];
}

- (void)addViewControllerByClassName:(ViewControllerDefinition *)definition
{
    if (definition)
    {
        if (!_viewControllersByClassName)
        {
            _viewControllersByClassName = [NSMutableDictionary dictionary];
        }
        
        NSMutableArray *definitions = [_viewControllersByClassName objectForKey:definition.customOrDefaultClass];
        if (!definitions)
        {
            definitions = [NSMutableArray array];
            [_viewControllersByClassName setObject:definitions forKey:definition.customOrDefaultClass];
        }
        
        [definitions addObject:definition];
    }
}

- (NSArray *)getViewControllersByClassName:(NSString *)className
{
    NSArray *result;
    
    id object = [_viewControllersByClassName objectForKey:className];
    if ( [object isKindOfClass:[NSArray class] ] )
    {
        result = object;
    }
    
    return result;
}

- (void)exportTo:(NSString *)outputPath
withTemplateHeader:(NSString *)templateHeader
       andSource:(NSString *)templateSource
{
    if (self.exportViewControllersSeparately)
    {
        [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition, BOOL *stop) {
            NSDictionary *templateMap = [self templateMapForViewController:definition.viewControllerID];
            NSString *fileName = [StoryboardFile separateViewControllerFileName:definition.customOrDefaultClass withCategory:self.categoryName];
            
            [StoryboardFile exportTo:outputPath
                  withTemplateHeader:templateHeader
                   andTemplateSource:templateSource
                      andTemplateMap:templateMap
                         andFileName:fileName];
        }];
    } else
    {
        NSDictionary *templateMap = [self templateMap];
        
        [StoryboardFile exportTo:outputPath
              withTemplateHeader:templateHeader
               andTemplateSource:templateSource
                  andTemplateMap:templateMap
                     andFileName:self.name];
    }
    
    NSLog(@"Exported files for %@ to %@", self.name, outputPath);
}

+ (void)exportTo:(NSString *)outputPath
withTemplateHeader:(NSString *)templateHeader
andTemplateSource:(NSString *)templateSource
  andTemplateMap:(NSDictionary *)templateMap
     andFileName:(NSString *)fileName
{
    NSString *header = [templateHeader segueCodeTemplateFromDict:templateMap];
    NSString *source = [templateSource segueCodeTemplateFromDict:templateMap];
    
    [StoryboardFile exportHeader:header
                       andSource:source
                          toPath:outputPath
                     andFileName:fileName];
}

+ (void)exportHeader:(NSString *)header andSource:(NSString *)source toPath:(NSString *)outputPath andFileName:(NSString *)fileName
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
    
    error = nil;
    NSString *headerPathFileName = [NSString stringWithFormat:@"%@/%@.h", outputPath, fileName];
    [header writeToFile:headerPathFileName
             atomically:NO
               encoding:NSUTF8StringEncoding
                  error:&error];
    if (error)
    {
        NSLog(@"Error when exporting header %@: %@", fileName, error);
    }
    
    error = nil;
    NSString *sourcePathFileName = [NSString stringWithFormat:@"%@/%@.m", outputPath, fileName];
    [source writeToFile:sourcePathFileName
             atomically:NO
               encoding:NSUTF8StringEncoding
                  error:&error];
    if (error)
    {
        NSLog(@"Error when exporting source %@: %@", fileName, error);
    }
}

- (NSString *)segueConstantDeclarations
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition, BOOL *stop) {
        NSArray *constantDeclarations = [definition segueConstantDeclarations];
        NSString *constantDeclarationsString = [constantDeclarations componentsJoinedByString:@"\n"];
        
        [result appendString:constantDeclarationsString joinedWith:@"\n"];
    }];
    
    return result;
}
    
- (NSString *)segueConstantDefinitions
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition, BOOL *stop) {
        NSArray *constantDefinitions = [definition segueConstantDefinitions];
        NSString *constantDefinitionsString = [constantDefinitions componentsJoinedByString:@"\n"];
        
        [result appendString:constantDefinitionsString joinedWith:@"\n"];
    }];
    
    return result;
}

- (NSString *)controllerCategoryDeclarations
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition, BOOL *stop) {
        [result appendString:[definition categoryDeclarations:self.name] joinedWith:@"\n\n"];
    }];
    
    return result;
}

- (NSString *)controllerCategoryDefinitions
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition, BOOL *stop) {
        [result appendString:[definition categoryDefinitions:self.name] joinedWith:@"\n\n"];
    }];
    
    return result;
}

+ (NSString *)prepareTemplateSectionFromString:(NSString *)templateSection
{
    NSMutableString *result = [templateSection mutableCopy];
    
    if ( [result length] > 0)
    {
        if ( [result characterAtIndex:0] != '\n')
        {
            [result insertString:@"\n" atIndex:0];
        }
        if ( [result characterAtIndex:[result length] - 1] != '\n')
        {
            [result appendString:@"\n"];
        }
    }
    
    return result;
}

+ (NSString *)prepareTemplateSectionFromArray:(NSArray *)templateSection
{
    NSString *fromString = [templateSection componentsJoinedByString:@"\n"];
    return [self prepareTemplateSectionFromString:fromString];
}

- (void)enumerateViewControllerClassNames:(void (^)(NSString *className, NSArray *definitions, BOOL *stop))block
{
    if (block)
    {
        for (id classNameID in [_viewControllersByClassName allKeys] )
        {
            if ( [classNameID isKindOfClass:[NSString class] ] )
            {
                NSString *className = classNameID;
                NSArray *definitions = [self getViewControllersByClassName:className];
                
                BOOL stop = NO;
                block(className, definitions, &stop);
                
                if (stop)
                {
                    break;
                }
            }
        }
    }
}

- (void)enumerateViewControllerDefinitions:(void (^)(ViewControllerDefinition *definition, BOOL *stop))block
{
    if (block)
    {
        for (id object in [_viewControllersByStoryboardID allValues] )
        {
            if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
            {
                ViewControllerDefinition *definition = object;
                
                BOOL stop = NO;
                block(definition, &stop);
                
                if (stop)
                {
                    break;
                }
            }
        }
    }
}

- (NSDictionary *)templateMap
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [result setObjectNilSafe:self.name forKey:FileNameKey];
    [result setObjectNilSafe:self.name forKey:StoryboardNameKey];
    
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromString:self.segueConstantDeclarations] forKey:SegueConstantDeclarationsKey];
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromString:self.segueConstantDefinitions] forKey:SegueConstantDefinitionsKey];
    
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromString:self.controllerCategoryDeclarations] forKey:ControllerCategoryDeclarationsKey];
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromString:self.controllerCategoryDefinitions] forKey:ControllerCategoryDefinitionsKey];
    
    return result;
}

- (NSDictionary *)templateMapForViewController:(NSString *)viewControllerName
{
    ViewControllerDefinition *definition = [self.viewControllersByStoryboardID objectForKey:viewControllerName];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSString *fileName = [StoryboardFile separateViewControllerFileName:definition.customOrDefaultClass withCategory:self.categoryName];
    
    [result setObjectNilSafe:fileName forKey:FileNameKey];
    [result setObjectNilSafe:self.name forKey:StoryboardNameKey];
    
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromArray:definition.segueConstantDeclarations] forKey:SegueConstantDeclarationsKey];
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromArray:definition.segueConstantDefinitions] forKey:SegueConstantDefinitionsKey];
    
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromString:[definition categoryDeclarations:[self categoryName] ] ] forKey:ControllerCategoryDeclarationsKey];
    [result setObjectNilSafe:[StoryboardFile prepareTemplateSectionFromString:[definition categoryDefinitions:[self categoryName] ] ] forKey:ControllerCategoryDefinitionsKey];
    
    return result;
}

@end
