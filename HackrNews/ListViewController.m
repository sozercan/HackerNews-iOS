//
//  ListViewController.m
//
//  Created by Sertac Ozercan on 1/16/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WebViewController.h"
#import "RSSViewCell.h"
#import "FeedStore.h"
#import "TUSafariActivity.h"
#import <CKRefreshControl/CKRefreshControl.h>

@implementation ListViewController
@synthesize webViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"RSSViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"RSSViewCell"];
    
    self.navigationItem.title = @"hacker news";
    
    CKRefreshControl *refreshControl = [CKRefreshControl new];
    refreshControl.tintColor = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1];
    [refreshControl addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = (id)refreshControl;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects: @"front", @"new", nil]];
    [segmentedControl addTarget:self action:@selector(changeFeedType:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 140, 35);
    segmentedControl.momentary = NO;
    segmentedControl.selectedSegmentIndex = 0;
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    UIBarButtonItem *flexibleSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1];
    [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpace, segmentBarItem, flexibleSpace, nil]];
}

- (void)changeFeedType:(id)sender
{    
    if([sender selectedSegmentIndex] == 0)
    {
        [[FeedStore sharedStore] setUrl:[NSURL URLWithString:@"http://news.ycombinator.com/rss"]];
        [self fetchEntries];
    }
    else
    {
        [[FeedStore sharedStore] setUrl:[NSURL URLWithString:@"http://hnrss.org/newest"]];
        [self fetchEntries];
    }
}

- (void)doRefresh:(UIRefreshControl *)sender
{
    [self fetchEntries];
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[channel items] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RSSViewCell"];
    
    if(cell == nil)
        cell = [[RSSViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RSSViewCell"];
    
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    
    [[cell title] setText:[item title]];
    //[[cell category] setText:[item pubDate]];
    
    if([[FeedStore sharedStore] hasItemBeenRead:item])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

- (void)fetchEntries
{    
    [[FeedStore sharedStore] fetchRSSFeedWithCompletion:^(RSSChannel *obj, NSError *err)
    {
        if(!err)
        {
            channel = obj;
            [[self tableView] reloadData];
        }
        else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self)
    {
        [self fetchEntries];
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self splitViewController])
        [[self navigationController] pushViewController:webViewController animated:YES];
    else
    {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webViewController];
        nav.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1];
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController], nav, nil];
        
        [[self splitViewController] setViewControllers:vcs];
        [[self splitViewController] setDelegate:webViewController];
    }
    
    RSSItem *entry = [[channel items] objectAtIndex:[indexPath row]];
    
    [[FeedStore sharedStore] markItemAsRead:entry];
    
    [[[self tableView] cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects: @"article", @"comments", nil]];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 140, 35);
    segmentedControl.momentary = NO;
    segmentedControl.selectedSegmentIndex = 0;
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    UIBarButtonItem *flexibleSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        webViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:segmentBarItem, shareButton, nil];
    else
        [webViewController setToolbarItems: [NSArray arrayWithObjects:flexibleSpace, segmentBarItem, flexibleSpace, shareButton, nil]];

    currentLink = [entry link];
    currentComment = [entry comments];
    currentTitle = [entry title];
        
    [webViewController listViewController:self handleObject:entry];
}

- (void)shareAction:(UIBarButtonItem*)sender
{
    NSString *textToShare = currentTitle;
    NSURL *urlToShare = [NSURL URLWithString:currentLink];
    NSArray *activityItems = @[textToShare, urlToShare];
    UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:@[[[TUSafariActivity alloc] init]]];
    avc.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact ];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(![aPopoverController isPopoverVisible])
        {
            aPopoverController = [[UIPopoverController alloc] initWithContentViewController:avc];
            [aPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
        [webViewController presentViewController:avc animated:TRUE completion:nil];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    popoverController = nil;
}

- (void)segmentAction:(id)sender
{
    if([sender selectedSegmentIndex] == 0)
    {
        url = [NSURL URLWithString:currentLink];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [[webViewController webView] loadRequest:req];
    }
    else
    {
        url = [NSURL URLWithString:currentComment];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [[webViewController webView] loadRequest:req];
    }
}
@end
