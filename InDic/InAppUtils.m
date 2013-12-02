//
//  InAppUtils.m
//  EventsList
//
//  Created by 모근원 on 11. 11. 10..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import "InAppUtils.h"

NSString* const _IN_APP_DONATE_01_ITEM_DOMAIN = @"com.lomohome.InDic.donate.01";
NSString* const _IN_APP_DONATE_02_ITEM_DOMAIN = @"com.lomohome.InDic.donate.03";
NSString* const _IN_APP_DONATE_03_ITEM_DOMAIN = @"com.lomohome.InDic.donate.04";


@implementation InAppUtils
@synthesize caller;
@synthesize maskView,spinner;

static InAppUtils* _sharedInAppUtils = nil;

+(InAppUtils*) sharedInAppUtils{
    @synchronized(self)     {
		if (!_sharedInAppUtils){
			_sharedInAppUtils = [[self alloc] init];
		}
		return _sharedInAppUtils;
	}
    
	return nil; //요건 그냥 컴파일러 에러 방지용.
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSLog(@"########### IN APP UTILS 초기화");
        // setting 에서 데이터 가져와서 셋팅해준다.
        canMakePurchase = [self checkAvilableToPurchase];
        sendPurchase = NO;
    }
    
    return self;
}


#pragma mark InAppUtils-INIT

-(BOOL)checkAvilableToPurchase{
    if ([SKPaymentQueue canMakePayments]) {
        //Can purchase, diaplay a store to the user
        //스토어 사용가능
        
        //상품결제 진행에 따른 결과 델리게이트 발생 시킴.
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        return YES;
    } else {
        //Warn the use that purchases are disabled.
        //스토어 사용 불가능.
        return NO;
    }
}


-(BOOL)isCanMakePurchase{
    return canMakePurchase;
}


-(void)loadingStart{
//    
//    NSLog(@"loading start inapp : %@ (%@)",[self.maskView superview],([self.maskView superview] == nil?@"isNULLok":@"notNULL"));
    
    if (self.maskView == nil && [self.maskView superview] == nil){
        NSLog(@"we make loading screen");
        //화면스피너 셋팅. 로딩중을 표시하기 위함.
        windowSize = [[UIScreen mainScreen] bounds];
//        NSLog(@"windowSize = %f, %f",windowSize.size.width,windowSize.size.height);
        self.maskView = [[UIView alloc] initWithFrame:windowSize];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0.5f;
        
//        NSLog(@"keyWindow subvies : %@",[[[[UIApplication sharedApplication] delegate] window] subviews].description);
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.maskView];
//        NSLog(@"KEY WINDOW MASK 추가 성공");
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setCenter:CGPointMake(windowSize.size.width/2.0, windowSize.size.height/2.0)]; //화면중간에 위치하기위한 포인트.
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.spinner];
//        NSLog(@"KEY WINDOW SPINNER 추가 성공");
        
//        NSLog(@"keyWindow subvies : %@",[[[[UIApplication sharedApplication] delegate] window] subviews].description);
        
        [self.spinner startAnimating];
        
        //10초가 지나면 네트웍 오류로 취소 시킨다.
        //[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(terminateTransaction) userInfo:nil repeats:NO];
    }
    
    
#if TEST_MODE_DEVICE_LOG    
    else {
        NSLog(@"already exist loading screen");
    }
#endif
    
//    NSLog(@"maskView superview  : %@ (%@)",[self.maskView superview],([self.maskView superview] == nil?@"isNULLok":@"notNULL"));
    
}

-(void)loadingEnd{
    
//    NSLog(@"loading end inapp : %@ (%@)",[self.maskView superview],([self.maskView superview] == nil?@"isNULLok":@"notNULL"));
    if (self.maskView != nil && [self.maskView superview] != nil){
        self.maskView.hidden = YES;
        [self.spinner stopAnimating];
        
        [self.spinner removeFromSuperview];
        [self.maskView removeFromSuperview];
//        NSLog(@"keyWindow subvies : %@",[[[[UIApplication sharedApplication] delegate] window] subviews].description);
        
        self.spinner = nil;
        self.maskView = nil;
    }
    
//    NSLog(@"maskView superview  : %@ (%@)",[self.maskView superview],([self.maskView superview] == nil?@"isNULLok":@"notNULL"));
}

//-(void)terminateTransaction{
//    
//        if([caller respondsToSelector:@selector(onFailurePurchase:)]){
//            [caller onFailurePurchase:@"NETWORK ERROR"];
//        }
//        [self loadingEnd];
//    
//}


