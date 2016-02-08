//
//  RSSItem.m
//
//  Created by Sertac Ozercan on 1/16/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import "RSSItem.h"

@implementation RSSItem
@synthesize title, link, comments, parentParserDelegate;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t\t%@ found a %@ element", self, elementName);
    
    if([elementName isEqual:@"title"])
    {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    }
    else if([elementName isEqual:@"link"])
    {
        currentString = [[NSMutableString alloc] init];
        [self setLink:currentString];
    }
    else if([elementName isEqual:@"comments"])
    {
        currentString = [[NSMutableString alloc] init];
        [self setComments:currentString];
    }
//    else if([elementName isEqual:@"pubDate"])
//    {
//        currentString = [[NSMutableString alloc] init];
//        [self setPubDate:currentString];
//    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentString appendString:str];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    currentString = nil;
    
    if ([elementName isEqual:@"item"])
        [parser setDelegate:parentParserDelegate];
}

- (void)readfromJSONDictionary:(NSDictionary *)d
{
    [self setTitle:[d objectForKey:@"title"]];
    [self setLink:[d objectForKey:@"url"]];
    [self setComments:[NSString stringWithFormat:@"http://news.ycombinator.com/item?id=%@",[d objectForKey:@"item_id"]]];
    //[self setDescription:[d objectForKey:@"description"]];
    
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:title forKey:@"title"];
//    [aCoder encodeObject:link forKey:@"link"];
//    [aCoder encodeObject:comments forKey:@"comments"];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if(self)
//    {
//        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
//        [self setLink:[aDecoder decodeObjectForKey:@"link"]];
//        [self setComments:[aDecoder decodeObjectForKey:@"comments"]];
//    }
//    return self;
//}


@end
