//
//  ActionCardView.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionCard : UIView

@property (nonatomic, strong) IBOutlet UILabel *lb_actionsTaken;
@property (nonatomic, strong) IBOutlet UILabel *lb_criticality;
@property (nonatomic, strong) IBOutlet UILabel *lb_ease;
@property (nonatomic, strong) IBOutlet UILabel *actionTitle;
@property (nonatomic, strong) IBOutlet UIScrollView *text;

@end
