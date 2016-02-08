//
//  RSSChannel.m
//
//  Created by Sertac Ozercan on 1/16/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import "RSSChannel.h"
#import "RSSItem.h"

@implementation RSSChannel
@synthesize items, title, infoString, parentParserDelegate;

- (id)init
{
    self = [super init];
    if(self)
        items = [[NSMutableArray alloc] init];
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t%@ found a %@ element", self, elementName);
    
    if([elementName isEqual:@"title"])
    {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    }
    else if([elementName isEqual:@"description"])
    {
        currentString = [[NSMutableString alloc] init];
        [self setInfoString:currentString];
    }
    else if([elementName isEqual:@"item"])
    {
        RSSItem *entry = [[RSSItem alloc] init];
        [entry setParentParserDelegate:self];
        [parser setDelegate:entry];
        [items addObject:entry];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    currentString = nil;
    if([elementName isEqual:@"channel"])
    {
        [parser setDelegate:parentParserDelegate];
    }
}

- (void)readfromJSONDictionary:(NSDictionary *)d
{
    NSArray *entries = [d objectForKey:@"items"];
    for(NSDictionary *entry in entries)
    {
        RSSItem *i = [[RSSItem alloc] init];
        [i readfromJSONDictionary:entry];
        [items addObject:i];
    }
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:items forKey:@"items"];
//    [aCoder encodeObject:title forKey:@"title"];
//    [aCoder encodeObject:infoString forKey:@"infoString"];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if(self)
//    {
//        items = [aDecoder decodeObjectForKey:@"items"];
//        [self setInfoString:[aDecoder decodeObjectForKey:@"infoString"]];
//        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
//    }
//    return self;
//}

@end
