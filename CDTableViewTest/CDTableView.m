//
//  CDTableView.m
//  CDTableViewTest
//
//  Created by chedechao on 2017/7/20.
//  Copyright © 2017年 chedechao. All rights reserved.
//

#import "CDTableView.h"
#import "CDTableViewCell.h"

static NSString *const kContentKeyPath = @"contentOffsetY";

@implementation CDTableView {
    NSInteger _cellSumCount;
    NSMutableArray *_visibleCellArr;
    CDTableViewCell *_cell;
    NSMutableSet *_cellCachePool;
    NSMutableDictionary *_cellFrameDict;
    CGFloat _lastRowHeight;
    CGFloat _lastOffsetY;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cellSumCount = 0;
        _lastRowHeight = 0;
        _cell = nil;
        _visibleCellArr = [NSMutableArray array];
        _cellCachePool = [NSMutableSet set];
        _cellFrameDict = [NSMutableDictionary dictionary];
        _lastOffsetY = 0;
    }
    return self;
}

- (void)dealloc {
    _cellCachePool = nil;
    _visibleCellArr = nil;
    _cellFrameDict = nil;
}

#pragma mark - delegate & datasource 返回的数据
- (void)getCellSumCounts {
    if (_cdDataSource && [_cdDataSource respondsToSelector:@selector(cdtableView:numberOfRowsInSection:)]) {
        _cellSumCount = [_cdDataSource cdtableView:self numberOfRowsInSection:0];
    }
}

- (void)getCellWithIndexPath:(NSIndexPath *)indexPath {
    if (_cdDataSource && [_cdDataSource respondsToSelector:@selector(cdtableView:cellForRowAtIndexPath:)]) {
        _cell = [_cdDataSource cdtableView:self cellForRowAtIndexPath:indexPath];
    }
    _cell.indexPath = indexPath;
    _cell.frame = [[_cellFrameDict objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] CGRectValue];
    [self addSubview:_cell];
}

- (CGFloat)getRowHeightWithIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 44;
    if (_cdDelegate && [_cdDelegate respondsToSelector:@selector(cdtableView:heightForRowAtIndexPath:)]) {
        rowHeight = [_cdDelegate cdtableView:self heightForRowAtIndexPath:indexPath];
    }
    return rowHeight;
}
#pragma mark -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//是否超出屏幕
- (BOOL)isInViewWithCellFrame:(CGRect)cellFrame {
    return cellFrame.origin.y > self.frame.size.height ? NO : YES;
}

