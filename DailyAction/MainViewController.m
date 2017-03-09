//
//  ViewController.m
//  DailyAction
//
//  Created by Beaudry Kock on 2/24/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setup];
    
    [self refreshOpportunityViews];
    // 
}

- (void)setup
{
    // load content
    
    self.opportunityViews = [NSMutableArray arrayWithCapacity:10];
    self.opportunityViewTags = [NSMutableDictionary dictionaryWithCapacity:10];
}

- (void)refreshOpportunityViews
{
    NSInteger oppCount = [[OpportunityDataManager sharedInstance] countOfOpportunities];
    
    if (oppCount > OPPORTUNITIES_LIMIT)
        oppCount = OPPORTUNITIES_LIMIT;
    
    // clear existing views
    for (UIView *view in self.opportunityScrollView.subviews)
        [view removeFromSuperview];
    
    [self.opportunityViews removeAllObjects];
    
    // set size of scrollview x opportunity count of current width
    self.opportunityScrollView.contentSize = CGSizeMake(self.opportunityScrollView.frame.size.width*oppCount, self.opportunityScrollView.frame.size.height);
    
    // position scrollview at last page
    self.opportunityScrollView.contentOffset = CGPointMake(self.opportunityScrollView.frame.size.width*(oppCount-1), 0.0);
    
    
    // Setting up Opportunity cards
    // 1. Create current view and previous
    OpportunityCard* current = [[[NSBundle mainBundle] loadNibNamed:@"OpportunityCardView" owner:self options:nil] objectAtIndex:0];
    current.tag = [self currentPage];
    [current parameterizeWithOpportunity:[[OpportunityDataManager sharedInstance] opportunityForDay:oppCount-1]];
    
    // today's opportunity needs to be positioned at slot 0 (from right) of content size
    float base_width = self.opportunityScrollView.frame.size.width;
    
    CGRect frame = current.frame;
    frame.origin.x = (base_width*(oppCount-1))+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = (self.opportunityScrollView.frame.size.height - frame.size.height)/2.0;
    current.frame = frame;
    
    [self.opportunityViews addObject:current];
    [self.opportunityViewTags setObject:current forKey:[NSNumber numberWithInteger:current.tag]];
    
    OpportunityCard* previous = [[[NSBundle mainBundle] loadNibNamed:@"OpportunityCardView" owner:self options:nil] objectAtIndex:0];
    previous.tag = ([self currentPage]-1);
    [previous parameterizeWithOpportunity:[[OpportunityDataManager sharedInstance] opportunityForDay:oppCount-2]];
    
    // yesterday's opportunity needs to be positioned at slot 1 (from right) of content size
    frame = previous.frame;
    frame.origin.x = (base_width*(oppCount-2))+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = (self.opportunityScrollView.frame.size.height - frame.size.height)/2.0;
    previous.frame = frame;
    
    [self.opportunityViews addObject:previous];
    [self.opportunityViewTags setObject:previous forKey:[NSNumber numberWithInteger:previous.tag]];
    
    [self.opportunityScrollView addSubview: self.opportunityViews[TODAY]];
    [self.opportunityScrollView addSubview: self.opportunityViews[YESTERDAY]];

}

# pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // once scroll view passes 1/2 way, add previous-1 or +1 to stack
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSLog(@"page = %lu", [self currentPage]);
    
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
}

- (NSInteger)currentPage
{
    return self.opportunityScrollView.contentOffset.x / self.opportunityScrollView.frame.size.width;
}

- (void)createOpportunityViewAtPage:(NSInteger)page
{
    float base_width = self.opportunityScrollView.frame.size.width;
    
    OpportunityCard* opportunity = [[[NSBundle mainBundle] loadNibNamed:@"OpportunityCardView" owner:self options:nil] objectAtIndex:0];
    opportunity.tag = page*10;
    [opportunity parameterizeWithOpportunity:[[OpportunityDataManager sharedInstance] opportunityForDay:page]];
    
    CGRect frame = opportunity.frame;
    frame.origin.x =  (base_width*page)+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = (self.opportunityScrollView.frame.size.height - frame.size.height)/2.0;
    opportunity.frame = frame;
    
    [self.opportunityScrollView addSubview:opportunity];
    
    [self.opportunityViews addObject:opportunity];
    [self.opportunityViewTags setObject:opportunity forKey:[NSNumber numberWithInteger:opportunity.tag]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
