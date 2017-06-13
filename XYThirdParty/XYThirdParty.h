//
//  XYThirdParty.h
//  XYCategories
//
//  Created by xyzhenu on 2017/6/8.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#ifndef XYThirdParty_h
#define XYThirdParty_h

#define View(__TAG__) [theView viewWithTag:__TAG__]
#define Label(__TAG__) ((UILabel*)[theView viewWithTag:__TAG__])
#define Image(__TAG__) ((UIImageView*)[theView viewWithTag:__TAG__])
#define Button(__TAG__) ((UIButton*)[theView viewWithTag:__TAG__])

#define LabelCreate(__TAG__) UILabel* label_##__TAG__ = [[UILabel alloc] init];\
label_##__TAG__.tag = __TAG__;\
[theView addSubview:label_##__TAG__];

#define ImageCreate(__TAG__) UIImageView* image_##__TAG__ = [[UIImageView alloc] init];\
image_##__TAG__.tag = __TAG__;\
image_##__TAG__.contentMode = UIViewContentModeCenter;\
[theView addSubview:image_##__TAG__];

#define ViewCreate(__TAG__) UIView* view##__TAG__ = [[UIView alloc] init];\
view_##__TAG__.tag = __TAG__;\
[theView addSubview:view_##__TAG__];


#endif /* XYThirdParty_h */
