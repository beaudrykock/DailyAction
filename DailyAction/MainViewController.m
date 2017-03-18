//
//  ViewController.m
//  DailyAction
//
//  Created by Beaudry Kock on 2/24/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setup];
    
    [self refreshOpportunityViews];
    
    [self loadTitleView];
}

- (void)setup
{
    // load content
    
    self.opportunityViews = [NSMutableArray arrayWithCapacity:10];
    self.opportunityViewTags = [NSMutableDictionary dictionaryWithCapacity:10];
    self.opportunityScrollView.showsHorizontalScrollIndicator = NO;
    
  
}

- (void)loadTitleView
{
     self.titleView = [[[NSBundle mainBundle] loadNibNamed:@"ActionDateView" owner:self options:nil] objectAtIndex:0];
    
    CGRect frame = self.titleView.frame;
    frame.origin.x = (self.view.frame.size.width-self.titleView.frame.size.width)/2.0;
    frame.origin.y = 16.0;
    self.titleView.frame = frame;
    
    [self.view addSubview:self.titleView];
}

- (void)refreshOpportunityViews
{
    NSInteger oppCount = [[OpportunityDataManager sharedInstance] countOfOpportunities];
    
    if (oppCount > OPPORTUNITIES_LIMIT)
        oppCount = OPPORTUNITIES_LIMIT;
    
    self.pageControl.numberOfPages = oppCount;
    
    
    
    // clear existing views
    for (UIView *view in self.opportunityScrollView.subviews)
        [view removeFromSuperview];
    
    [self.opportunityViews removeAllObjects];
    
    // set size of scrollview x opportunity count of current width
    self.opportunityScrollView.contentSize = CGSizeMake(self.opportunityScrollView.frame.size.width*oppCount, self.opportunityScrollView.frame.size.height);
    
    // position scrollview at last page
    self.opportunityScrollView.contentOffset = CGPointMake(self.opportunityScrollView.frame.size.width*(oppCount-1), 0.0);
    
    self.pageControl.currentPage = [self currentPage];
    
    self.lastPage = [self currentPage];
    
    // Setting up Opportunity cards
    [self createOpportunityViewAtPage: [self currentPage]];
    [self createOpportunityViewAtPage: [self currentPage]-1];

}

# pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // once scroll view passes 1/2 way, add previous-1 or +1 to stack
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSLog(@"page = %lu", [self currentPage]);
    
    self.pageControl.currentPage = [self currentPage];
    
    if ([self.opportunityViewTags objectForKey: [NSNumber numberWithInteger: [self currentPage]-1]]) {
    
        return;
    }
    else {
        if (([self currentPage]-1)>=0)
        {
            NSLog(@"Creating view at page %lu", [self currentPage]-1);
            // view is missing, create it and set its tag to currentPage+1
            [self createOpportunityViewAtPage:[self currentPage]-1];
        }
    }
    
    // now check if we're on a new page, in which case the title view must be updated
    if ([self currentPage] != _lastPage)
    {
        _lastPage = [self currentPage];
        
        [self parameterizeTitle];
    }
}

- (void)parameterizeTitle
{
    // TODO
}

- (NSInteger)currentPage
{
    return self.opportunityScrollView.contentOffset.x / self.opportunityScrollView.frame.size.width;
}

- (void)createOpportunityViewAtPage:(NSInteger)page
{
    float base_width = self.opportunityScrollView.frame.size.width;
    
    OpportunityCard* opportunity = [[[NSBundle mainBundle] loadNibNamed:@"OpportunityCardView" owner:self options:nil] objectAtIndex:0];
    opportunity.tag = page;
    [opportunity parameterizeWithOpportunity:[[OpportunityDataManager sharedInstance] opportunityForDay:page]];
    
    CGRect frame = opportunity.frame;
    frame.size.width = base_width-20.0;
    frame.size.height = self.opportunityScrollView.frame.size.height;
    frame.origin.x =  (base_width*page)+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = (self.opportunityScrollView.frame.size.height - frame.size.height)/2.0;
    opportunity.frame = frame;
    
    opportunity.layer.cornerRadius = 15.0;
    
    [self.opportunityScrollView addSubview:opportunity];
    
    [self.opportunityViews addObject:opportunity];
    [self.opportunityViewTags setObject:opportunity forKey:[NSNumber numberWithInteger:opportunity.tag]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
