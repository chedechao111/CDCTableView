//
//  CDTableViewCell.m
//  CDTableViewTest
//
//  Created by chedechao on 2017/7/20.
//  Copyright © 2017年 chedechao. All rights reserved.
//

#import "CDTableViewCell.h"

@implementation CDTableViewCell {
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:(arc4random() % 255)/255.0 alpha:1.0];
        UIView *test = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
        test.backgroundColor = [UIColor greenColor];
        [self addSubview:test];
        
        UIView *sepatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        sepatorLine.backgroundColor = [UIColor grayColor];
        [self addSubview:sepatorLine];
        
        
    }
    return self;
}

-(void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    
    [_label removeFromSuperview];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 100, 20)];
    _label.text = [NSString stringWithFormat:@"%ld",_indexPath.row];
    [self addSubview:_label];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ip:%d, frame:%@", (int)self.indexPath.row, NSStringFromCGRect(self.frame)];
}

@end
