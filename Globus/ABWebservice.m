//
//  ABWebservice.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//  Updated to ARC

#import "ABWebservice.h"


@interface ABWebservice ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;

- (void)objectBuilderDidFinishWithObject:(id)theObject;
- (void)buildObjectThreadedWithData:(NSData *)theData;

@end


@implementation ABWebservice

@synthesize connection, request, response;
@synthesize statusCodesDataSource = _statusCodesDataSource;


#pragma mark - Housekeeping

- (id)init
{
	if ((self = [super init]))
	{
		responseData = [[NSMutableData alloc] init];
		returnObjectType = ABWebserviceReturnObjectTypeOther;
        self.statusCodesDataSource = self;
		self.requestCacheEnabled = NO;
	}
	
	return self;
}

- (void)dealloc
{
	[connection cancel];
}


#pragma mark - API / Public methods

@synthesize delegate, returnObjectType, backgroundProcessingEnabled, requestCacheEnabled, running, canStop;

- (void)startWithRequest:(NSURLRequest *)theRequest
{
	if (requestCacheEnabled && [request.URL isEqual:theRequest.URL])
		return;
	
	self.request = theRequest;
	
	if (delegate)
	{
		canStop = NO;
		running = YES;

		[connection cancel];
		
		if ([delegate respondsToSelector:@selector(webserviceWillStart:)])
			[delegate webserviceWillStart:self];

#if DEBUG
		NSLog(@"ABWebservice started with request URL: %@", theRequest.URL.absoluteString);
#endif
		self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	}
}

- (void)stop
{
	[connection cancel];
	
	if (running)
	{
#if DEBUG
		NSLog(@"ABWebservice cancelled with request URL: %@", request.URL.absoluteString);
#endif
		self.request = nil;
		
		canStop = NO;
		running = NO;
		
		if ([delegate respondsToSelector:@selector(webserviceDidCancel:)])
			[delegate webserviceDidCancel:self];
	}
}

- (void)clearCache
{
	self.request = nil;
}


#pragma mark - Connection delegates

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse
{
	[responseData setLength:0];
	
	self.response = theResponse;
	
	NSInteger statusCode = ((NSHTTPURLResponse *)theResponse).statusCode;
    
    __block BOOL isValidCode = NO;
    
    [[_statusCodesDataSource webserviceValidStatusCodesArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSNumber *validCode = (NSNumber*)obj;
        if(statusCode == [validCode intValue]){
            isValidCode = YES;
            *stop = YES;
        }
    }];
	
	if (!isValidCode)
	{
		[self stop];
		
		if ([delegate respondsToSelector:@selector(webservice:didFailWithError:)])
			[delegate webservice:self didFailWithError:nil];
	}
	else
	{
		canStop = YES;
		if ([delegate respondsToSelector:@selector(webserviceDidStartLoading:)])
			[delegate webserviceDidStartLoading:self];
	}

}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)theData
{
	[responseData appendData:theData];
		
	if ([delegate respondsToSelector:@selector(webservice:didChangeProgress:)])
	{
		float progress = theData.length / response.expectedContentLength;
		[delegate webservice:self didChangeProgress:progress];
	}
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)theError
{
	self.request = nil;

	canStop = NO;
	running = NO;
	
	if ([delegate respondsToSelector:@selector(webservice:didFailWithError:)])
		[delegate webservice:self didFailWithError:theError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	canStop = NO;
	running = NO;

	if ([delegate respondsToSelector:@selector(webserviceDidFinishLoading:)])
		[delegate webserviceDidFinishLoading:self];
	
#if DEBUG
	if (returnObjectType == ABWebserviceReturnObjectTypeNSString || returnObjectType == ABWebserviceReturnObjectTypeNSPropertyList || returnObjectType == ABWebserviceReturnObjectTypeOther)
		NSLog(@"Webservice returned with response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
	else
		NSLog(@"Webservice returned with binary response of length: %lu", (unsigned long)responseData.length);
#endif

	if (backgroundProcessingEnabled)
		[NSThread detachNewThreadSelector:@selector(buildObjectThreadedWithData:) toTarget:self withObject:responseData];
	else
		[self objectBuilderDidFinishWithObject:[self objectWithData:responseData]];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	if ([delegate respondsToSelector:@selector(webservice:didChangeProgress:)])
	{
		float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
		[delegate webservice:self didChangeProgress:progress];
		
		if (progress >= 1.0 && [delegate respondsToSelector:@selector(webserviceDidFinishSending:)])
			[delegate webserviceDidFinishSending:self];
	}
}


#pragma mark - Object builder

- (void)objectBuilderDidFinishWithObject:(id)theObject
{
	if (theObject)
		[delegate webservice:self didFinishWithObject:theObject];
	else
		if ([delegate respondsToSelector:@selector(webservice:didFailWithError:)])
			[delegate webservice:self didFailWithError:nil];
}

- (void)buildObjectThreadedWithData:(NSData *)theData
{
    @autoreleasepool {
        [self performSelectorOnMainThread:@selector(objectBuilderDidFinishWithObject:) withObject:[self objectWithData:theData] waitUntilDone:YES];
    }
}

// method must be overwritten in subclass for ABWebserviceReturnObjectTypeOther 
- (id)objectWithData:(NSData *)theData
{
	switch (returnObjectType)
	{
		case ABWebserviceReturnObjectTypeNSString:
			return [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
			break;
			
		case ABWebserviceReturnObjectTypeNSNumber:
		{
			NSString *numberString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
			NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
			NSNumber *number = [formatter numberFromString:numberString];
			return number;
			break;
		}
		
		case ABWebserviceReturnObjectTypeUIImage:
			return [UIImage imageWithData:theData];
			break;
			
		case ABWebserviceReturnObjectTypeNSData:
			return theData;
			break;
			
		case ABWebserviceReturnObjectTypeNSPropertyList:
            return [NSPropertyListSerialization propertyListWithData:theData options:NSPropertyListImmutable format:nil error:nil];
			break;

		case ABWebserviceReturnObjectTypeOther:
		default:
			return nil;
			break;
	}
}

#pragma mark - WebserviceValidStatusCodesDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:200], nil];
    return validCodes;
}

@end
