//
//  seguecodePlugin.m
//  seguecodePlugin
//
//  Created by Ian on 11/4/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "seguecodePlugin.h"

#import "NSObject+Utility.h"
#import "NSNotification+Utility.h"
#import "NSURL+Utility.h"

#import "NSMutableDictionary+RunConfig.h"

static seguecodePlugin *sharedPlugin;

@interface seguecodePlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (copy) NSURL *currentlyEditingStoryboardFileName;

@property (weak, readwrite) NSMenuItem *storyboardEnabled;

@end

@implementation seguecodePlugin

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init] )
    {
        self.bundle = plugin;
        
        if ( [self pathToSegueCode] )
        {
            NSLog(@"seguecode found at %@", [self pathToSegueCode] );
            
            [self setupNotifications];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self setupMenu];
            }];
        } else
        {
            NSLog(@"seguecode not found!");
        }
    }
    return self;
}

- (void)setupNotifications
{
    [ [NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(transitionFromOneFileToAnother:)
                                                  name:[NSNotification transitionFromOneFileToAnotherName]
                                                object:nil];
    [ [NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(ideEditorDocumentDidSave:)
                                                  name:[NSNotification ideEditorDocumentDidSaveName]
                                                object:nil];
/*
    [ [NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(logNotification:)
                                                  name:nil
                                                object:nil];
*/
}

- (void)transitionFromOneFileToAnother:(NSNotification *)notification
{
    if ( [notification isTransitionFromOneFileToAnother] )
    {
        NSURL *nextURL = [notification transitionFromOneFileToAnotherNextDocumentURL];
        NSRange begin = [nextURL rangeOfString:@"file://"];
        
        if (begin.location != NSNotFound && begin.length > 0)
        {
            if ( [ [nextURL pathExtension] isEqualToString:@"storyboard"] )
            {
                self.currentlyEditingStoryboardFileName = nextURL;
            } else
            {
                self.currentlyEditingStoryboardFileName = nil;
                NSLog(@"Ignoring %@", [nextURL pathExtension] );
            }
        } else
        {
            NSLog(@"Unable to find file:// in %@", nextURL);
            self.currentlyEditingStoryboardFileName = nil;
        }
        
        [self updateStoryboardEnabled];
    } else
    {
        NSLog(@"Unexpected notification %@ sent to %@",
              notification,
              NSStringFromSelector(@selector(transitionFromOneFileToAnother:) )
              );
    }
}

- (void)ideEditorDocumentDidSave:(NSNotification *)notification
{
    if ( [notification isIDEEditorDocumentDidSave] )
    {
        id notificationObject = [notification object];
        
        Class IBStoryboardDocument = NSClassFromString(@"IBStoryboardDocument");
        if ( [notificationObject isKindOfClass:IBStoryboardDocument] && self.currentlyEditingStoryboardFileName )
        {
            NSMutableDictionary *runConfig = [NSMutableDictionary runConfigForStoryboardAtURL:self.currentlyEditingStoryboardFileName];
            
            if (runConfig)
            {
                NSLog(@"Applying to %@", self.currentlyEditingStoryboardFileName);
                [self applyToStoryboardAtURL:self.currentlyEditingStoryboardFileName
                                withRunConfig:runConfig];
            } else
            {
                NSLog(@"Skipping %@, not configured for usage", self.currentlyEditingStoryboardFileName);
            }
        }
    }
}

-(void)logNotification:(NSNotification *)notification
{
    if ( [notification isXcodeEvent] )
    {
        NSLog(@"Notification: %@ %@", [notification name], [notification object]);
    }
}

- (BOOL)createDefaultRunConfigForStoryboardAtPath:(NSURL *)storyboardURL
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result.combine = NO;
    result.outputPath = [NSString stringWithFormat:@"./Generated"];
    return [result writeRunConfigForStoryboardAtURL:storyboardURL];
}

- (BOOL)applyToStoryboardAtURL:(NSURL *)storyboardURL withRunConfig:(NSMutableDictionary *)runConfig
{
    NSPipe *pipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [ [self pathToSegueCode] path];

    NSString *outputFolder = [NSString stringWithFormat:@"\"%@/%@\"", [ [storyboardURL URLByDeletingLastPathComponent] path], runConfig.outputPath];
    
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObjectsFromArray:@[@"--outputPath", outputFolder] ];
    if (runConfig.combine)
    {
        [arguments addObject:@"--combine"];
    }
    if (runConfig.projectName)
    {
        [arguments addObjectsFromArray:@[@"--projectName", runConfig.projectName] ];
    }
    [arguments addObject:[NSString stringWithFormat:@"\"%@\"", [storyboardURL path] ] ];
    task.arguments = arguments;
    
    task.currentDirectoryPath = [ [storyboardURL URLByDeletingLastPathComponent] path];
    task.standardOutput = pipe;
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [ [pipe fileHandleForReading] availableData];
    NSString *outputResult = [ [NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    if (outputResult.length > 0)
    {
        NSLog(@"seguecode result:\n%@", outputResult);
    }

    return task.terminationStatus != 0;
}

- (NSURL *)pathToSegueCode
{
    return [self.bundle URLForResource:@"seguecode.bundle/Contents/MacOS/seguecode"
                         withExtension:nil];
}

- (NSMenuItem *)xcodeEditMenu
{
    NSMenuItem *result = [ [NSApp mainMenu] itemWithTitle:@"Edit"];
    if (result == nil)
    {
        NSLog(@"Unable to find Edit menu");
    }
    return result;
}

- (void)setupMenu
{
    NSMenuItem *editMenuItem = [self xcodeEditMenu];
    if (editMenuItem)
    {
        [ [editMenuItem submenu] addItem:[NSMenuItem separatorItem] ];
        
        NSMenuItem *storyboardEnabled = [ [NSMenuItem alloc] initWithTitle:@"Enable seguecode"
                                                                    action:@selector(toggleEnabled:)
                                                             keyEquivalent:@""];
        [storyboardEnabled setTarget:self];
        [ [editMenuItem submenu] addItem:storyboardEnabled];
        self.storyboardEnabled = storyboardEnabled;
    } else
    {
        NSLog(@"Cannot add seguecode menu items");
    }
}

- (void)toggleEnabled:(id)sender
{
    if (self.currentlyEditingStoryboardFileName)
    {
        if (![self enabledForStoryboardAtPath:self.currentlyEditingStoryboardFileName] )
        {
            [self createDefaultRunConfigForStoryboardAtPath:self.currentlyEditingStoryboardFileName];
        } else
        {
            [NSMutableDictionary removeRunConfigForStoryboardAtURL:self.currentlyEditingStoryboardFileName];
        }
        [self updateStoryboardEnabled];
    }
}

- (BOOL)enabledForStoryboardAtPath:(NSURL *)storyboardURL
{
    // TODO: why aren't we using the passed in value?
    return self.currentlyEditingStoryboardFileName && [NSMutableDictionary runConfigForStoryboardAtURL:self.currentlyEditingStoryboardFileName];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL result = YES;
    if (menuItem == self.storyboardEnabled)
    {
        result = self.currentlyEditingStoryboardFileName != nil;
    }
    return result;
}

- (void)updateStoryboardEnabled
{
    if (self.currentlyEditingStoryboardFileName)
    {
        [self.storyboardEnabled setEnabled:YES];
        if ( [self enabledForStoryboardAtPath:self.currentlyEditingStoryboardFileName] )
        {
            [self.storyboardEnabled setState:NSOnState];
        } else
        {
            [self.storyboardEnabled setState:NSOffState];
        }
    } else
    {
        [self.storyboardEnabled setEnabled:NO];
        [self.storyboardEnabled setState:NSOffState];
    }
}



- (void)dealloc
{
    [ [NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
