//
//  Mocoga.h
//  Mocoga Publisher SDK
//	Version 1.0.2
//
//  Created by dev@mocoga.com Mocoga Development Team on 12. 8. 27.
//  Copyright (c) 2012 Mocoga, nTels Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MocogaDelegate;

enum {
    MocogaOfferConSizeSmall     = 0,	// iPhone 40x40, iPad 80x80
    MocogaOfferConSizeNormal	= 1,	// iPhone 60x60, iPad 100x100
    MocogaOfferConSizeLarge     = 2		// iPhone 80x80, iPad 120x120
};
typedef NSUInteger MocogaOfferConSize;

@interface Mocoga : NSObject

/** @name Class Methods */

/** Mocoga SDK 에서 제공하는 메소드를 사용하기 위한 instance 를 반환합니다.
 
 Singleton Class를 사용합니다.
 */
+ (Mocoga *)shared;

/** @name Instance Methods */

/** Mocoga SDK를 실제로 사용하기 위하여 App ID와 Secret Key를 설정합니다.
 
 http://dashboard.mocoga.com 에서 앱의 App ID와 Secret Key를 확인하여 파라미터로 넘겨주면 Mocoga SDK 사용을 위한 초기화가 진행됩니다.
 
 @param appID 해당 앱의 App ID
 @param secretKey 해당 앱의 Secret Key
 @param delegate MocogaDelegate 를 받을 delegate 설정
 @see getAppId
 @see getSecretKey
 */
- (void)initAppID:(NSString *)appID secretKey:(NSString *)secretKey delegate:(id)targetDelegate;

/** Mocoga SDK를 사용중인 현재 앱의 App ID를 반환합니다.
 
 Mocoga SDK를 사용중인 현재 앱의 App ID를 반환합니다.
 
 @return 해당 App 의 App ID
 @see initAppID:secretKey:delegate:
 */
- (NSString *)getAppID;

/** Mocoga SDK를 사용중인 현재 앱의 Secret Key를 반환합니다.
 
 Mocoga SDK를 사용중인 현재 앱의 Secret Key를 반환합니다.
 
 @return 해당 앱의 Secret Key string 객체
 @see initAppID:secretKey:
 */
- (NSString *)getSecretKey;

/** Mocoga SDK를 사용중인 현재 앱에 User ID를 설정합니다.
 
 Mocoga SDK를 사용중인 현재 앱에 User ID를 설정합니다.
 가상화폐를 서버에서 관리하시는 경우, showOfferConAtPoint 호출 전에 setUserID 를 호출해야 합니다.
 가상화폐를 클라이언트에서 관리하시는 경우, setUserID 를 사용하지 않습니다.
 
 @param userID 보상을 지급할 User ID
 @see getUserID
 */
- (void)setUserID:(NSString *)userID;

/** Mocoga SDK를 사용중인 현재 앱의 User ID를 반환합니다.
 
 Mocoga SDK를 사용중인 현재 앱의 User ID를 반환합니다.
 
 @return 해당 앱의 User ID
 @see setUserID:
 */
- (NSString *)getUserID;

/** OfferCon의 위치를 지정하고 사이즈를 정하여 OfferCon을 보여줍니다.
 
 @param point OfferCon 위치
 @param size OfferCon 크기
 @see showOfferConAtPoint:size:autoresizingMask:
 @see hideOfferCon
 */
- (void)showOfferConAtPoint:(CGPoint)point size:(MocogaOfferConSize)size;

/** OfferCon의 위치를 지정하고 사이즈를 정하여 OfferCon을 보여줍니다.
 
 화면 회전시 OfferCon 의 위치를 자동으로 조정할 수 있는 옵션을 제공합니다.
 
 @param point OfferCon 위치
 @param size OfferCon 크기
 @param autoresizing OfferCon 뷰의 Auto resizing 속성, UIViewAutoresizingFlexibleLeftMargin/UIViewAutoresizingFlexibleRightMargin/UIViewAutoresizingFlexibleTopMargin/UIViewAutoresizingFlexibleBottomMargin 사용 가능
 @see showOfferConAtPoint:size:
 @see hideOfferCon
 */
- (void)showOfferConAtPoint:(CGPoint)point size:(MocogaOfferConSize)size autoresizingMask:(UIViewAutoresizing)autoresizing;

/** OfferCon을 화면에서 숨깁니다.
 
 @see showOfferConAtPoint:size:
 @see showOfferConAtPoint:size:autoresizingMask:
 */
- (void)hideOfferCon;

/** Mocoga에 보상 지급했음을 알립니다.
 
 가상화폐를 클라이언트에서 관리하시는 경우에만 사용합니다.
 주로 mocogaRequestsToGiveReward:withInfo Delegate 안에서 보상을 지급한 뒤에 호출합니다.

 @param rewardTransId 보상건에 대한 공유한 ID 값, mocogaRequestsToGiveReward:withInfo Delegate 에서 받은 rewardTransId 인자값을 사용
 @see mocogaRequestsToGiveReward:withInfo:
 */
- (void)didGiveReward:(NSString *)rewardTransId;

@end

/** @name Mocoga Delegate */

@protocol MocogaDelegate <NSObject>
@optional

/** 사용자가 OfferCon을 클릭하여 OfferView가 나타날때 호출됩니다.
 
 게임의 경우, 게임을 일시정지하는 코드를 넣을 수 있습니다.
 
 @see mocogaDidHideOfferView:
 */
- (void)mocogaWillShowOfferView;

/** OfferView가 닫힌 후에 호출됩니다.
 
 게임의 경우, 게임을 재개하는 코드를 넣을 수 있습니다.
 
 @see mocogaDidHideOfferView:
 */
- (void)mocogaDidHideOfferView;

/** 사용자에게 보상을 해야하는 경우 호출됩니다.
 
 가상화폐를 클라이언트에서 관리하시는 경우에만 호출되는 Delegate 입니다.

 @param rewardTransId 보상건에 대한 공유한 ID 값, didGiveReward 메소트 호출시 사용
 @param rewardInfo 보상해야 하는 reward 정보. @"reward_id", @"reward_amount" 키 값
 @see didGiveReward:
 */
- (void)mocogaRequestsToGiveReward:(NSString *)rewardTransId withInfo:(NSDictionary *)rewardInfo;

/** 보상지급이 이루어진 뒤에, 가상화폐 UI를 업데이트할 시점을 알려주기 위해 호출됩니다.
 
 가상화폐를 서버에서 관리하시는 경우에만 호출되는 Delegate 입니다.
 */
- (void)mocogaUpdateCurrency;

@end


