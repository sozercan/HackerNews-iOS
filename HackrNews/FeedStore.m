//
//  FeedStore.m
//
//  Created by Sertac Ozercan on 2/13/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import "FeedStore.h"
#import "RSSChannel.h"
#import "Connection.h"
#import "RSSItem.h"

@implementation FeedStore

@synthesize url;

+ (FeedStore*)sharedStore
{
    static FeedStore *feedStore = nil;
    if(!feedStore)
        feedStore = [[FeedStore alloc] init];
    
    return feedStore;
}

- (void)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *, NSError *))block
{
    if(!url)
        url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    RSSChannel *channel = [[RSSChannel alloc] init];
    
    Connection *connection = [[Connection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection setXmlRootObject:channel];
    [connection start];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"feed.db"];
        NSURL *dbURL = [NSURL fileURLWithPath:dbPath];
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbURL options:nil error:&error])
                 [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        [context setUndoManager:nil];
    }
    
    return self;
}

- (void)markItemAsRead:(RSSItem *)item
{
    if([self hasItemBeenRead:item])
        return;
    
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:context];
    
    [obj setValue:[item link] forKey:@"urlString"];
    
    [context save:nil];
}

- (BOOL)hasItemBeenRead:(RSSItem *)item
{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"Link"];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"urlString like %@", [item link]];
    [req setPredicate:pred];
    
    NSArray *entries = [context executeFetchRequest:req error:nil];
    if([entries count] > 0)
        return YES;
    
    return NO;
}
@end
