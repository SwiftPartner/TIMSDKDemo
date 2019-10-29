//
//  ImageMessageContent.h
//  TIMKitDemo
//
//  Created by ryan on 2019/10/25.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "MessageContent.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageMessageContent : MessageContent

@property(assign, nonatomic) NSInteger width;
@property(assign, nonatomic) NSInteger height;

+ (instancetype)contentWithImage:(UIImage *) image;



@end

NS_ASSUME_NONNULL_END
