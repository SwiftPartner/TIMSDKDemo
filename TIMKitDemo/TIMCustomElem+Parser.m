//
//  TIMCustomElem+Parser.m
//  TIMKitDemo
//
//  Created by ryan on 2019/10/18.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "TIMCustomElem+Parser.h"
#import <MJExtension/MJExtension.h>

@implementation TIMCustomElem (Parser)

- (nullable MessageContent *)parse {
    NSError *error;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        return nil;
    }
    MessageContent *messageContent = [MessageContent mj_objectWithKeyValues:jsonObj];
    if(!messageContent || messageContent.type == MessageTypeUnknown) {
        return nil;
    }
    return messageContent;
}

@end
