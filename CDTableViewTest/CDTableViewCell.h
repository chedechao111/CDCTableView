//
//  CDTableViewCell.h
//  CDTableViewTest
//
//  Created by chedechao on 2017/7/20.
//  Copyright © 2017年 chedechao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDTableViewCell : UIView

@property (nonatomic, copy) NSString *reuserId;
@property (nonatomic, strong) NSIndexPath *indexPath;


@end
