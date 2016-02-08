//
//  FeedStore.h
//
//  Created by Sertac Ozercan on 2/13/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSChannel, RSSItem;

@interface FeedStore : NSObject
{
    NSURL *url;
    
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property (nonatomic) NSURL *url;

+ (FeedStore*)sharedStore;

- (void)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj, NSError *err))block;
- (void)markItemAsRead:(RSSItem*)item;
- (BOOL)hasItemBeenRead:(RSSItem*)item;

@end
