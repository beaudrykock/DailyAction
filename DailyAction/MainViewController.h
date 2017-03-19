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

@interface MainViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *opportunityScrollView;
@property (nonatomic, strong) NSMutableArray *opportunityViews;
@property (nonatomic, strong) NSMutableArray *opportunities;
@property (nonatomic, strong) NSMutableDictionary *opportunityViewTags;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger lastPage;
@property (nonatomic, strong) ActionDate *titleView;
@property (nonatomic, strong) IBOutlet UIButton *btn_changeLocation;

@end

