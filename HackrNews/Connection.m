//
//  Connection.m
//
//  Created by Sertac Ozercan on 2/13/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import "Connection.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation Connection

@synthesize request, completionBlock, xmlRootObject, jsonRootObject;

- (id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if(self)
        [self setRequest:req];
    return self;
}

- (void)start
{
    container = [[NSMutableData alloc] init];
    internalConnection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self startImmediately:YES];
    
    if(!sharedConnectionList)
        sharedConnectionList = [[NSMutableArray alloc] init];
    [sharedConnectionList addObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id rootObject = nil;
    
    if([self xmlRootObject])
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:container];
        [parser setDelegate:[self xmlRootObject]];
        [parser parse];
        
        rootObject = [self xmlRootObject];
    }
    else if([self jsonRootObject])
    {
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:container options:0 error:nil];
        [[self jsonRootObject] readfromJSONDictionary:d];
        rootObject = [self jsonRootObject];
    }
    
    if([self completionBlock])
        [self completionBlock](rootObject, nil);
    
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([self completionBlock])
        [self completionBlock](nil, error);
    [sharedConnectionList removeObject:self];
}

@end