//初始化cell根据屏幕高度和cell的高度决定初始化cell的个数
- (void)setUpCell {
    
    CGRect cellFrame = CGRectZero;
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
    [self getCellSumCounts];
    @autoreleasepool {
        for (NSInteger i = 0 ; i < _cellSumCount; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            CGFloat rowHeight = [self getRowHeightWithIndexPath:indexPath];
            cellFrame = CGRectMake(0, _lastRowHeight, cellWidth, rowHeight);
            [_cellFrameDict setObject:[NSValue valueWithCGRect:cellFrame] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            
            if ([self isInViewWithCellFrame:cellFrame] == YES) {
                [self getCellWithIndexPath:indexPath];
                [_visibleCellArr addObject:_cell];
            }
            _lastRowHeight += rowHeight;
        }
    }
    self.contentSize = CGSizeMake(cellWidth, _lastRowHeight);
}
//从缓冲池中拿cell
- (CDTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    
    CDTableViewCell *cell = nil;
    if (_cellCachePool && _cellCachePool.count > 0) {
        cell = [_cellCachePool anyObject];
    
        if (identifier && [identifier isEqualToString:cell.reuserId]) {
            [_cellCachePool removeObject:cell];
        }
    }
    return cell;
}
// 去除一个cell 添加到缓冲池
- (void)recycleOldCell:(NSInteger )index toCacheWithObject:(CDTableViewCell *)cell {
    [_visibleCellArr removeObjectAtIndex:index];
    [_cellCachePool addObject:cell];
    [cell removeFromSuperview];
}


- (void)downRecycleCellFromIndex:(NSInteger)indexFrom toIndex:(NSInteger) indexTo withCurrentOffsetY:(CGFloat)currentOffsetY{

    //下拉
    if (currentOffsetY < _lastOffsetY ) {
        
        CDTableViewCell *endCell = _visibleCellArr.firstObject;
        //下拉到第一个截至
        if (endCell.indexPath.row == 0) {
            return;
        }
        
        NSInteger markIndex = indexTo;
        for (NSInteger i = _visibleCellArr.count - 1; i >= 0; i--) {
            //下拉 尾部cell移除
            CDTableViewCell *cell = (CDTableViewCell *)_visibleCellArr[i];
            //当前视图的cell，最后一个cell的index是否超出范围，是的话移除
            if (cell.indexPath.row > indexTo) {
                [self recycleOldCell:i toCacheWithObject:cell];
            } else {
                markIndex = MIN(cell.indexPath.row, markIndex);
            }
        }
        
        //从markcell的上一个视图之上添加视图 一直填到 计算好的indexFrom（根据屏幕计算好的cell索引范围，第一个索引）
        for (NSInteger i = markIndex; i > indexFrom; i --) {
            [self getCellWithIndexPath:[NSIndexPath indexPathForRow:i - 1 inSection:0]];
            [_visibleCellArr insertObject:_cell atIndex:0];
        }
    }
    
}

- (void)upRecycleCellFromIndex:(NSInteger)indexFrom toIndex:(NSInteger) indexTo withCurrentOffsetY:(CGFloat)currentOffsetY{
    
    //上滑
    if (currentOffsetY > _lastOffsetY ) {
        
        CDTableViewCell *endCell = _visibleCellArr.lastObject;
        //上滑到最后一个截至
        if (endCell.indexPath.row + 1 > _cellSumCount) {
            return;
        }
        
        NSInteger markIndex = indexFrom;
        for (NSInteger i = 0; i < _visibleCellArr.count; i++) {
            CDTableViewCell *cell = (CDTableViewCell *)_visibleCellArr[i];
            //上滑 第一个cell的row是不是小于当前索引范围，是的话移除
            if (cell.indexPath.row < indexFrom ) {
                [self recycleOldCell:i toCacheWithObject:cell];
                i--;
            } else {
                markIndex = MAX(cell.indexPath.row, markIndex);
            }
        }
        //上滑 从markcell的下一个开始添加 一直添加到 indexTo（根据屏幕计算好的cell索引范围，最后一个索引
        for (NSInteger i = markIndex; i < indexTo; i ++) {
            [self getCellWithIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
            [_visibleCellArr addObject:_cell];
        }
    }

}

- (CGFloat)accurateContentOffsetY {
    CGFloat visiableYBegin = self.contentOffset.y;
    if (visiableYBegin + self.frame.size.height > _lastRowHeight) { //最后cell处理，不处理，循环会按照当店offsetY寻找索引
        visiableYBegin = _lastRowHeight - self.frame.size.height;
    }
    visiableYBegin = MAX(0, visiableYBegin);
    return visiableYBegin;
}

//根据屏幕尺寸，获取cell的索引范围
- (CGPoint)calculteVisableIndex {
    
    CGFloat beginOffsetY = [self accurateContentOffsetY];
    CGFloat endOffsetY = beginOffsetY + self.frame.size.height;
    CGFloat contentHeight = 0;
    CGFloat preContentHeight = 0;
    NSInteger fromIndex = -1 ,toIndex = -1;
    for (NSInteger i = 0; i < _cellFrameDict.count; i ++) {
        preContentHeight = contentHeight;
        contentHeight += [[_cellFrameDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] CGRectValue].size.height;

        if (fromIndex < 0) {
            if (preContentHeight <= beginOffsetY && contentHeight >= beginOffsetY) {
                fromIndex = i;
            }
        }
        
        if (fromIndex >= 0 && toIndex < 0) {
            if (preContentHeight <= endOffsetY && contentHeight >= endOffsetY) {
                toIndex = i;
            }
        }
    }
    
    if (fromIndex >= 0 && toIndex < 0) {
        toIndex = fromIndex;
    }
    return CGPointMake(fromIndex, toIndex);
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat currentOffsetY = self.contentOffset.y;
    
    CGPoint index = [self calculteVisableIndex];
    
    //index.x 是根据屏幕计算出的第一个cell的索引 ，index.y是最后一个
    [self upRecycleCellFromIndex:index.x toIndex:index.y withCurrentOffsetY:currentOffsetY];
    
    [self downRecycleCellFromIndex:index.x toIndex:index.y withCurrentOffsetY:currentOffsetY];

    _lastOffsetY = currentOffsetY;
    
}



@end
