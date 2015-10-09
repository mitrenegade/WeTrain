//
//  TutorialScrollView.h
//  cwsfroster
//
//  Created by Bobby Ren on 9/2/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIPageControl *pageControl;
}

-(void)setTutorialPages:(NSArray *)pageNames;

@end