#pragma mark 결재 딜리게이트 (SKProductsRequestDelegate)

/*
 * 상품 정보 유무 확인시 사용.
 * 이 메소드 보내서 상품을 확인하게 되면
 - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response 
 를 호출한다.
 */
- (void) requestMakePurchaseWithProductId:(NSString*)_productId withCaller:(id)_caller
{ 
    caller = _caller;
    sendPurchase = YES;
    lastCalledProductId = _productId;

    NSLog(@"requestMakePurchaseWithProductId : %@",_productId);
    

    //purchase
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject:_productId]];
    request.delegate = self;
    [request start];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(loadingStart) userInfo:nil repeats:NO];
    
} 

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response 
{ 
    NSLog(@"SKProductsResponse got response : product count : %d (%@)",[response.products count],lastCalledProductId);
    
    if([response.products count] > 0 && sendPurchase){
        SKProduct* product = [response.products objectAtIndex:0];
        NSLog(@"### Product Title : %@",product.localizedTitle);
        NSLog(@"### Product Description : %@",product.localizedDescription);
        NSLog(@"### Product Price : %@",product.price);
        
        NSLog(@"send request make a purchase");
        [self makeInAppPurchaseWithProduct:product];
    } 
#if TEST_MODE_DEVICE_LOG    
    
        NSLog(@"################### DEBUG MODE - in-App Product List Start ######################");
        
        for (SKProduct* _product in response.products) {
            NSLog(@"####################################################################");
            NSLog(@"### Product Title : %@",_product.localizedTitle);
            NSLog(@"### Product Description : %@",_product.localizedDescription);
            NSLog(@"### Product Price : %@",_product.price);
            NSLog(@"####################################################################");
        }
        
        NSLog(@"################### DEBUG MODE - in-App Product List End ######################");
    
#endif
    
    NSLog(@"invalidProductIdentifiers count : %d",[response.invalidProductIdentifiers count]);
    if([response.invalidProductIdentifiers count] > 0){
        NSString* invalidString = [response.invalidProductIdentifiers objectAtIndex:0];
        NSLog(@"Invalid Identifiers : %@",invalidString);
        
        if([caller respondsToSelector:@selector(onFailurePurchaseWithProductId:)]){
            [caller onFailurePurchaseWithProductId:invalidString];
        }
        [self loadingEnd];
            
        
    }
    
    sendPurchase = NO;
    
    //NSArray *myProduct = response.products; 
    //    // populate UI 
    //    [request autorelease]; 
    
    //[self makeInAppPurchaseWithProduct:myProduct];
}

//실제 구매 요청 액션
- (void)makeInAppPurchaseWithProduct:(SKProduct*)_product{
    //    SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"com.lomohome.eventsList.donated01"]; 
    //    [[SKPaymentQueue defaultQueue] addPayment:payment];
    NSLog(@"request makeInAppPurchaseWithProduct : %@, (type : %@)",_product,lastCalledProductId);
    
//    if ([lastCalledProductId isEqualToString:_IN_APP_RESTORE_PLUS_PACK_ITEM_DOMAIN]){
//        
//        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//    } else {
    
        SKPayment *payment = [SKPayment paymentWithProduct:_product];
        //    payment.quantity = 1;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
//    }
    
}

#pragma mark 결재결과 딜리게이트 (SKPaymentTransactionObserver)
//서버로부터 결재결과 받음
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions 
{
    NSLog(@"receive in-app result from apple server , transactions : %@",transactions);
    
    for (SKPaymentTransaction *transaction in transactions) 
    {
        NSLog(@"💰💰💰 transaction.transactionState : %d",transaction.transactionState);
        switch (transaction.transactionState) 
        { 
            case SKPaymentTransactionStatePurchased: 
                [self completeTransaction:transaction]; 
                break; 
            case SKPaymentTransactionStateFailed: 
                [self failedTransaction:transaction]; 
                break; 
            case SKPaymentTransactionStateRestored: 
                [self restoreTransaction:transaction]; 
            default: 
                break; 
        } 
    } 
    
}

