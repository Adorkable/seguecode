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

#import "NSMutableDictionary+RunConfig.h"

static seguecodePlugin *sharedPlugin;

@interface seguecodePlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (copy) NSString *currentlyEditingStoryboardFileName;

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

            [self setupMenu];
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
        NSString *next = [nextURL description];
        NSRange begin = [next rangeOfString:@"file://"];
        
        if (begin.location != NSNotFound)
        {
            NSString *fullPath = [next substringFromIndex:begin.location + begin.length];
            if ( [[fullPath pathExtension] isEqualToString:@"storyboard"] )
            {
                self.currentlyEditingStoryboardFileName = fullPath;
            } else
            {
                self.currentlyEditingStoryboardFileName = nil;
                NSLog(@"Ignoring %@", [fullPath pathExtension] );
            }
        } else
        {
            NSLog(@"Unable to find file:// in %@", next);
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
            NSMutableDictionary *runConfig = [NSMutableDictionary runConfigForStoryboardAtPath:self.currentlyEditingStoryboardFileName];
            
            if (runConfig)
            {
                NSLog(@"Applying to %@", self.currentlyEditingStoryboardFileName);
                [self applyToStoryboardAtPath:self.currentlyEditingStoryboardFileName
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

- (BOOL)createDefaultRunConfigForStoryboardAtPath:(NSString *)storyboardPath
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result.exportConstants = NO;
    result.squashVCS = NO;
    result.outputDirectory = [NSString stringWithFormat:@"./Generated"];
    return [result writeRunConfigForStoryboardAtPath:storyboardPath];
}

- (BOOL)applyToStoryboardAtPath:(NSString *)storyboardPath withRunConfig:(NSMutableDictionary *)runConfig
{
    NSPipe *pipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [ [self pathToSegueCode] path];

    NSString *outputFolder = [NSString stringWithFormat:@"%@/%@", [storyboardPath stringByDeletingLastPathComponent], runConfig.outputDirectory];
    
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObjectsFromArray:@[@"--output-dir", outputFolder] ];
    if (runConfig.squashVCS)
    {
        [arguments addObject:@"--squash-vcs"];
    }
    if (runConfig.exportConstants)
    {
        [arguments addObject:@"--export-constants"];
    }
    [arguments addObject:storyboardPath];
    task.arguments = arguments;
    
    task.currentDirectoryPath = [storyboardPath stringByDeletingLastPathComponent];
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
    return [self.bundle URLForResource:@"seguecode"
                         withExtension:nil];
}

- (void)setupMenu
{
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem)
    {
        [ [editMenuItem submenu] addItem:[NSMenuItem separatorItem] ];
        
        NSMenuItem *storyboardEnabled = [ [NSMenuItem alloc] initWithTitle:@"Enable seguecode"
                                                                    action:@selector(enableSeguecode:)
                                                             keyEquivalent:@""];
        [storyboardEnabled setTarget:self];
        [ [editMenuItem submenu] addItem:storyboardEnabled];
        self.storyboardEnabled = storyboardEnabled;
    } else
    {
        NSLog(@"Unable to find Edit menu, cannot add menu items");
    }
}

- (void)enableSeguecode:(id)sender
{
    if (self.currentlyEditingStoryboardFileName)
    {
        [self createDefaultRunConfigForStoryboardAtPath:self.currentlyEditingStoryboardFileName];

        [self updateStoryboardEnabled];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL result = YES;
    if (menuItem == self.storyboardEnabled)
    {
        result = self.currentlyEditingStoryboardFileName != nil && [NSMutableDictionary runConfigForStoryboardAtPath:self.currentlyEditingStoryboardFileName] == nil;
    }
    return result;
}

- (void)updateStoryboardEnabled
{
    if (self.currentlyEditingStoryboardFileName)
    {
        if ( [NSMutableDictionary runConfigForStoryboardAtPath:self.currentlyEditingStoryboardFileName] )
        {
            [self.storyboardEnabled setEnabled:NO];
            [self.storyboardEnabled setState:NSOnState];
        } else
        {
            [self.storyboardEnabled setEnabled:YES];
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
