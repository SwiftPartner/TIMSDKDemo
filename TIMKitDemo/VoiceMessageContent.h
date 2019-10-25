//
//  VoiceMessageElement.h
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "MessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoiceMessageContent : MessageContent

@property (assign) long dataSize;
@property(nonatomic,assign) long second;

+ (instancetype)contentWithDataSize:(long)dataSize second:(long)second;

@end

NS_ASSUME_NONNULL_END
