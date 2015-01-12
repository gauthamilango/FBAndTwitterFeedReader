//
//  WebViewController.m
//  Interview App
//
//  Created by Gautham Ilango on 10/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.webView loadRequest:request];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
