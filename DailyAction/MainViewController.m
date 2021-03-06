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

    [[OpportunityDataManager sharedInstance] addObserver:self forKeyPath:@"contentAvailable" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    
    [[OpportunityDataManager sharedInstance] addObserver:self forKeyPath:@"contentUpdated" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    if ([[OpportunityDataManager sharedInstance] contentAvailable])
    {
        [self refreshOpportunityViews];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
  if ([keyPath isEqualToString:@"contentUpdated"]) {
        if ([[OpportunityDataManager sharedInstance] contentUpdated] &&
            [[OpportunityDataManager sharedInstance] allContentCreationCompleted])
        {
            [self refreshOpportunityViews];
            
            [OpportunityDataManager sharedInstance].contentUpdated = NO;
        }
    }
  else if ([keyPath isEqualToString:@"contentAvailable"]) {
      if ([[OpportunityDataManager sharedInstance] contentAvailable])
      {
          [self refreshOpportunityViews];
          
          [OpportunityDataManager sharedInstance].contentUpdated = NO;
      }
  }
}

- (void)refreshOpportunityViews
{
    NSInteger oppCount = [[OpportunityDataManager sharedInstance] countOfActedOnOpportunities]; // 1 extra for today's, if 0 or otherwise less than OPPORTUNITIES_LIMIT
    BOOL freshOppExists = ([[OpportunityDataManager sharedInstance] todaysOpportunity] != nil);
    if (freshOppExists) oppCount++;
    
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
    
    
    // opportunity views created in order of acted-on then today's (last slot; there may not be an action for today)
    for (int i = 0; i<oppCount-1; i++)
    {
        [self createOpportunityViewAtPage: i];
    }
    
    // finally, create today's
    [self createOpportunityViewAtPage:oppCount-1];
    
    // set today's opp as opp ID currently displayed
    Opportunity *todaysOpp = [[OpportunityDataManager sharedInstance] todaysOpportunity];
    self.currentlyDisplayedOpportunityID = todaysOpp.opportunityID;
    
    // now position scrollview at last page (always most current)
    CGRect visibleView = CGRectMake(self.opportunityScrollView.frame.size.width*(oppCount-1), 0.0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.lazyLoaded = YES;
    [self.opportunityScrollView scrollRectToVisible:visibleView animated:YES];
    self.lazyLoaded = NO;
    
    // always set to last position in the view
    self.pageControl.currentPage = oppCount-1;
    self.lastPage = oppCount-1;

    NSLog(@"page = %lu", [self currentPage]);
    NSLog(@"last page = %lu", self.lastPage);

}

# pragma mark - Scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.scrollStarted)
    {
        self.contentOffset = self.opportunityScrollView.contentOffset.x;
        self.scrollStarted = YES;
    }
    
//    NSLog(@"fabs(self.opportunityScrollView.contentOffset.x-self.contentOffset) = %f", fabs(self.opportunityScrollView.contentOffset.x-self.contentOffset));
//    NSLog(@"self.opportunityScrollView.frame.size.width)/2 = %f", (self.opportunityScrollView.frame.size.width)/2);
//    NSLog(@"page = %lu", [self currentPage]);
//    NSLog(@"last page = %lu", self.lastPage);
//    NSLog(@"lazyLoaded = %d", self.lazyLoaded);
    
    if ([self currentPage] != self.lastPage && !self.lazyLoaded)
    {        
        self.lazyLoaded = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Interaction"
                                                          action:@"Swiped opportunity cards"
                                                           label:@""
                                                           value:@1] build]];
//    NSLog(@"scroll decelerated");
//    NSLog(@"page = %lu", [self currentPage]);
//    NSLog(@"last page = %lu", self.lastPage);
    self.pageControl.currentPage = [self currentPage];
    self.lastPage = [self currentPage];
    self.lazyLoaded = NO;
    
    self.scrollStarted = NO;
    
    RLMResults<Opportunity*> *opportunities = [[OpportunityDataManager sharedInstance] actedOnOpportunities];
    
    if ([self currentPage] == opportunities.count && ([[OpportunityDataManager sharedInstance] todaysOpportunity] != nil))
    {
        Opportunity *todaysOpp = [[OpportunityDataManager sharedInstance] todaysOpportunity];
        
        self.currentlyDisplayedOpportunityID = todaysOpp.opportunityID;
    }
    else
    {
        self.currentlyDisplayedOpportunityID = [opportunities objectAtIndex:[self currentPage]].opportunityID;
    }
    
//    NSLog(@"page = %lu", [self currentPage]);
//    NSLog(@"last page = %lu", self.lastPage);
//    NSLog(@"title view page = %lu", self.titleViewPage);
    
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
    CGFloat width = self.opportunityScrollView.frame.size.width;
    return (self.opportunityScrollView.contentOffset.x + (0.5f * width)) / width;
    
//    return self.opportunityScrollView.contentOffset.x / self.opportunityScrollView.frame.size.width;
}

