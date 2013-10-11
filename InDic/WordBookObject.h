//
//  WordBookObject.h
//  InDic
//
//  Created by moKorean on 13. 10. 11..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordBookObject : NSObject

@property (nonatomic, assign)   int idx;
@property (nonatomic, strong)   NSString* word;
@property (nonatomic, strong)   NSDate* addDate;
@property (nonatomic, assign)   int priority;

@end
