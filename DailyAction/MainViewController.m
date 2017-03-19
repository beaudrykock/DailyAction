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
    self.btn_changeLocation.layer.cornerRadius = 4.0;
    
    // subscribe to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserVotingLocation) name:UPDATED_USER_LOCATION object:nil];
  
}

- (void)loadTitleView
{
     self.titleView = [[[NSBundle mainBundle] loadNibNamed:@"ActionDateView" owner:self options:nil] objectAtIndex:0];
    self.titleView.date_container.layer.cornerRadius = 15.0;
    
    CGRect frame = self.titleView.frame;
    frame.origin.x = (self.view.frame.size.width-self.titleView.frame.size.width)/2.0;
    frame.origin.y = 26.0;
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
    frame.size.height = self.opportunityScrollView.frame.size.height;
    frame.origin.x =  (base_width*page)+((self.opportunityScrollView.frame.size.width - frame.size.width)/2.0);
    frame.origin.y = 0.0;
    opportunity.frame = frame;
    
    opportunity.layer.cornerRadius = 15.0;
    
    [self.opportunityScrollView addSubview:opportunity];
    
    [self.opportunityViews addObject:opportunity];
    [self.opportunityViewTags setObject:opportunity forKey:[NSNumber numberWithInteger:opportunity.tag]];
    
}

- (IBAction)changeLocation:(id)sender
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Where do you vote?"
                                          message:@"Enter a 5-digit zipcode"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"e.g. 94301";
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    self.okAction = [UIAlertAction
                               actionWithTitle:@"Update"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *zipcode = alertController.textFields.firstObject;
                                   
                                   [[UserDataManager sharedInstance] updateUserVotingZipcode:zipcode.text];
                                   [[UserDataManager sharedInstance] updateUserVotingLocalityFromZipcode:zipcode.text];
                                   [[UserDataManager sharedInstance] updateUserLocationSource:MANUAL];
                                   
                                   [self refreshUserVotingLocation];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:self.okAction];
    self.okAction.enabled = NO;
    
    [self presentViewController:alertController animated:YES completion:nil];

}
- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *login = alertController.textFields.firstObject;
        
        
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([login.text rangeOfCharacterFromSet:notDigits].location == NSNotFound && login.text.length == 5)
        {
            self.okAction.enabled = YES;
        }
        else
        {
            self.okAction.enabled = NO;
        }
    }
}

// gets user locality and zipcode from User database and displays
- (void)refreshUserVotingLocation
{
    NSString *userZipcode = [[UserDataManager sharedInstance] userVotingZip];
    NSString *userLocality = [[UserDataManager sharedInstance] userVotingLocality];
    NSString *userLocationSource = [[UserDataManager sharedInstance] userLocationSource];
    
    if ([userLocationSource isEqualToString:AUTO])
    {
        [self.lb_votingLocation setText:[NSString stringWithFormat:@"We think you're a %@ voter (%@)", userLocality, userZipcode]];
    }
    else
    {
        [self.lb_votingLocation setText:[NSString stringWithFormat:@"You're a %@ voter (%@)", userLocality, userZipcode]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
