//
//  TutorialScrollView.h
//  cwsfroster
//
//  Created by Bobby Ren on 9/2/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TutorialScrollDelegate <NSObject>

-(void)didScrollToPage:(int)page;

@end

@interface TutorialScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIPageControl *pageControl;
}

@property (weak, nonatomic) id delegate;

-(void)setTutorialPages:(NSArray *)pageNames;

@end
