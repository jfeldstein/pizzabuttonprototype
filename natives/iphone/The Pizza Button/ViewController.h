//
//  ViewController.h
//  The Pizza Button
//
//  Created by Michael Feldstein on 11/24/13.
//  Copyright (c) 2013 Michael Feldstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, UIWebViewDelegate>

@property IBOutlet UIWebView* webView;
@property CLLocationManager* locationManager;
@end
