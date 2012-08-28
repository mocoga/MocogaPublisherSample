//
//  ThirdViewController.m
//  MocogaClient
//
//  Created by dev@mocoga.com Mocoga Development Team on 12. 8. 27.
//  Copyright (c) 2012 Mocoga, nTels Company. All rights reserved.
//

#import "ThirdViewController.h"

/*
 * << 헤더 파일 추가 >>
 *
 * - Mocoga SDK 사용을 위한 헤더를 추가합니다.
 */
#import <MocogaSDK/Mocoga.h>

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Small", @"Small");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_gray"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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
	
	CGPoint offerConPoint = CGPointZero;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
			offerConPoint = CGPointMake(140.f, 260.f);
		}
		else {
			offerConPoint = CGPointMake(260.f, 140.f);
		}
	}
	else {
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
			offerConPoint = CGPointMake(344.f, 772.f);
		}
		else {
			offerConPoint = CGPointMake(772.f, 344.f);
		}
	}
	
	[[Mocoga shared] showOfferConAtPoint:offerConPoint
									size:MocogaOfferConSizeSmall
						autoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin)];
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

@end
