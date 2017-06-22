//
//  TraveloMateUI
//
//  Created by Diparth Patel on 5/2/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Sinch/Sinch.h>
#import "SINUIViewController.h"



typedef enum {
  kButtonsAnswerDecline,
  kButtonsHangup,
} EButtonsBar;

@class Users;

@interface VoiceCallVC : SINUIViewController

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *remoteUsername;
@property (weak, nonatomic) IBOutlet UILabel *callStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *endCallButton;

@property (nonatomic, readwrite, strong) NSTimer *durationTimer;

@property (nonatomic, readwrite, strong) id<SINCall> call;

@property (nonatomic, strong) Users* user;

- (IBAction)accept:(id)sender;
- (IBAction)decline:(id)sender;
- (IBAction)hangup:(id)sender;

@end
