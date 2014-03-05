//
//  BIWebViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/3/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIWebViewController.h"

@interface BIWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation BIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(tappedDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self loadRequest];
}

- (void)loadRequest {
    if(_URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_URL cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:30];
        [_webView loadRequest:request];
    }
}

#pragma mark - webviewdelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showProgressHUD];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideProgressHUD];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - ibactions

- (void)tappedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
