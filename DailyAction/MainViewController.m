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
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [self setup];
    
    [self refreshUserVotingLocation];
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
  
    [[OpportunityDataManager sharedInstance] addObserver:self forKeyPath:@"contentUpdated" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    if ([[OpportunityDataManager sharedInstance] contentAvailable])
    {
        [self refreshOpportunityViews];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
  if ([keyPath isEqualToString:@"contentUpdated"]) {
        if ([[OpportunityDataManager sharedInstance] contentUpdated])
        {
            [self refreshOpportunityViews];
            
            [OpportunityDataManager sharedInstance].contentUpdated = NO;
        }
    }
}


- (void)refreshTitleView
{
    if (!self.titleView)
    {
        self.titleView = [[[NSBundle mainBundle] loadNibNamed:@"ActionDateView" owner:self options:nil] objectAtIndex:0];
        self.titleView.date_container.layer.cornerRadius = 15.0;
        
        CGRect frame = self.titleView.frame;
        frame.origin.x = (self.view.frame.size.width-self.titleView.frame.size.width)/2.0;
        frame.origin.y = 26.0;
        self.titleView.frame = frame;
        
        [self.view addSubview:self.titleView];
    }
    
    // parameterize title view
    RLMResults<Opportunity*> *opportunities = [[OpportunityDataManager sharedInstance] actedOnOpportunities];
    
    Opportunity *opp;
    
    if ([self currentPage] == opportunities.count)
    {
        opp = [[OpportunityDataManager sharedInstance] todaysOpportunity];
    }
    else
    {
        opp = [[OpportunityDataManager sharedInstance] todaysOpportunity];
    }
    
    self.currentlyDisplayedOpportunityID = opp.opportunityID;
    
    self.titleView.lb_title.text = opp.summary;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd";
    self.titleView.lb_date.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)refreshOpportunityViews
{
    NSInteger oppCount = [[OpportunityDataManager sharedInstance] countOfActedOnOpportunities]+1; // 1 extra for today's, if 0 or otherwise less than OPPORTUNITIES_LIMIT
    
    if (oppCount > OPPORTUNITIES_LIMIT)
        oppCount = OPPORTUNITIES_LIMIT;
    
    self.pageControl.numberOfPages = oppCount;
    
    if (oppCount <= 1)
        self.pageControl.hidden = YES;
    else
        self.pageControl.hidden = NO;
    
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
    
    if (oppCount>1)
        [self createOpportunityViewAtPage: [self currentPage]-1];
    
    [self refreshTitleView];
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
        
        [self refreshTitleView];
    }
}

- (NSInteger)currentPage
{
    return self.opportunityScrollView.contentOffset.x / self.opportunityScrollView.frame.size.width;
}

- (void)createOpportunityViewAtPage:(NSInteger)page
{
    
    RLMResults<Opportunity*> *opportunities = [[OpportunityDataManager sharedInstance] actedOnOpportunities];
    
    float base_width = self.opportunityScrollView.frame.size.width;
    
    OpportunityCard* opportunity = [[[NSBundle mainBundle] loadNibNamed:@"OpportunityCardView" owner:self options:nil] objectAtIndex:0];
    opportunity.delegate = self;
    opportunity.tag = page;
    
    // for today's action
    if (page == opportunities.count)
    {
        Opportunity *todaysOpp = [[OpportunityDataManager sharedInstance] todaysOpportunity];
        
        [opportunity parameterizeWithOpportunity:todaysOpp];
    }
    else
    {
        [opportunity parameterizeWithOpportunity:[opportunities objectAtIndex:page]];
    }
    
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
        if ([alertController.title isEqualToString:@"Where do you vote?"])
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
        else
        {
            UITextField *login = alertController.textFields.firstObject;
            
            if ([login.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound && login.text.length >= 2)
            {
                self.okAction.enabled = YES;
            }
            else
            {
                self.okAction.enabled = NO;
            }
        }
    }
}

