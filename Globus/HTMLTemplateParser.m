//
//  HTMLTemplateParser.m
//  HTMLTemplateParser
//
//  Created by Yves Bannwart-Landert on 07.02.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import "HTMLTemplateParser.h"


#pragma mark - Constants

#define kDELIMITER_START    @"{"
#define kDELIMITER_END      @"}"
#define kTEMPLATE_SUFFIX    @"html"


#pragma mark - Private Interface

@interface HTMLTemplateParser (Private)

- (NSString *)loadBlockfile:(NSString *)theTemplate;
- (NSMutableString *)getContent;
- (NSMutableString *)setBlockVariables:(NSDictionary *)vars fromContent:(NSString *)content intoContent:(NSString *)blockContent;
- (NSMutableString *)pelaceDefinedVariableBlock:(NSString *)key value:(NSString *)value content:(NSString *)content;
- (NSString *)getRegularExpressionForDelimiter:(NSString *)variable;
- (NSString *)getRegularExpressionForCutoutVar:(NSString *)variable;
- (NSString *)newlineToHTMLBreak:(NSString *)value;
- (NSString *)toString:(id)value;
- (void)removeWebViewShadows:(UIWebView *)webView;

@end


@implementation HTMLTemplateParser

@synthesize webViewShadow, parsedTemplate;


#pragma mark - Initialization

- (id)initWithTemplate:(NSString *)theTemplate 
{
    self = [super init];
    if (self) {
        self.webViewShadow = YES;
        [self loadTemplate:theTemplate];
    }
    return self;
}

#pragma mark - Public API Methods

/* 
**  Load container (main) template file 
*/
- (void)loadTemplate:(NSString *)theTemplate
{
    NSString *htmlTemplate = [[NSBundle mainBundle] pathForResource:theTemplate ofType:kTEMPLATE_SUFFIX]; 
    
    NSError *error = nil;
    parsedTemplate = nil;
    templateContent = [NSMutableString stringWithContentsOfFile:htmlTemplate encoding:NSUTF8StringEncoding error:&error];
}

/* 
**  Define a single variable with name and value
*/
- (void)setVariable:(NSString *)variable value:(id)value
{
    NSMutableString *tmp = [self getContent];
    
    tmp = [self pelaceDefinedVariableBlock:variable value:variable content:tmp];
    
    NSString *r = [self getRegularExpressionForDelimiter:variable];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:r options:0 error:NULL];
    NSString *lineBreakFormatedVar = [self newlineToHTMLBreak:value];
    tmp = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, [tmp length]) withTemplate:lineBreakFormatedVar]];
    
    parsedTemplate = tmp;
}

/* 
**  Define multiple template variables from dictionary
*/
- (void)setVariables:(NSDictionary *)vars 
{
    NSError *error = nil;
    NSMutableString *tmp = [self getContent];
    
    for (id var in vars) 
    {
        tmp = [self pelaceDefinedVariableBlock:var value:[vars objectForKey:var] content:tmp];
        
        NSString *r = [self getRegularExpressionForDelimiter:var];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:r options:0 error:&error];
        NSArray *matches = [regex matchesInString:templateContent options:0 range:NSMakeRange(0, [templateContent length])];
        
        for (NSTextCheckingResult *match in matches)
        {
            NSString *matchText = [templateContent substringWithRange:[match range]];
            NSString *lineBreakFormatedVar = [self newlineToHTMLBreak:[vars objectForKey:var]];
            
            if ([[NSString stringWithFormat:@"%@%@%@", kDELIMITER_START, var, kDELIMITER_END] isEqual:matchText]) {
                tmp = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, [tmp length]) withTemplate:lineBreakFormatedVar]];
            }
        }
    }
    parsedTemplate = tmp; 
}

/* 
**  Define repeating block template with multiple variables from dictionary
*/
- (void)setBlock:(NSString *)block withArray:(NSArray *)theArray forTemplate:(NSString *)theTemplate
{
    NSString *blockContent = [self loadBlockfile:theTemplate];
    NSMutableString *final = [[NSMutableString alloc] init];
    
    if ([theArray count] > 0) 
    {
        for (int i=0; i<[theArray count]; i++)
        {            
            NSMutableString *t = [blockContent copy];
            t = [self setBlockVariables:(NSDictionary *)[theArray objectAtIndex:i] fromContent:t intoContent:blockContent];
            [final appendString:t];
        }
    } 
    
    // Find block element and insert parsed block template
    NSMutableString *tmp = [self getContent];
    NSString *r = [self getRegularExpressionForDelimiter:block];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:r options:0 error:NULL];
    tmp = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, [tmp length]) withTemplate:final]];
    
    parsedTemplate = tmp;
}

