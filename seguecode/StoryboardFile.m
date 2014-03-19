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
    
    [self enumerateViewControllerDefinitionsByStoryboardID:^(ViewControllerDefinition *definition) {
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
        [self enumerateViewControllerClassNames:^(NSString *className, NSArray *definitions) {
            NSDictionary *templateMap = [self templateMapForViewController:className];
            NSString *fileName = [StoryboardFile separateViewControllerFileName:className withCategory:self.categoryName];
            
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
    
    [self enumerateViewControllerClassNames:^(NSString *className, NSArray *definitions) {
        [result appendString:[self segueConstantDeclarationsForViewControllerClassName:className] joinedWith:@"\n"];
    }];
    
    return result;
}

- (NSString *)segueConstantDeclarationsForViewControllerClassName:(NSString *)className
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition) {
        NSArray *constantDeclarations = [definition segueConstantDeclarations];
        NSString *constantDeclarationsString = [constantDeclarations componentsJoinedByString:@"\n"];
        
        [result appendString:constantDeclarationsString joinedWith:@"\n"];
    } withClassName:className];
    
    return result;
}

- (NSString *)segueConstantDefinitions
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerClassNames:^(NSString *className, NSArray *definitions) {
        [result appendString:[self segueConstantDefinitionsForViewControllerClassName:className] joinedWith:@"\n"];
    }];
    
    return result;
}

- (NSString *)segueConstantDefinitionsForViewControllerClassName:(NSString *)className
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerDefinitions:^(ViewControllerDefinition *definition) {
        NSArray *constantDeclarations = [definition segueConstantDefinitions];
        NSString *constantDeclarationsString = [constantDeclarations componentsJoinedByString:@"\n"];
        
        [result appendString:constantDeclarationsString joinedWith:@"\n"];
    } withClassName:className];
    
    return result;
}

- (NSString *)controllerCategoryDeclarations
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerClassNames:^(NSString *className, NSArray *definitions) {
        [result appendString:[self controllerCategoryDeclarationsForViewControllerClassName:className] joinedWith:@"\n"];
    }];
    
    return result;
}

- (NSString *)controllerCategoryDeclarationsForViewControllerClassName:(NSString *)className
{
    return [ViewControllerDefinition categoryDeclarations:[self categoryName]
                                    forDefinitions:[self getViewControllersByClassName:className] ];
}

- (NSString *)controllerCategoryDefinitions
{
    __block NSMutableString *result = [NSMutableString string];
    
    [self enumerateViewControllerClassNames:^(NSString *className, NSArray *definitions) {
        [result appendString:[self controllerCategoryDefinitionsForViewControllerClassName:className] joinedWith:@"\n"];
    }];
    
    return result;
}

- (NSString *)controllerCategoryDefinitionsForViewControllerClassName:(NSString *)className
{
    return [ViewControllerDefinition categoryDefinitions:[self categoryName]
                                          forDefinitions:[self getViewControllersByClassName:className] ];
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

- (void)enumerateViewControllerClassNames:(void (^)(NSString *className, NSArray *definitions))block
{
    if (block)
    {
        for (id classNameID in [_viewControllersByClassName allKeys] )
        {
            if ( [classNameID isKindOfClass:[NSString class] ] )
            {
                NSString *className = classNameID;
                NSArray *definitions = [self getViewControllersByClassName:className];
                
                block(className, definitions);
            }
        }
    }
}

+ (void)enumerateViewControllerDefinitions:(NSArray *)definitions withBlock:(void (^)(ViewControllerDefinition *definition))block
{
    [definitions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *definition = obj;
            block(definition);
        }
    }];
}

- (void)enumerateViewControllerDefinitions:(void (^)(ViewControllerDefinition *definition))block withClassName:(NSString *)className
{
    if (block)
    {
        NSArray *definitions = [self getViewControllersByClassName:className];
        [StoryboardFile enumerateViewControllerDefinitions:definitions withBlock:block];
    }
}

- (void)enumerateViewControllerDefinitionsByClassName:(void (^)(ViewControllerDefinition *definition))block
{
    if (block)
    {
        [self enumerateViewControllerClassNames:^(NSString *enumeratedClassName, NSArray *definitions) {
            [StoryboardFile enumerateViewControllerDefinitions:definitions withBlock:block];
        }];
    }
}

- (void)enumerateViewControllerDefinitionsByStoryboardID:(void (^)(ViewControllerDefinition *definition))block
{
    if (block)
    {
        for (id object in [_viewControllersByStoryboardID allValues] )
        {
            if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
            {
                ViewControllerDefinition *definition = object;
                
                block(definition);
            }
        }
    }
}

- (NSDictionary *)templateMap
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [result setObjectNilSafe:self.name forKey:FileNameKey];
    [result setObjectNilSafe:self.name forKey:StoryboardNameKey];
    
    [StoryboardFile addTo:result asTemplateSection:[self segueConstantDeclarations] forKey:SegueConstantDeclarationsKey];
    [StoryboardFile addTo:result asTemplateSection:[self segueConstantDefinitions] forKey:SegueConstantDefinitionsKey];

    [StoryboardFile addTo:result asTemplateSection:[self controllerCategoryDeclarations] forKey:ControllerCategoryDeclarationsKey];
    [StoryboardFile addTo:result asTemplateSection:[self controllerCategoryDefinitions] forKey:ControllerCategoryDefinitionsKey];
    
    return result;
}

- (NSDictionary *)templateMapForViewController:(NSString *)viewControllerName
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSString *fileName = [StoryboardFile separateViewControllerFileName:viewControllerName withCategory:self.categoryName];
    
    [result setObjectNilSafe:fileName forKey:FileNameKey];
    [result setObjectNilSafe:self.name forKey:StoryboardNameKey];
    
    [StoryboardFile addTo:result asTemplateSection:[self segueConstantDeclarationsForViewControllerClassName:viewControllerName] forKey:SegueConstantDeclarationsKey];
    [StoryboardFile addTo:result asTemplateSection:[self segueConstantDefinitionsForViewControllerClassName:viewControllerName] forKey:SegueConstantDefinitionsKey];

    [StoryboardFile addTo:result asTemplateSection:[self controllerCategoryDeclarationsForViewControllerClassName:viewControllerName] forKey:ControllerCategoryDeclarationsKey];
    [StoryboardFile addTo:result asTemplateSection:[self controllerCategoryDefinitionsForViewControllerClassName:viewControllerName] forKey:ControllerCategoryDefinitionsKey];
  
    return result;
}

+ (void)addTo:(NSMutableDictionary *)templateMap asTemplateSection:(NSString *)section forKey:(NSString *)key
{
    [templateMap setObject:[StoryboardFile prepareTemplateSectionFromString:section] forKey:key];
}

@end
