//
//  ListViewController.h
//
//  Created by Sertac Ozercan on 1/16/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;
@class WebViewController;

@interface ListViewController : UITableViewController
{
    UIBarButtonItem *shareButton;
    
    NSString *currentLink;
    NSString *currentComment;
    NSString *currentTitle;

    RSSChannel *channel;
    
    NSURL *url;
    
    UIPopoverController *aPopoverController;
}

@property (nonatomic, strong) WebViewController *webViewController;

- (void)fetchEntries;

@end

@protocol ListViewControllerDelegate
- (void)listViewController:(ListViewController*)lvc handleObject:(id)object;
@end
