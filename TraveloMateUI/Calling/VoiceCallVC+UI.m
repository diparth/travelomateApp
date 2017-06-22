//
//  TraveloMateUI
//
//  Created by Diparth Patel on 5/2/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

#import "VoiceCallVC+UI.h"

@implementation VoiceCallVC (UIAdjustments)

- (void)setCallStatusText:(NSString *)text {
  self.callStateLabel.text = text;
}

#pragma mark - Buttons

- (void)showButtons:(EButtonsBar)buttons {
  if (buttons == kButtonsAnswerDecline) {
    self.answerButton.hidden = NO;
    self.declineButton.hidden = NO;
    self.endCallButton.hidden = YES;
  } else if (buttons == kButtonsHangup) {
    self.endCallButton.hidden = NO;
    self.answerButton.hidden = YES;
    self.declineButton.hidden = YES;
  }
}

#pragma mark - Duration

- (void)setDuration:(NSInteger)seconds {
  [self setCallStatusText:[NSString stringWithFormat:@"%02d:%02d", (int)(seconds / 60), (int)(seconds % 60)]];
}

- (void)internal_updateDuration:(NSTimer *)timer {
  SEL selector = NSSelectorFromString([timer userInfo]);
  if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector withObject:timer];
#pragma clang diagnostic pop
  }
}

- (void)startCallDurationTimerWithSelector:(SEL)sel {
  NSString *selectorAsString = NSStringFromSelector(sel);
  self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(internal_updateDuration:)
                                                      userInfo:selectorAsString
                                                       repeats:YES];
}

- (void)stopCallDurationTimer {
  [self.durationTimer invalidate];
  self.durationTimer = nil;
}

@end
