//
//  ViewController.h
//  DailyAction
//
//  Created by Beaudry Kock on 2/24/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionCard.h"
#import "OpportunityDataManager.h"
#import "Constants.h"

@interface MainViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *opportunityScrollView;
@property (nonatomic, strong) NSMutableArray *opportunities;

@end

