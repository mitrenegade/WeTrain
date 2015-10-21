//
//  TutorialScrollView.m
//  cwsfroster
//
//  Created by Bobby Ren on 9/2/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import "TutorialScrollView.h"

@implementation TutorialScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
}

-(void)setupScroll {
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setDelegate:self];
    [scrollView setBounces:NO];

    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];

    [self addSubview:scrollView];
    [self addSubview:pageControl];

}

-(void)setTutorialPages:(NSArray *)pageNames {
    self.backgroundColor = [UIColor clearColor];
    [self setupScroll];

    int page = 0;
    int width = self.bounds.size.width;
    for (NSString *name in pageNames) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
        UIView *tutorialPage = [subviewArray objectAtIndex:0];

        CGRect frame = CGRectMake(0, 0, width, scrollView.frame.size.height);
        tutorialPage.frame = frame;
        CGPoint center = CGPointMake(page * width + width/2, self.frame.size.height / 2 - 30);
        tutorialPage.center = center;
        [scrollView addSubview:tutorialPage];

        page++;
    }
    [pageControl setNumberOfPages:page];
    [scrollView setContentSize:CGSizeMake(page * width, self.bounds.size.height)];

    pageControl.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 40);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / self.bounds.size.width;
    [pageControl setCurrentPage:page];
    
    if (self.delegate != nil) {
        [self.delegate didScrollToPage:page];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
