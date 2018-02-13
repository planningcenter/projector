/*!
 * PROSwitchTableViewCell.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/14/14
 */

#import "PROSwitchTableViewCell.h"

#import "PROSwitch.h"

@interface PROSwitchTableViewCell ()

@property (nonatomic, weak) PROSwitch *control;

@end

@implementation PROSwitchTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.control addTarget:self action:@selector(pco_valueChangeHandler:) forControlEvents:UIControlEventValueChanged];
}

- (PROSwitch *)control {
    if (!_control) {
        PROSwitch *s = [[PROSwitch alloc] initWithFrame:CGRectZero];
        
        _control = s;
        self.accessoryView = s;
    }
    return _control;
}

- (BOOL)isOn {
    return [self.control isOn];
}
- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}
- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [self.control setOn:on animated:animated];
}

- (void)pco_valueChangeHandler:(id)sender {
    if (self.valueChanged) {
        self.valueChanged([self isOn]);
    }
}

@end

NSString *const PROSwitchTableViewCellIdentifier = @"PROSwitchTableViewCellIdentifier";
