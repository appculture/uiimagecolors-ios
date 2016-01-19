//
//  ABWebserviceWithAuth.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/1/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "WebserviceWithAuth.h"
#import "WebserviceProxy.h"

@interface WebserviceWithAuth ()

@property (nonatomic) SecTrustRef trust;

@end

@implementation WebserviceWithAuth

@synthesize dataSource = _dataSource;
@synthesize trust = _trust;

#if DEBUG
static const char *kTrustNames[kSecTrustResultOtherError + 1] = {
    "Invalid",
    "Proceed",
    "Confirm",
    "Deny",
    "Unspecified",
    "RecoverableTrustFailure",
    "FatalTrustFailure",
    "OtherError"
};
#endif

- (SecTrustRef)trust {
    if(_trust == nil) {
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"der"];
        NSData *certData = [NSData dataWithContentsOfFile:dataPath];
        
        OSStatus            err;
        SecCertificateRef   cert;
        SecPolicyRef        policy;
        
        cert = SecCertificateCreateWithData(NULL, (__bridge_retained CFDataRef) certData);
        assert(cert != NULL);
        
        policy = SecPolicyCreateBasicX509();
        assert(policy != NULL);
        
        err = SecTrustCreateWithCertificates(cert, policy, &_trust);
        assert(err == noErr);
        
        err = SecTrustSetAnchorCertificates(_trust, (__bridge_retained CFArrayRef) [NSArray arrayWithObject:(__bridge_transfer id) cert]);
        assert(err == noErr);
    }
    return _trust;
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace 
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{	     
	if ([challenge previousFailureCount] < 2) {
		if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]) {
            NSAssert(_dataSource, @"you need to set _dataSource");
            NSURLCredential *newCredential = [NSURLCredential credentialWithUser:[_dataSource username] password:[_dataSource password] persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        } else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            
            SecTrustRef trust = self.trust;
            
            NSDate *            date;
            SecTrustResultType  result;
            OSStatus            err;
            
            date = [NSDate new];
            assert(date != nil);
            
            err = SecTrustSetVerifyDate(trust, (__bridge_retained CFDateRef) date);
            assert(err == noErr);
            
            err = SecTrustEvaluate(trust, &result);
            assert(err == noErr);
            
#if DEBUG
            
            if (result < (sizeof(kTrustNames) / sizeof(*kTrustNames))) {
                NSLog(@"result = %s", kTrustNames[result]);
            } else {
                NSLog(@"result = unknown (%zu)", (size_t) result);
            }
#endif
            
            NSURLCredential *credential = [NSURLCredential credentialForTrust:trust];
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            
            
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }

}

@end
