//
//  SecondViewController.h
//  MocogaServer
//
//  Created by dev@mocoga.com on 12. 8. 24..
//  Copyright (c) 2012년 Mocoga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (retain, nonatomic) NSMutableData *pointData;
@property (retain, nonatomic) NSURLConnection *pointConnection;

@property (retain, nonatomic) IBOutlet UILabel *rewardPointLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *rewardPointIndicator;

@end
