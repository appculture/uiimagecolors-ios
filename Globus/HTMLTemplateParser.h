//
//  HTMLTemplateParser.h
//  HTMLParser
//
//  Created by Yves Bannwart-Landert on 07.02.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLTemplateParser : NSObject
{
    NSString *templateContent;
    NSString *parsedTemplate;
}

@property (nonatomic, assign) BOOL webViewShadow;
@property (nonatomic, strong) NSString *parsedTemplate;

- (id)initWithTemplate:(NSString *)theTemplate;

- (NSDictionary *)dictionaryWithStrings:(NSDictionary *)dictionary;
- (void)loadTemplate:(NSString *)theTemplate;
- (void)setVariable:(NSString *)variable value:(id)value;
- (void)setVariables:(NSDictionary *)vars;
- (void)setBlock:(NSString *)block withArray:(NSArray *)theArray forTemplate:(NSString *)theTemplate;
- (void)parse:(UIWebView *)webView;

@end
