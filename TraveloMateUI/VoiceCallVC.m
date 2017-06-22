//
//  TraveloMateUI
//
//  Created by Diparth Patel on 5/2/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//


#import "VoiceCallVC.h"
#import "VoiceCallVC+UI.h"
#import "TraveloMateUI-Swift.h"

@interface VoiceCallVC () <SINCallDelegate>


@end

@implementation VoiceCallVC

- (id<SINAudioController>)audioController {
    return [[(AppDelegate *)[[UIApplication sharedApplication] delegate] client] audioController];
}

- (void)setCall:(id<SINCall>)call {
    _call = call;
    _call.delegate = self;
}

#pragma mark - UIViewController Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.answerButton.layer.cornerRadius = 35;
    self.endCallButton.layer.cornerRadius = 35;
    self.declineButton.layer.cornerRadius = 35;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if ([self.call direction] == SINCallDirectionIncoming) {
        [self setCallStatusText:@""];
        [self showButtons:kButtonsAnswerDecline];
        [[self audioController] startPlayingSoundFile:[self pathForSound:@"incoming.wav"] loop:YES];
    } else {
        [self setCallStatusText:@"Calling..."];
        [self showButtons:kButtonsHangup];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.remoteUsername.text = [NSString stringWithFormat:@"%@ %@",[self.user firstName],[self.user lastName]];
    self.backgroundImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.user picUrl]]];
    self.userImage.image = [self.backgroundImage image];
}

#pragma mark - Call Actions

- (IBAction)accept:(id)sender {
    [[self audioController] stopPlayingSoundFile];
    [self.call answer];
}

- (IBAction)decline:(id)sender {
    [self.call hangup];
    //NSArray *temp = [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismiss];
}

- (IBAction)hangup:(id)sender {
    [self.call hangup];
    //NSArray *temp = [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismiss];
}

- (void)onDurationTimer:(NSTimer *)unused {
    NSInteger duration = [[NSDate date] timeIntervalSinceDate:[[self.call details] establishedTime]];
    [self setDuration:duration];
}

#pragma mark - SINCallDelegate

- (void)callDidProgress:(id<SINCall>)call {
    [self setCallStatusText:@"ringing..."];
    [[self audioController] startPlayingSoundFile:[self pathForSound:@"ringback.wav"] loop:YES];
}

- (void)callDidEstablish:(id<SINCall>)call {
    [self startCallDurationTimerWithSelector:@selector(onDurationTimer:)];
    [self showButtons:kButtonsHangup];
    [[self audioController] stopPlayingSoundFile];
}

- (void)callDidEnd:(id<SINCall>)call {
    //NSArray *temp = [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismiss];
    [[self audioController] stopPlayingSoundFile];
    [self stopCallDurationTimer];
}

#pragma mark - Sounds

- (NSString *)pathForSound:(NSString *)soundName {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:soundName];
}

#pragma mark - User info


- (void)fetchUserDetails:(NSString *)userid {
    
}




@end
