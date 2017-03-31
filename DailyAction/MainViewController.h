//
//  ViewController.h
//  DailyAction
//
//  Created by Beaudry Kock on 2/24/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpportunityCard.h"
#import "OpportunityDataManager.h"
#import "Constants.h"
#import "ActionDate.h"
#import "UserDataManager.h"
#import "CallScript.h"

@interface MainViewController : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate, CallScriptDelegate, OpportunityCardDelegate>

@property (nonatomic, assign) NSInteger titleViewPage;
@property (nonatomic, assign) BOOL scrollStarted;
@property (nonatomic, assign) BOOL lazyLoaded;
@property (nonatomic, assign) float contentOffset;
@property (nonatomic, strong) NSNumber *currentlyDisplayedOpportunityID;
@property (nonatomic, strong) IBOutlet UIScrollView *opportunityScrollView;
@property (nonatomic, strong) NSMutableArray *opportunityViews;
@property (nonatomic, strong) NSMutableArray *opportunities;
@property (nonatomic, strong) NSMutableDictionary *opportunityViewTags;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger lastPage;
@property (nonatomic, strong) ActionDate *titleView;
@property (nonatomic, strong) IBOutlet UIButton *btn_changeLocation;
@property (nonatomic, strong) UIAlertAction *okAction;
@property (nonatomic, strong) IBOutlet UILabel *lb_votingLocation;
@property (nonatomic, strong) CallScript *callScriptView;



@end

