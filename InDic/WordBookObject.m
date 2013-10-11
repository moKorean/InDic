//
//  WordBookObject.m
//  InDic
//
//  Created by moKorean on 13. 10. 11..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "WordBookObject.h"

@implementation WordBookObject

@synthesize addDate,word,priority,idx;

-(id)init{
    self = [super init];
    if (self){
        //init
        self.addDate = [NSDate date];
        self.word = nil;
        self.priority = 0;
        self.idx = -1;
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.addDate forKey:@"addDate"];
    [coder encodeObject:self.word forKey:@"word"];
    [coder encodeInteger:self.priority forKey:@"priority"];
    [coder encodeInteger:self.idx forKey:@"idx"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [super init];
    if (self != nil)
    {
        self.addDate = [coder decodeObjectForKey:@"addDate"];
        self.word =[coder decodeObjectForKey:@"word"];
        self.priority = [coder decodeIntegerForKey:@"priority"];
        self.idx = [coder decodeIntegerForKey:@"idx"];
    }
    return self;
}

@end
