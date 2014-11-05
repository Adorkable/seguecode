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

static seguecodePlugin *sharedPlugin;

@interface seguecodePlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (copy) NSString *currentlyEditingStoryboardFileName;

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
        
        [self setupNotifications];

        [self setupMenu];
        
        NSLog(@"seguecode found at %@", [self pathToSegueCode] );
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
        }
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
            [self applyToStoryboardAtPath:self.currentlyEditingStoryboardFileName];
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

- (BOOL)applyToStoryboardAtPath:(NSString *)storyboardPath
{
    BOOL result = NO;
    if ( [self pathToSegueCode] )
    {
        NSPipe *pipe = [NSPipe pipe];
        
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = [ [self pathToSegueCode] path];

        NSString *outputFolder = [NSString stringWithFormat:@"%@/../Generated", [storyboardPath stringByDeletingLastPathComponent] ];
        task.arguments = @[@"-o", outputFolder, storyboardPath];
        task.currentDirectoryPath = [storyboardPath stringByDeletingLastPathComponent];
        task.standardOutput = pipe;
        [task launch];
        [task waitUntilExit];
        
        NSData *data = [ [pipe fileHandleForReading] availableData];
        NSLog(@"seguecode result:\n%@", [ [NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
        result = YES;
    } else
    {
        NSLog(@"Unable to find seguecode in bundle, can't run!");
        result = NO;
    }
    return result;
}

- (NSURL *)pathToSegueCode
{
    return [self.bundle URLForResource:@"seguecode"
                         withExtension:nil];
}

- (void)setupMenu
{
    // Create menu items, initialize UI, etc.
    /*
     // Sample Menu Item:
     NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
     if (menuItem) {
     [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
     NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
     [actionMenuItem setTarget:self];
     [[menuItem submenu] addItem:actionMenuItem];
     }*/
}
/*
// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}*/

- (void)dealloc
{
    [ [NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
