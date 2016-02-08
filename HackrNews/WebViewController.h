//
//  WebViewController.h
//
//  Created by Sertac Ozercan on 1/16/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListViewController.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, ListViewControllerDelegate, UISplitViewControllerDelegate>
{
    UIWebView *wv;
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
}

@property (nonatomic, readonly) UIWebView *webView;
@end
