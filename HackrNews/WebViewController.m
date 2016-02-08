//
//  WebViewController.m
//
//  Created by Sertac Ozercan on 1/16/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import "WebViewController.h"
#import "RSSItem.h"

@implementation WebViewController

- (void)loadView
{
    //Create an instance of UIWebView as large as the screen
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    wv = [[UIWebView alloc] initWithFrame:screenFrame];
    //Tell web view to scale web content to fit within bounds of webview
    [wv setScalesPageToFit:YES];
    [wv setDelegate:self];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"left.png"];
    UIImage *forwardButtonImage = [UIImage imageNamed:@"right.png"];

    backButton = [[UIBarButtonItem alloc] initWithImage:backButtonImage landscapeImagePhone:backButtonImage style:UIBarButtonSystemItemRewind target:self action:@selector(goBack)];
    forwardButton = [[UIBarButtonItem alloc] initWithImage:forwardButtonImage landscapeImagePhone:forwardButtonImage style:UIBarButtonSystemItemFastForward target:self action:@selector(goForward)];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backButton, forwardButton, nil];
        }
    }
    else
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:forwardButton, backButton, nil];

    [self updateButtons];
    
    [self setView:wv];
}

- (void)goBack {
    [wv goBack];
    [self updateButtons];
}

- (void)goForward {
    [wv goForward];
    [self updateButtons];
}

- (void) updateButtons {
    [backButton setEnabled:[wv canGoBack]];
    [forwardButton setEnabled:[wv canGoForward]];
}

- (UIWebView *)webView {
    return (UIWebView *)[self view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateButtons];
}

- (void)listViewController:(ListViewController *)lvc handleObject:(id)object
{
    RSSItem *entry = object;
    
    if(![entry isKindOfClass:[RSSItem class]])
        return;
    
    NSURL *url = [NSURL URLWithString:[entry link]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:req];
    
    [[self navigationItem] setTitle:[entry title]];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setTitle:@"news"];
    [[self navigationItem] setLeftBarButtonItems:[NSArray arrayWithObjects:barButtonItem, backButton, forwardButton, nil]];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(barButtonItem == [[self navigationItem] leftBarButtonItem])
        [[self navigationItem] setLeftBarButtonItem:nil];
}

@end