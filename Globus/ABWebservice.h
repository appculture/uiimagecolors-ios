//
//  ABWebservice.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <Foundation/Foundation.h>


typedef enum
{
    ABWebserviceReturnObjectTypeOther,
    ABWebserviceReturnObjectTypeNSString,
    ABWebserviceReturnObjectTypeNSNumber,
    ABWebserviceReturnObjectTypeUIImage,
	ABWebserviceReturnObjectTypeNSData,
    ABWebserviceReturnObjectTypeNSPropertyList
}
ABWebserviceReturnObjectType;

@protocol WebserviceValidStatusCodesDataSource <NSObject>

- (NSArray*)webserviceValidStatusCodesArray;

@end


@protocol ABWebserviceDelegate;


@interface ABWebservice : NSObject <WebserviceValidStatusCodesDataSource>
{
	__unsafe_unretained id <ABWebserviceDelegate> delegate;
	ABWebserviceReturnObjectType returnObjectType;

	BOOL backgroundProcessingEnabled;
	BOOL requestCacheEnabled;
	BOOL running;
	BOOL canStop;

@private
	NSURLConnection *connection;
	NSURLRequest *request;
	NSURLResponse *response;
	NSMutableData *responseData;
}

@property (nonatomic, unsafe_unretained) __unsafe_unretained id <ABWebserviceDelegate> delegate;
@property (nonatomic, unsafe_unretained) __unsafe_unretained id <WebserviceValidStatusCodesDataSource> statusCodesDataSource;
@property (nonatomic) ABWebserviceReturnObjectType returnObjectType;
@property (nonatomic) BOOL backgroundProcessingEnabled, requestCacheEnabled, running, canStop;

- (void)startWithRequest:(NSURLRequest *)theRequest;
- (void)stop;
- (void)clearCache;

- (id)objectWithData:(NSData *)theData;

@end


@protocol ABWebserviceDelegate <NSObject>

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject;

@optional
- (void) webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError;
- (void) webserviceWillStart:(ABWebservice *)theWebservice;
- (void) webserviceDidFinishSending:(ABWebservice *)theWebservice;
- (void) webserviceDidStartLoading:(ABWebservice *)theWebservice;
- (void) webserviceDidFinishLoading:(ABWebservice *)theWebservice;
- (void) webserviceDidCancel:(ABWebservice *)theWebservice;
- (void) webservice:(ABWebservice *)theWebservice didChangeProgress:(float)progress;

@end

