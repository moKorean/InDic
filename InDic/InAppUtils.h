//
//  InAppUtils.h
//  EventsList
//
//  Created by 모근원 on 11. 11. 10..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern NSString* const _IN_APP_DONATE_01_ITEM_DOMAIN;
extern NSString* const _IN_APP_DONATE_02_ITEM_DOMAIN;
extern NSString* const _IN_APP_DONATE_03_ITEM_DOMAIN;

@interface InAppUtils : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    
    BOOL canMakePurchase;
    BOOL sendPurchase;
    
    id caller;
    
    CGRect windowSize;
    
    NSString* lastCalledProductId;
    
    NSString* currentPurchaseItemDomain;
}

+(InAppUtils*) sharedInAppUtils;

@property (nonatomic, strong) id caller;
@property (nonatomic, strong) UIActivityIndicatorView * spinner;
@property (nonatomic, strong) UIView *maskView;

/////////////// 구매 버튼
-(void)openInstructionForItem:(NSString*)_iTemDomain withCaller:(id)_caller withOptionalPreMsg:(NSString*)_preMsg;
-(void)callInApp;
-(void)cancelInApp;


///////////////////////////////////////////////////////////////////////////

-(BOOL)isCanMakePurchase;
-(BOOL)checkAvilableToPurchase;

//결재 요청!!!
- (void) requestMakePurchaseWithProductId:(NSString*)_productId withCaller:(id)_caller;

- (void)makeInAppPurchaseWithProduct:(SKProduct*)_product;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

-(void)loadingStart;
-(void)loadingEnd;

//-(void)terminateTransaction;

@end


@protocol InAppUtilsDelegate <NSObject>

@optional
-(void)onFailurePurchaseWithProductId:(NSString*)_productId; //실패. 결재단계시 취소도 포함
-(void)onSuccessPurchaseWithProductId:(NSString*)_productId;    //결재 성공
-(void)onRestoredWithProductId:(NSString*)_productId;    //복구 성공 (결재버튼을 통한 복구가 아닌 복구 모드로 들어왔을때임) * 현재 어플에선 사용안함.
-(void)onCancelPurchaseWithProductId:(NSString*)_productId; //처음 결재안내 나온 후 취소버튼

@end
