//
//  Mocoga.h
//  Mocoga SDK
//
//  Created by Mocoga Development Team on 5/5/12.
//  Copyright (c) 2012 Mocoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MocogaDelegate;

enum {
    MocogaOfferConSizeSmall     = 0,	// iphone 40x40, ipad 80x80
    MocogaOfferConSizeNormal	= 1,	// iphone 60x60, ipad 100x100
    MocogaOfferConSizeLarge     = 2		// iphone 80x80, ipad 120x120
};

typedef NSUInteger MocogaOfferConSize;

@interface Mocoga : NSObject

///---------------------------------------------------------------------------------------
/// @name 초기화 메서드
///---------------------------------------------------------------------------------------

/** Mocoga SDK를 실제로 사용하기 위하여 앱 아이디와 시크릿키를 설정합니다.
 
 이 메서드는 Mocoga SDK를 사용하기 위하여 구현하기 위한 초기화 메서드입니다. dashboard에서 개발사의 해당 App ID와 Secret Key를 확인하여 파라미터로 넘겨주면 Mocoga SDK 사용을 위한 초기화가 진행됩니다.
 
 @param appID Mocoga SDK를 사용하기 위하여 등록한 해당 App의 ID 객체
 @param secretKey Mocoga SDK를 사용하기 위하여 등록한 해당 App의 Secret Key 객체
 @see getAppId
 @see getSecretKey
 */
- (void)initAppID:(NSString *)appID secretKey:(NSString *)secretKey delegate:(id)targetDelegate;

///---------------------------------------------------------------------------------------
/// @name 접근자
///---------------------------------------------------------------------------------------

/** Mocoga SDK를 사용중인 현재 앱의 App ID를 반환합니다.
 
 이 접근자는 Mocoga SDK를 사용중인 현재 앱의 App ID를 반환합니다.
 
 @return 해당 앱의 App ID string 객체
 @see initAppID:secretKey:
 */
- (NSString *)getAppID;

/** Mocoga SDK를 사용중인 현재 앱의 Secret Key를 반환합니다.
 
 이 접근자는 Mocoga SDK를 사용중인 현재 앱의 Secret Key를 반환합니다.
 
 @return 해당 앱의 Secret Key string 객체
 @see initAppID:secretKey:
 */
- (NSString *)getSecretKey;

/** Mocoga SDK를 사용중인 현재 앱에 User ID를 설정합니다.
 
 이 접근자는 Mocoga SDK를 사용중인 현재 앱에 User ID를 설정합니다.
 
 @param userID 보상을 지급할 User ID
 @see getUserID
 */
- (void)setUserID:(NSString *)userID;

/** Mocoga SDK를 사용중인 현재 앱의 User ID를 반환합니다.
 
 이 접근자는 Mocoga SDK를 사용중인 현재 앱의 User ID를 반환합니다.
 
 @return 해당 앱의 User ID 객체
 @see setUserID:
 */
- (NSString *)getUserID;

///---------------------------------------------------------------------------------------
/// @name 오퍼콘 설정
///---------------------------------------------------------------------------------------

/** 오퍼콘의 위치를 지정하고 사이즈를 정하여 오퍼콘을 보여줍니다.
 
 이 메서드는 오퍼콘의 위치를 지정하고 사이즈를 정하여 오퍼콘을 보여줍니다.
 
 @param point 오퍼콘 위치
 @param size 오퍼콘 크기
 @see showOfferConAtPoint:size:autoresizingMask:
 @see hideOfferCon
 */
- (void)showOfferConAtPoint:(CGPoint)point size:(MocogaOfferConSize)size;

/** 오퍼콘의 위치를 지정하고 사이즈를 정하여 오퍼 아이콘을 보여줍니다.
 
 이 메서드는 오퍼콘의 위치를 지정하고 사이즈를 정하여 오퍼콘을 보여줍니다.
 
 @param point 오퍼콘 위치
 @param size 오퍼콘 크기
 @param autoresizing 아이콘의 Auto resizing 속성
 @see showOfferConAtPoint:size:
 @see hideOfferCon
 */
- (void)showOfferConAtPoint:(CGPoint)point size:(MocogaOfferConSize)size autoresizingMask:(UIViewAutoresizing)autoresizing;

/** 오퍼콘의 위치를 지정하고 사이즈를 정하여 오퍼콘을 보여줍니다.
 
 이 메서드는 오퍼콘의 위치를 지정하고 사이즈를 정하여 오퍼콘을 보여줍니다.
 
 @see showOfferConAtPoint:size:
 @see showOfferConAtPoint:size:autoresizingMask:
 */
- (void)hideOfferCon;

- (void)didGiveReward:(NSString *)rewardTransId;

+ (Mocoga *)shared;

@property (nonatomic, assign) id delegate;

@end

@protocol MocogaDelegate <NSObject>
@optional

- (void)mocogaWillShowOfferView;
- (void)mocogaDidHideOfferView;

// Delegate for Client Callback
- (void)mocogaRequestsToGiveReward:(NSString *)rewardTransId withInfo:(NSDictionary *)rewardInfo;

// 서버 Callback 방식이고, 비디오뷰가 완료되었을때, Point 를 업데이트할 기회를 준다.
// 서버 Callback 방식이고, Publisher 에서 직접 설치확인을 하게되는 경우, 역시 이거를 불러 Point 를 업데이트할 기회를 준다.
- (void)mocogaUpdateCurrency;

@end


