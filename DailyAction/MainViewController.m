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
    
    // 
}

- (void)setup
{
    // set size of scrollview x 2 of current width
    self.opportunityScrollView.contentSize = CGSizeMake(self.opportunityScrollView.frame.size.width*3, self.opportunityScrollView.frame.size.height);
    self.opportunityScrollView.contentOffset = CGPointMake(self.opportunityScrollView.frame.size.width*2.0, 0.0);
    
    self.opportunities = [NSMutableArray arrayWithCapacity:3];
    
    // Setting up Opportunity cards
    // 1. Create current view and previous
    ActionCard* current = [[[NSBundle mainBundle] loadNibNamed:@"ActionCardView" owner:self options:nil] objectAtIndex:0];
    
    [current parameterizeWithOpportunity:[[OpportunityDataManager sharedInstance] opportunityForDay:TODAY]];
    
    // today's opportunity needs to be positioned at slot 0 (from right) of content size
    float base = self.opportunityScrollView.frame.size.width;
    
    CGRect frame = current.frame;
    frame.origin.x = (base*2.0)+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = (self.opportunityScrollView.frame.size.height - frame.size.height)/2.0;
    current.frame = frame;
    
    [self.opportunities addObject:current];
    
    ActionCard* previous = [[[NSBundle mainBundle] loadNibNamed:@"ActionCardView" owner:self options:nil] objectAtIndex:0];
    
    [previous parameterizeWithOpportunity:[[OpportunityDataManager sharedInstance] opportunityForDay:YESTERDAY]];

    // yesterday's opportunity needs to be positioned at slot 1 (from right) of content size
    frame = previous.frame;
    frame.origin.x = base+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = (self.opportunityScrollView.frame.size.height - frame.size.height)/2.0;
    previous.frame = frame;
    
    [self.opportunities addObject:previous];
    
    [self.opportunityScrollView addSubview: self.opportunities[TODAY]];
    [self.opportunityScrollView addSubview: self.opportunities[YESTERDAY]];
}

# pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // once scroll view passes 1/2 way, add previous-1 or +1 to stack
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