- (void)createOpportunityViewAtPage:(NSInteger)page
{
    
    RLMResults<Opportunity*> *opportunities = [[OpportunityDataManager sharedInstance] actedOnOpportunities];
    
    float base_width = self.opportunityScrollView.frame.size.width;
    
    OpportunityCard* opportunity = [[[NSBundle mainBundle] loadNibNamed:@"OpportunityCardView" owner:self options:nil] objectAtIndex:0];
    opportunity.delegate = self;
    opportunity.tag = page;
    
    // for today's action
    if (page == opportunities.count && ([[OpportunityDataManager sharedInstance] todaysOpportunity] != nil))
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
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Interaction"
                                                          action:@"Change location"
                                                           label:@""
                                                           value:@1] build]];
    
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
        
        // TODO - show post-action interface
        [self refreshOpportunityViews];
    }
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)composeEmail
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Action Taken"
                                                          action:@"E-mail"
                                                           label:@""
                                                           value:@1] build]];
    
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
        [oppCard setPortionsToAlpha:0.0];
        CGRect frame = self.callScriptView.frame;
        frame.origin.y = self.opportunityScrollView.frame.origin.y+77.0;
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
        [oppCard setPortionsToAlpha:1.0];
    } completion:^(BOOL finished) {
        [self.callScriptView removeFromSuperview];
        _callScriptView = nil;
    }];
}

- (void)makeCall
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Action Taken"
                                                          action:@"Phone call"
                                                           label:@""
                                                           value:@1] build]];
    
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:self.currentlyDisplayedOpportunityID];
    
    // get the subaction
    PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
    
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneAction.phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneAction.phoneNumber]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {
            if (success)
            {
                [self.callScriptView setButtonToDone];
            }
        }];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:^(BOOL success) {
            if (success)
            {
                [self.callScriptView setButtonToDone];            }
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

- (void)doneWithCall
{
    // mark as done
    [[OpportunityDataManager sharedInstance] markOpportunityAsActedOnWithID:self.currentlyDisplayedOpportunityID];
    
    [self cancelScript];
    
    [self showActionFeedback];
    
}

- (void)showActionFeedback
{
    self.feedback = [[[NSBundle mainBundle] loadNibNamed:@"ActionFeedbackView" owner:self options:nil] objectAtIndex:0];
    self.feedback.delegate = self;
    Opportunity *opp = [[OpportunityDataManager sharedInstance] opportunityWithID:self.currentlyDisplayedOpportunityID];
    
    [self.feedback setupWithOpportunity:opp];
    
    CGRect frame = self.feedback.frame;
    frame.origin.x = (self.view.frame.size.width-self.feedback.frame.size.width)/2.0;
    frame.origin.y = self.view.frame.size.height;
    self.feedback.frame = frame;
    
    [self.view addSubview:self.feedback];
    
    [UIView animateWithDuration:0.5 animations:^{
        OpportunityCard *oppCard = self.opportunityViews[[self currentPage]];
        [oppCard setPortionsToAlpha:0.0];
        CGRect frame = self.feedback.frame;
        frame.origin.y = self.opportunityScrollView.frame.origin.y+77.0;
        self.feedback.frame = frame;
    }];
}

- (void)provideFeedbackWithIndex:(NSInteger)index
{
    // TODO record feedback for action for user
    
    // close action feedback
    [self hideActionFeedback];
    
    // refresh views
    [self refreshOpportunityViews];

}

- (void)hideActionFeedback
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.feedback.frame;
        frame.origin.y = self.view.frame.size.height;
        self.feedback.frame = frame;
        OpportunityCard *oppCard = self.opportunityViews[[self currentPage]];
        [oppCard setPortionsToAlpha:1.0];
    } completion:^(BOOL finished) {
        [self.feedback removeFromSuperview];
        _feedback = nil;
    }];
}

#pragma mark - Housekeeping
- (void)viewWillAppear:(BOOL)animated
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Main view"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
