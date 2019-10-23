//
//  VoiceMessageElement.m
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "VoiceMessageContent.h"
#import <MJExtension/MJExtension.h>

@implementation VoiceMessageContent

+ (instancetype)contentWithDataSize:(long)dataSize second:(long)second {
    VoiceMessageContent *content = [VoiceMessageContent new];
    content.type = MessageTypeVoice;
    content.dataSize = dataSize;
    content.second = second;
    return content;
}

@end
