//
//  MessageElement.m
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "MessageContent.h"
#import "VoiceMessageContent.h"
#import "TextMessageContent.h"
#import <MJExtension/MJExtension.h>

@implementation MessageContent

- (nullable instancetype)initWithJson:(NSString *)json {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [self initWithData:data];
}

- (nullable instancetype)initWithData:(NSData *)data {
    if(!data) {
        return nil;
    }
    NSError *error;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        return nil;
    }
    if(![jsonObj isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSDictionary *contentDic = (NSDictionary *)jsonObj;
    if(![contentDic.allKeys containsObject:@"type"]) {
        return nil;
    }
    long type = [contentDic[@"type"] longValue];
    switch (type) {
        case MessageTypeVoice:
            return [VoiceMessageContent mj_objectWithKeyValues:data];
        case MessageTypeText:
            return [TextMessageContent mj_objectWithKeyValues:data];
        default:
            return  nil;
    }
}

- (NSString *)jsonString {
    return self.mj_JSONString;
}

- (NSData *)jsonData {
    return self.mj_JSONData;
}


- (NSArray *)mj_ignoredPropertyNames {
    return @[@"path"];
}

@end
