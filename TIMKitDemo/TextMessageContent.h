//
//  TextMessageContent.h
//  TIMKitDemo
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextMessageContent : MessageContent

@property(nonatomic, copy) NSString* text;

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
