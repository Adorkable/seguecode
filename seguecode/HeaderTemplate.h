//
//  HeaderTemplate.h
//  seguecode
//
//  Created by Ian on 12/11/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#pragma once

#define DefaultTemplateHeader @"\
 //\n\
 // <#(FileName)#>.h\n\
 // Generated by seguecode\n\
\n\
#pragma once\n\
\n\
#import <UIKit/UIKit.h>\n\
<#(SegueConstantDeclarations)#>\
<#(ControllerCategoryDeclarations)#>\
"

#define DefaultTemplateSource @"\
 //\n\
 // <#(FileName)#>.m\n\
 // Generated by seguecode\n\
\n\
#import \"<#(FileName)#>.h\"\n\
<#(SegueConstantDefinitions)#>\
<#(ControllerCategoryDefinitions)#>\
"

/////////////////////////////////////////////

#define DefaultSegueConstantDeclarationTemplate @"\
extern NSString * const <#(ConstantName)#>;"

#define DefaultSegueConstantDefinitionTemplate @"\
NSString * const <#(ConstantName)#> = @\"<#(ConstantValue)#>\";"

#define DefaultSegueConstant @"\
From<#(SourceViewControllerName)#><#(SegueName)#>To<#(DestinationViewControllerName)#>\
"

////////////////////////////////////////////////

#define DefaultControllerCategoryDeclarationImport @"\
#import \"<#(ViewControllerName)#>.h\"\n\
"

#define DefaultControllerCategoryDeclaration @"\
@interface <#(ViewControllerName)#> (<#(StoryboardName)#>)\n\
<#(SegueSelectorDeclarations)#>\n\
@end\
"
#define DefaultControllerCategoryDefinition @"\
@implementation <#(ViewControllerName)#> (<#(StoryboardName)#>)\n\
<#(SegueSelectorDefinitions)#>\n\
@end\
"

#define DefaultSegueSelectorDeclaration @"\
- (IBAction)go<#(SegueName)#>To<#(DestinationViewControllerName)#>;\n\
- (void)go<#(SegueName)#>To<#(DestinationViewControllerName)#>WithInfo:(id)info;\n\
"

#define DefaultSegueSelectorDefinition @"\
- (IBAction)go<#(SegueName)#>To<#(DestinationViewControllerName)#>\n\
{\n\
    [self go<#(SegueName)#>To<#(DestinationViewControllerName)#>WithInfo:nil];\n\
}\n\
\n\
- (void)go<#(SegueName)#>To<#(DestinationViewControllerName)#>WithInfo:(id)info\n\
{\n\
     [self performSegueWithIdentifier:<#(ConstantName)#> sender:info];\n\
}\n\
"
