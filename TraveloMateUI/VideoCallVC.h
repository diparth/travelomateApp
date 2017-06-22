#import <UIKit/UIKit.h>
#import <Sinch/Sinch.h>

#import "SINUIViewController.h"


typedef enum {
    kVideoButtonsAnswerDecline,
    kVideoButtonsHangup,
} EVideoButtonsBar;


@class Users;

@interface VideoCallVC : SINUIViewController

@property (weak, nonatomic) IBOutlet UILabel *remoteUsername;
@property (weak, nonatomic) IBOutlet UILabel *callStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *endCallButton;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIView *localVideoView;

@property (nonatomic, readwrite, strong) NSTimer *durationTimer;

@property (nonatomic, readwrite, strong) id<SINCall> call;

@property (nonatomic, strong) Users* user;

- (IBAction)accept:(id)sender;
- (IBAction)decline:(id)sender;
- (IBAction)hangup:(id)sender;

@end