//결재 성공
- (void) completeTransaction: (SKPaymentTransaction *)transaction 
{ 
    // Your application should implement these two methods. 
    //생략가능 [self recordTransaction: transaction]; 
    //생략가능 [self provideContent: transaction.payment.productIdentifier]; 
    // Remove the transaction from the payment queue. 
    
    NSLog(@"completeTransaction");
    NSLog(@"Transaction Identifier : %@",transaction.transactionIdentifier);
    NSLog(@"Transaction Date : %@",transaction.transactionDate);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if([caller respondsToSelector:@selector(onSuccessPurchaseWithProductId:)])
        [caller onSuccessPurchaseWithProductId:transaction.payment.productIdentifier];
    
    [self loadingEnd];

}
//복구 성공
- (void) restoreTransaction: (SKPaymentTransaction *)transaction 
{ 
    //생략 가능[self recordTransaction: transaction]; 
    //생략가능 [self provideContent: transaction.originalTransaction.payment.productIdentifier]; 
    NSLog(@"restoreTransaction");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if([caller respondsToSelector:@selector(onRestoredWithProductId:)])
        [caller onRestoredWithProductId:transaction.payment.productIdentifier];
    
    [self loadingEnd];

}
//결재 실패
- (void) failedTransaction: (SKPaymentTransaction *)transaction 
{
    /*
     0 SKErrorUnknown,
     1 SKErrorClientInvalid,               // client is not allowed to issue the request, etc.
     2 SKErrorPaymentCancelled,            // user cancelled the request, etc.
     3 SKErrorPaymentInvalid,              // purchase identifier was invalid, etc.
     4 SKErrorPaymentNotAllowed,           // this device is not allowed to make the payment
     5 SKErrorStoreProductNotAvailable,    // Product is not available in the current storefront
     */
    NSLog(@"failedTransaction : %d,%@",transaction.error.code,transaction.error.description);
    
    if (transaction.error.code != SKErrorPaymentCancelled) 
    { 
        // Optionally, display an error here.
        NSString* failDesc = nil;
        if (transaction.error.localizedDescription) {
            failDesc = transaction.error.localizedDescription;
        } else {
            failDesc = NSLocalizedString(@"fail purchase", nil);
        }
        
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:nil message:failDesc delegate:nil cancelButtonTitle:NSLocalizedString(@"confirm", nil) otherButtonTitles:nil, nil];
        [failAlert show];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
    if([caller respondsToSelector:@selector(onFailurePurchaseWithProductId:)]){
        [caller onFailurePurchaseWithProductId:transaction.payment.productIdentifier];
    }
    
    [self loadingEnd];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"restoreCompletedTransactionsFailedWithError : %@",error.description);
    
    if([caller respondsToSelector:@selector(onFailurePurchaseWithProductId:)]){
        [caller onFailurePurchaseWithProductId:lastCalledProductId];
    }
    
    [self loadingEnd];
    
}


#pragma mark inAppUtil

-(void)openInstructionForItem:(NSString*)_iTemDomain withCaller:(id)_caller withOptionalPreMsg:(NSString*)_preMsg{
    NSString* _msg;
    if (_caller == nil || _iTemDomain == nil) return;
    
    currentPurchaseItemDomain = _iTemDomain;
    caller = _caller;
    
    if ([currentPurchaseItemDomain isEqualToString:_IN_APP_DONATE_01_ITEM_DOMAIN]){
        _msg = [NSString stringWithFormat:NSLocalizedString(@"donate inst for donate", nil),@"$0.99"];
    } else if ([currentPurchaseItemDomain isEqualToString:_IN_APP_DONATE_02_ITEM_DOMAIN]){
        _msg = [NSString stringWithFormat:NSLocalizedString(@"donate inst for donate", nil),@"$2.99"];
    } else if ([currentPurchaseItemDomain isEqualToString:_IN_APP_DONATE_03_ITEM_DOMAIN]){
        _msg = [NSString stringWithFormat:NSLocalizedString(@"donate inst for donate", nil),@"$4.99"];
    } else {
        return;
    }
    
    if (_preMsg != nil) {
        _msg = [NSString stringWithFormat:@"%@\n\n%@",_preMsg,_msg];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:_msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"confirm", nil),nil] ;
    alertView.tag = 99884;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99884) {
        if (buttonIndex == 1) {
            [self callInApp];
        } else {
            [self cancelInApp];
        }
    }
}

-(void)callInApp{
    NSLog(@"CALL IN APP");
    if (caller == nil) return;
    
    [self requestMakePurchaseWithProductId:currentPurchaseItemDomain withCaller:caller];
    
}

-(void)cancelInApp{
    NSLog(@"CANCEL IN APP");
    if (caller == nil) return;
    if([caller respondsToSelector:@selector(onCancelPurchaseWithProductId:)])
        [caller onCancelPurchaseWithProductId:currentPurchaseItemDomain];
    
}

@end
