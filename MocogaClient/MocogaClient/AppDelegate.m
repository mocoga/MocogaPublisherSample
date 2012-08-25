//
//  AppDelegate.m
//  MocogaClient
//
//  Created by dev@mocoga.com on 12. 8. 24..
//  Copyright (c) 2012년 Mocoga. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"

#import "SecondViewController.h"

/*
 * << 헤더 파일 추가 >>
 *
 * - Mocoga SDK 사용을 위한 헤더를 추가합니다.
 */
#import <MocogaSDK/Mocoga.h>

@interface AppDelegate (GamePointMethods)
- (NSUInteger)addPointFromClient:(NSUInteger)addedPoints;
@end

@interface AppDelegate (MocogaDelegate)
- (void)mocogaWillShowOfferView;
- (void)mocogaDidHideOfferView;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
	[_window release];
	[_tabBarController release];
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
	[[Mocoga shared] initAppID:@"e2601ecf-8183-42d7-8f1f-296e070bfbdc" secretKey:@"4/pBIdJSeoAHaQ==" delegate:self];
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	
	UIViewController *viewController1, *viewController2;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil] autorelease];
	    viewController2 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPhone" bundle:nil] autorelease];
	} else {
	    viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPad" bundle:nil] autorelease];
	    viewController2 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPad" bundle:nil] autorelease];
	}
	
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, nil];
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
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

@implementation AppDelegate (GamePointMethods)

#pragma mark -
#pragma mark Game Points for Client
- (NSUInteger)addPointFromClient:(NSUInteger)addedPoints {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSUInteger points = [prefs integerForKey:@"GamePointsFromClient"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(points + addedPoints) forKey:@"GamePointsFromClient"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return (points + addedPoints);
}

@end

@implementation AppDelegate (MocogaDelegate)

#pragma mark -
#pragma mark MocogaDelegate

/*
 * << 클라이언트 보상 지급 구현 >>
 *
 * - 앱 설치/비디오 시청이 완료된 경우, Mocoga는 보상 지급을 위해 mocogaRequestsToGiveReward:withInfo Delegate를 호출합니다.
 * - 퍼블리셔는 Delegate 안에서 사용자에게 보상을 지급하고 didGiveReward 메소드를 호출하여 Mocoga에게 보상을 지급했음을 알려야 합니다.
 * - 또한 사용자가 업데이트된 가상화폐를 볼수 있도록 UI를 업데이트 하는 것을 권장합니다.
 * - 퍼블리셔 캠페인의 가상화폐 정보에서 "클라이언트" 를 선택합니다.
 */

- (void)mocogaRequestsToGiveReward:(NSString *)rewardTransId withInfo:(NSDictionary *)rewardInfo {
    // 사용자에게 reward_amount 에 해당하는 보상을 지급합니다.
    // 가상화폐 UI 를 업데이트합니다.
	NSLog(@"<< MocogaDelegate >> mocogaRequestsToGiveReward called");
	
	NSString *rewardAmount = [rewardInfo objectForKey:@"reward_amount"];
    [self addPointFromClient:[rewardAmount integerValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SAMPLEPUBLISHER_NOTI_UPDATED_POINTS"
                                                        object:self
                                                      userInfo:nil];
    
    [[Mocoga shared] didGiveReward:rewardTransId];
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