// gets user locality and zipcode from User database and displays
- (void)refreshUserVotingLocation
{
    NSString *userZipcode = [[UserDataManager sharedInstance] userVotingZip];
    NSString *userLocality = [[UserDataManager sharedInstance] userVotingLocality];
    NSString *userLocationSource = [[UserDataManager sharedInstance] userLocationSource];
    
    // only set if information already available
    if (userZipcode && userLocality && userLocationSource)
    {
        if ([userLocationSource isEqualToString:AUTO])
        {
            [self.lb_votingLocation setText:[NSString stringWithFormat:@"We think you're a %@ voter (%@)", userLocality, userZipcode]];
        }
        else
        {
            [self.lb_votingLocation setText:[NSString stringWithFormat:@"You're a %@ voter (%@)", userLocality, userZipcode]];
        }
    }
}

#pragma mark - Mail compose delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    if (result == MFMailComposeResultSent)
    {
        // mark as done
        [[OpportunityDataManager sharedInstance] markOpportunityAsActedOnWithID:self.currentlyDisplayedOpportunityID];
        
        [self refreshOpportunityViews];
    }
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)composeEmail
{
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:self.currentlyDisplayedOpportunityID];
    
    if (![MFMailComposeViewController canSendMail]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Please set up e-mail";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        return;
    }
    else
    {
        // get the subaction
        EmailAction *emailAction = [[OpportunityDataManager sharedInstance] emailActionForActionWithID:action.actionID];
        
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[emailAction.emailAddress]];
        [composeVC setSubject:@"Hear me roar"];
        [composeVC setMessageBody:emailAction.emailScript isHTML:NO];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}

#pragma mark - Updating name

- (void)showUpdateNameModal
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"What's your name?"
                                          message:@"Enter your first and last name"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"";
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
                         UITextField *name = alertController.textFields.firstObject;
                         
                         [[UserDataManager sharedInstance] updateUserFullName: name.text];
                         
                         [self.callScriptView generateScript];
                         
                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:self.okAction];
    self.okAction.enabled = NO;
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Script view handling

- (void)showCallScript
{
    self.callScriptView = [[[NSBundle mainBundle] loadNibNamed:@"CallScriptView" owner:self options:nil] objectAtIndex:0];
    self.callScriptView.delegate = self;
    [self.callScriptView parameterizeWithOpportunity: [[OpportunityDataManager sharedInstance] opportunityWithID:self.currentlyDisplayedOpportunityID]];
    
    CGRect frame = self.callScriptView.frame;
    frame.origin.x = (self.view.frame.size.width-self.callScriptView.frame.size.width)/2.0;
    frame.origin.y = self.view.frame.size.height;
    self.callScriptView.frame = frame;
    
    [self.view addSubview:self.callScriptView];
    
    [UIView animateWithDuration:0.5 animations:^{
        OpportunityCard *oppCard = self.opportunityViews[[self currentPage]];
        oppCard.alpha = 0.0;
        CGRect frame = self.callScriptView.frame;
        frame.origin.y = self.opportunityScrollView.frame.origin.y;
        self.callScriptView.frame = frame;
    }];
}

- (void)cancelScript
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.callScriptView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.callScriptView.frame = frame;
        OpportunityCard *oppCard = self.opportunityViews[[self currentPage]];
        oppCard.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.callScriptView removeFromSuperview];
        _callScriptView = nil;
    }];
}

- (void)makeCall
{
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:self.currentlyDisplayedOpportunityID];
    
    // get the subaction
    PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
    
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneAction.phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneAction.phoneNumber]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {
            if (success)
            {
                // mark as done
                [[OpportunityDataManager sharedInstance] markOpportunityAsActedOnWithID:self.currentlyDisplayedOpportunityID];
                
                [self refreshOpportunityViews];
            }
        }];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:^(BOOL success) {
            if (success)
            {
                // mark as done
                [[OpportunityDataManager sharedInstance] markOpportunityAsActedOnWithID:self.currentlyDisplayedOpportunityID];
                
                [self refreshOpportunityViews];
            }
        }];
    } else {
        // device cannot do phone calls
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Phone functions not available on your device";
        dispatch_after(2.5, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
}

#pragma mark - Housekeeping
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
