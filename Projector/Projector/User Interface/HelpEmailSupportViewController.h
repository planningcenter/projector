//
//  HelpEmailSupportViewController.h
//  Projector
//
//  Created by Skylar Schipper on 6/9/14.
//

#import "PCOViewController.h"

@interface HelpEmailSupportViewController : PCOViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *bodyView;
@property (weak, nonatomic) IBOutlet PCOTextField *subjectField;

@property (strong, nonatomic) NSError *reportError;

@end
