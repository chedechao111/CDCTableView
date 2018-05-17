//
//  CDTableView.h
//  CDTableViewTest
//
//  Created by chedechao on 2017/7/20.
//  Copyright © 2017年 chedechao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDTableView,CDTableViewCell;

@protocol CDTableViewDataSource <NSObject>

@required

- (NSInteger)cdtableView:(CDTableView *)cdtableView numberOfRowsInSection:(NSInteger)section;

- (CDTableViewCell *)cdtableView:(CDTableView *)cdtableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol CDTableViewDelegate <NSObject>

- (CGFloat)cdtableView:(CDTableView *)cdtableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CDTableView : UIScrollView 

@property (nonatomic, weak) id<CDTableViewDataSource> cdDataSource;
@property (nonatomic, weak) id<CDTableViewDelegate> cdDelegate;
@property (nonatomic) CGFloat rowHeight;

- (void)setUpCell;
- (CDTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