/* 
**  Parsed template into UIWebView
*/
- (void)parse:(UIWebView *)webView
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [webView loadHTMLString:parsedTemplate baseURL:baseURL];
    parsedTemplate = nil;
    
    if (self.webViewShadow)
        [self removeWebViewShadows:webView];
}


#pragma mark - Private API Methods

/* 
**  Get template content
*/
- (NSMutableString *)getContent
{
    NSMutableString *content;
    
    if (!parsedTemplate)
        content = [templateContent copy];
    else 
        content = [parsedTemplate copy];
    
    return content;
}

/* 
**  Load template for repeating blocks
*/
- (NSString *)loadBlockfile:(NSString *)theTemplate
{
    NSError *error = nil;
    NSString *blockFile = [[NSBundle mainBundle] pathForResource:theTemplate ofType:kTEMPLATE_SUFFIX];
    NSString *blockContent = [NSMutableString stringWithContentsOfFile:blockFile encoding:NSUTF8StringEncoding error:&error];
    
    return blockContent;
}

/* 
**  Define repeating block variables from dictionary
*/
- (NSMutableString *)setBlockVariables:(NSDictionary *)vars fromContent:(NSString *)content intoContent:(NSString *)blockContent
{
    NSError *error = nil;
    NSMutableString *tmp = [content copy];
    
    for (id var in vars) 
    {
         tmp = [self pelaceDefinedVariableBlock:var value:[vars objectForKey:var] content:tmp];
        
        // Create regex for replacement vars
        NSString *r = [self getRegularExpressionForDelimiter:var];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:r options:0 error:&error];
        NSArray *matches = [regex matchesInString:blockContent options:0 range:NSMakeRange(0, [blockContent length])];
        
        for (NSTextCheckingResult *match in matches)
        {
            NSString *matchText = [blockContent substringWithRange:[match range]];
            NSString *lineBreakFormatedVar = [self newlineToHTMLBreak:[vars objectForKey:var]];
            
            if ([[NSString stringWithFormat:@"%@%@%@", kDELIMITER_START, var, kDELIMITER_END] isEqual:matchText]) {
                tmp = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, [tmp length]) withTemplate:lineBreakFormatedVar]];
            }
        }
    }
    return tmp;
}

/* 
 **  Replace undefined variables
*/
- (NSMutableString *)pelaceDefinedVariableBlock:(NSString *)key value:(NSString *)value content:(NSString *)content
{
    NSError *error = nil;
    NSMutableString *tmp = [content copy];
    
    NSString *cutout = [self getRegularExpressionForCutoutVar:key];
    NSRegularExpression *definedVars = [NSRegularExpression regularExpressionWithPattern:cutout options:0 error:&error];
    NSArray *cutOutStrings = [definedVars matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    
	// added unused attribute by ahorstmann
    for (NSTextCheckingResult *match __attribute__((unused)) in cutOutStrings)
    {
        if (!value || [value length] == 0)
            tmp = [NSMutableString stringWithString:[definedVars stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, [content length]) withTemplate:@""]];
    }
    return tmp;
}


#pragma mark - Helper methods

/* 
**  Get regular expression for variable delimiter
*/
- (NSString *)getRegularExpressionForDelimiter:(NSString *)variable
{
    return [NSString stringWithFormat:@"\\%@%@\\%@", kDELIMITER_START, variable, kDELIMITER_END];
}

/* 
 **  Get regular expression for undefined variables cutouts
 */
- (NSString *)getRegularExpressionForCutoutVar:(NSString *)variable
{
    return [NSString stringWithFormat:@"<!--\\s?ISDEF:\\s?%@\\s?-->\\s*?\\n?(\\s*.*?\\n?)\\s*<!--\\s?END\\s%@\\s?-->", variable, variable];
}

/* 
**  Replace \n (newline) with break (<br />)
*/
- (NSString *)newlineToHTMLBreak:(NSString *)value
{
    return [value stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
}

/*
** Check if value is a string 
*/
- (NSString *)toString:(id)value 
{    
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]])
        return nil;

    return [value description];
}

- (NSDictionary *)dictionaryWithStrings:(NSDictionary *)dictionary
{
    NSMutableDictionary *stringDictionary = [[NSMutableDictionary alloc] init];
    for (id key in dictionary) 
    {
        NSString *string;
        if (![dictionary valueForKey:key] || [dictionary valueForKey:key] == [NSNull null]) {
            string = @"";
        }
        else {    
            string = [self toString:[dictionary valueForKey:key]];
        }
        if (string)
            [stringDictionary setValue:string forKey:key];
            
    }
    return stringDictionary;
}

/* 
**  Remove UIWebview shadows
*/
- (void)removeWebViewShadows:(UIWebView *)webView
{
    UIView *scrollview = [webView.subviews objectAtIndex:0];    
    for (UIView *subview in [scrollview subviews])
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
}

@end
