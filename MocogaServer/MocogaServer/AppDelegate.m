//
//  AppDelegate.m
//  MocogaServer
//
//  Created by dev@mocoga.com Mocoga Development Team on 12. 8. 27.
//  Copyright (c) 2012 Mocoga, nTels Company. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

#import "JSONKit.h"

/*
 * << 헤더 파일 추가 >>
 *
 * - Mocoga SDK 사용을 위한 헤더를 추가합니다.
 */
#import "Mocoga.h"

@interface AppDelegate ()

@property (retain, nonatomic) NSMutableData *pointData;
@property (retain, nonatomic) NSURLConnection *pointConnection;

@end

@interface AppDelegate (MocogaDelegate)
- (void)mocogaUpdateCurrency;
- (void)mocogaWillShowOfferView;
- (void)mocogaDidHideOfferView;
@end

@interface AppDelegate (SampleRewardServerMethods)
- (void)getPointFromSampleGameServer;
@end

@interface AppDelegate (SampleRewardServerConnections)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end

@interface AppDelegate (SampleRewardServerNotifications)
- (void)foregroundNotificationReceived:(NSNotification *)notification;
- (void)updatedPointsNotificationReceived:(NSNotification *)notification;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize pointData;
@synthesize pointConnection;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationWillEnterForegroundNotification
												  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
												  object:nil];
	
	[_window release];
	[_tabBarController release];
	[pointData release];
	[pointConnection cancel];
	[pointConnection release];
	
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	/* << Mocoga SDK 초기화 >>
	 *
	 * - Application Delegate Class 파일 (e.g. YourAppDelgate.m) 에 "Mocoga.h" 를 추가하고 (상단 참조), didFinishLanunchingWithOptions 메소드에 초기화하는 코드를 넣습니다.
	 * - [[Mocoga shared] initAppID:@"Your App ID" secretKey:@"Your Secret Key" delegate:"Your AppDelegate Class"];
	 * - 주의! 현재 샘플 앱의 AppID와 SecretKey는 테스트용이므로, 실제 사용하려는 AppID와 SecretKey를 추가해주시기 바랍니다.
	 */
	[[Mocoga shared] initAppID:@"affb74e1-0293-49bc-959a-5b244decf046" secretKey:@"c4/2DIUdGNTTEw==" delegate:self];
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
    // Override point for customization after application launch.
	UIViewController *viewController1, *viewController2, *viewController3;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil] autorelease];
	    viewController2 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPhone" bundle:nil] autorelease];
		viewController3 = [[[ThirdViewController alloc] initWithNibName:@"ThirdViewController_iPhone" bundle:nil] autorelease];
	} else {
	    viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPad" bundle:nil] autorelease];
	    viewController2 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPad" bundle:nil] autorelease];
		viewController3 = [[[ThirdViewController alloc] initWithNibName:@"ThirdViewController_iPad" bundle:nil] autorelease];
	}
	
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, nil];
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
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
	
	/*
	 * << 가상화폐 관리 방식 >>
	 *
	 * - 앱 내 가상화폐의 관리방식(서버 관리 or 클라이언트 관리)에 따라 Mocoga에서 보상을 지급하는 방식에 차이가 있습니다.
	 * - 서버에서 관리하신다면
	 *   : Mocoga는 사용자에게 보상지급이 필요할 경우, 운영 중이신 서버로 보상을 요청하게 됩니다.
	 *   : 퍼블리셔 캠페인의 가상화폐 정보에서 "서버"를 선택하시고, 구현하신 보상 지급 서버 URL 을 입력합니다.
	 *   : 주의! 하단 구현방식은 샘플앱을 위한 서버 보상지급 구현입니다. 실제 구현시에는 해당 서버에 맞는 구현을 하시길 바랍니다.
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foregroundNotificationReceived:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedPointsNotificationReceived:)
                                                 name:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
                                               object:nil];
	
	[self getPointFromSampleGameServer];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end

@implementation AppDelegate (MocogaDelegate)

#pragma mark -
#pragma mark MocogaDelegate

/*
 * << 가상화폐 UI 업데이트 >>
 *
 * - 앱 설치/비디오 시청이 완료된 경우, Mocoga는 보상 지급을 위해 서버 URL 을 호출한 후에 클라이언트에서 
 *   mocogaUpdateCurrency Delegate를 호출하여 사용자에게 보여지는 Currency를 업데이트해야 하는 시점을 알려줍니다.
 * - Application Delegate Class로 (e.g. YourAppDelgate.m)  mocogaUpdateCurrency Delegate가 전달됩니다.
 */
- (void)mocogaUpdateCurrency {
	// 서버로부터 업데이트된 가상화폐를 얻어 UI 를 갱신합니다.
	NSLog(@"<< MocogaDelegate >> mocogaUpdateCurrency called");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
														object:self
													  userInfo:nil];
}

/*
 * << Offer View Event Delegate >>
 *
 * - 사용자가 OfferCon을 클릭하면, 전면을 차지하는 Offer View가 노출됩니다.
 * - Offer View가 노출될 때는 mocogaWillShowOfferView Delegate, 사라질 때는 mocogaDidHideOfferView Delegate 가 호출됩니다.
 * - 위의 Delegate를 이용하여 앱을 일시정지/재개하는 코드 등을 넣으실 수 있습니다.
 * - Application Delegate Class로 (e.g. YourAppDelgate.m)  mocogaWillShowOfferView/mocogaDidHideOfferView  Delegate가 전달됩니다.
 */
- (void)mocogaWillShowOfferView {
	// 게임의 경우, 게임을 일시정지하는 코드를 넣을 수 있습니다.
	NSLog(@"<< MocogaDelegate >> mocogaWillShowOfferView called");
}

- (void)mocogaDidHideOfferView {
	// 게임의 경우, 게임을 재개하는 코드를 넣을 수 있습니다.
	NSLog(@"<< MocogaDelegate >> mocogaDidHideOfferView called");
}

@end

@implementation AppDelegate (SampleRewardServerMethods)

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
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REWARD_POINT_INDICATOR_STARTANIMATING"
														object:self
													  userInfo:nil];
}

@end

@implementation AppDelegate (SampleRewardServerConnections)

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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REWARD_POINT_INDICATOR_STOPANIMATING"
														object:self
													  userInfo:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REWARD_POINT_INDICATOR_STOPANIMATING"
														object:self
													  userInfo:nil];
	
	NSString *result = [[[NSString alloc] initWithBytes:[pointData bytes] length:[pointData length] encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary *jsonDic = [result objectFromJSONString];
	
	if (jsonDic) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REWARD_POINT_DIDUPDATE"
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:jsonDic forKey:@"result"]];
    }
}

@end

@implementation AppDelegate (SampleRewardServerNotifications)

#pragma mark -
#pragma mark Notification Methods

- (void)foregroundNotificationReceived:(NSNotification *)notification {
    [self getPointFromSampleGameServer];
}

- (void)updatedPointsNotificationReceived:(NSNotification *)notification {
    [self getPointFromSampleGameServer];
}

@end
