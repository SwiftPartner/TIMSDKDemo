//
//  TextMessageContent.m
//  TIMKitDemo
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "TextMessageContent.h"
#import "MessageContent.h"

@implementation TextMessageContent

- (instancetype)initWithText:(NSString *)text {
    if(self = [super init]) {
        self.type = MessageTypeText;
        self.text = text;
    }
    return self;
}

@end
