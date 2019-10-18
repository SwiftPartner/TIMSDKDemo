//
//  TIMCustomElem+Parser.h
//  TIMKitDemo
//
//  Created by ryan on 2019/10/18.
//  Copyright © 2019 windbird. All rights reserved.
//
#import <ImSDK/ImSDK.h>
#import "MessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIMCustomElem (Parser)

- (nullable MessageContent *)parse;

@end

NS_ASSUME_NONNULL_END
