//
//  ViewController.m
//  The Pizza Button
//
//  Created by Michael Feldstein on 11/24/13.
//  Copyright (c) 2013 Michael Feldstein. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"/dist"]];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"dist"];
    NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSLog(@"HTML %@", baseURL);
    [self.webView setDelegate:self];
    [self.webView loadHTMLString:html baseURL:baseURL];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations objectAtIndex:0];
    NSString* locationFunctionCall = [NSString stringWithFormat:@"locationUpdated(%f, %f);", location.coordinate.latitude, location.coordinate.longitude];
    NSString* resp = [self.webView stringByEvaluatingJavaScriptFromString:locationFunctionCall];
    NSLog(@"resp %@", resp);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    if([requestString rangeOfString:@"twitter.com"].location != NSNotFound) {
        if ([[UIApplication sharedApplication] canOpenURL:[request URL]]) {
            [[UIApplication sharedApplication] openURL:[request URL]];
            return NO;
        }
    }
    
    if ([requestString hasPrefix:@"ios-log:"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
        NSLog(@"UIWebView console: %@", logString);
        return NO;
    }
    
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate copyPersistentStorageToLocalStorage];
}


@end
