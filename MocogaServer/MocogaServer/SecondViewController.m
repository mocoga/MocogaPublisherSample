//
//  SecondViewController.m
//  MocogaServer
//
//  Created by dev@mocoga.com on 12. 8. 24..
//  Copyright (c) 2012년 Mocoga. All rights reserved.
//

#import "SecondViewController.h"

#import "JSONKit.h"

/*
 * << 헤더 파일 추가 >>
 *
 * - Mocoga SDK 사용을 위한 헤더를 추가합니다.
 */
#import <MocogaSDK/Mocoga.h>

@interface SecondViewController (SampleRewardServerMethods)
- (void)getPointFromSampleGameServer;
@end

@interface SecondViewController (SampleRewardServerConnections)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end

@interface SecondViewController (SampleRewardServerNotifications)
- (void)foregroundNotificationReceived:(NSNotification *)notification;
- (void)updatedPointsNotificationReceived:(NSNotification *)notification;
@end

@implementation SecondViewController

@synthesize pointData;
@synthesize pointConnection;
@synthesize rewardPointLabel;
@synthesize rewardPointIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Second", @"Second");
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	/*
	 * << User ID 설정 >>
	 *
	 * - Mocoga에서 보상을 지급할 때, 어느 사용자에게 보상을 지급해야 하는지를 전달하기 위해서는
	 *   퍼블리셔에서 관리하는 사용자 ID, 즉 보상지급의 대상이 되는 User ID 설정을 해야 합니다.
	 * - OfferCon을 노출하기 전, 즉 showOfferConAtPoint 메소드를 호출하기 이전에 setUserID 메소드를 통해 User ID를 설정해야 합니다.
	 * - 설정한 User ID 는 보상지급 서버 URL 호출시 user_id 로 전달됩니다.
	 * - User ID가 설정이 되어 있지 않으면, 보상을 지급할 사용자를 알 수 없으므로 OfferCon이 표시되지 않습니다.
	 * - 주의! 테스트 앱에서는 편의를 위하여 UDID를 사용하였습니다. 실제 사용시에는 실제 User ID를 입력해주시기 바랍니다.
	 */
	[[Mocoga shared] setUserID:[UIDevice currentDevice].uniqueIdentifier];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationWillEnterForegroundNotification
												  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
												  object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foregroundNotificationReceived:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedPointsNotificationReceived:)
                                                 name:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
                                               object:nil];
	
	[self getPointFromSampleGameServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationWillEnterForegroundNotification
												  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
												  object:nil];
	
    [pointData release];
	[pointConnection cancel];
	[pointConnection release];
	[rewardPointLabel release];
	[rewardPointIndicator release];
	
    [super dealloc];
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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[[Mocoga shared] showOfferConAtPoint:CGPointMake(260.f, 350.f)
										size:MocogaOfferConSizeNormal
							autoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin)];
	}
	else {
		[[Mocoga shared] showOfferConAtPoint:CGPointMake(500.f, 650.f)
										size:MocogaOfferConSizeNormal
							autoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin)];
	}
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

- (void)viewDidUnload {
	[self setRewardPointLabel:nil];
	[self setRewardPointIndicator:nil];
	[super viewDidUnload];
}
@end

@implementation SecondViewController (SampleRewardServerMethods)

#pragma mark -
#pragma mark Sample reward server
- (void)getPointFromSampleGameServer {
    NSString *requestString = [NSString stringWithFormat:@"http://sample-reward.mocoga.com/get_currency?user_id=%@", [[Mocoga shared] getUserID]];
	NSURL *pointURL = [NSURL URLWithString:requestString];
	NSMutableURLRequest *pointRequest = [NSMutableURLRequest requestWithURL:pointURL
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:30];
	
	if (self.pointConnection) {
		[self.pointConnection cancel];
		self.pointConnection = nil;
	}
	
	self.pointConnection = [NSURLConnection connectionWithRequest:pointRequest delegate:self];
	[self.rewardPointIndicator startAnimating];
}

@end

@implementation SecondViewController (SampleRewardServerConnections)

#pragma mark -
#pragma mark Delegate methods for sample reward server
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (self.pointData == nil) {
		self.pointData = [NSMutableData data];
	}
    
    [self.pointData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.pointData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.rewardPointIndicator stopAnimating];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.rewardPointIndicator stopAnimating];
	
	NSString *result = [[[NSString alloc] initWithBytes:[pointData bytes] length:[pointData length] encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary *jsonDic = [result objectFromJSONString];
	
	if (jsonDic) {
        NSInteger point = [[jsonDic objectForKey:@"point"] intValue];
		self.rewardPointLabel.text = [NSString stringWithFormat:@"%d Point", point];
    }
}

@end

@implementation SecondViewController (SampleRewardServerNotifications)

#pragma mark -
#pragma mark Notification Methods

- (void)foregroundNotificationReceived:(NSNotification *)notification {
    [self getPointFromSampleGameServer];
}

- (void)updatedPointsNotificationReceived:(NSNotification *)notification {
    [self getPointFromSampleGameServer];
}

@end
