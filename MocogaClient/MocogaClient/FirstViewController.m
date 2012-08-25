//
//  FirstViewController.m
//  MocogaClient
//
//  Created by dev@mocoga.com on 12. 8. 24..
//  Copyright (c) 2012년 Mocoga. All rights reserved.
//

#import "FirstViewController.h"

/*
 * << 헤더 파일 추가 >>
 *
 * - Mocoga SDK 사용을 위한 헤더를 추가합니다.
 */
#import <MocogaSDK/Mocoga.h>

@interface FirstViewController ()

@end

@interface FirstViewController (SampleGamePointMethods)
- (NSUInteger)getPointsFromClient;
@end

@interface FirstViewController (NSNotificationMethods)
- (void)gamePointDidUpdateNotification:(NSNotification *)notification;
@end

@implementation FirstViewController

@synthesize gamePointLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"First", @"First");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gamePointDidUpdateNotification:)
                                                 name:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
                                               object:nil];
    
	self.gamePointLabel.text = [NSString stringWithFormat:@"%d", [self getPointsFromClient]];
}

- (void)viewDidUnload
{
    [self setGamePointLabel:nil];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	/*
	 * << OfferCon (Offer Icon) 표시 >>
	 *
	 * - OfferCon을 화면상에 노출하기 위해, showOfferConAtPoint 메소드를 호출합니다.
	 *   : 네트워크 환경이 원활하지 않는 등의 경우, OfferCon이 노출되지 않을 수 있습니다.
	 *   : 자세한 사항은 Xcode 콘솔 로그를 통하여 확인하실 수 있습니다.
	 * - OfferCon을 화면상에서 숨길 때는 hideOfferCon 메소드를 호출합니다.
	 * - OfferCon의 위치는 화면 좌측상단을 기준으로 좌표값을 지정하며, 크기는 Small/Normal/Large 중 선택하실 수 있습니다.
	 *   enum {
	 *		MocogaOfferConSizeSmall = 0,   // iphone 40x40, ipad 80x80
	 *		MocogaOfferConSizeNormal = 1,  // iphone 60x60, ipad 100x100
	 *		MocogaOfferConSizeLarge = 2    // iphone 80x80, ipad 120x120
	 *	 };
	 * - Mocoga SDK 는 Status Bar 의 방향(orientation)을 감지하여 OfferCon 을 표시할 방향을 판단합니다.
	 *   앱 화면과 OfferCon 의 방향이 맞지 않는 경우 다음과 같이 Status Bar 의 방향을 설정하시면 됩니다.
	 * - 화면 회전에 따라 OfferCon 위치를 조정해야할 경우에는 다음과 같이 대응하실 수 있습니다.
	 *   : 화면 회전이 일어난 후에 showOfferConAtPoint를 다시 호출하면 됩니다.
	 *     (e.g. willAnimateRotationToInterfaceOrientation가 불릴 때)
	 *   : showOfferConAtPoint:size:autoresizingMask 메소드를 사용하여 화면 회전에 자동 대응될 수 있도록 구현하실 수 있습니다.
	 */
	[[Mocoga shared] showOfferConAtPoint:CGPointMake(10.f, 60.f)
									size:MocogaOfferConSizeLarge
						autoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin)];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	/*
	 * << OfferCon (Offer Icon) 감추기 >>
	 *
	 * - OfferCon을 화면상에 숨기기 위해, hideOfferCon 메소드를 호출합니다.
	 */
	[[Mocoga shared] hideOfferCon];
}

- (void)dealloc {
    [gamePointLabel release];
	
	[super dealloc];
}

@end

@implementation FirstViewController (SampleGamePointMethods)

#pragma mark -
#pragma mark Game Points for Client
- (NSUInteger)getPointsFromClient {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSUInteger points = [prefs integerForKey:@"GamePointsFromClient"];
    return points;
}
@end

@implementation FirstViewController (NSNotificationMethods)

#pragma mark -
#pragma mark Notification methods
- (void)gamePointDidUpdateNotification:(NSNotification *)notification {
	self.gamePointLabel.text = [NSString stringWithFormat:@"%d", [self getPointsFromClient]];
}

@end
