//
//  TextStepperField.m
//
//  Created by Manuel Garcia Lopez 24-1-2011.
//

#import "TextStepperField.h"

@interface TextStepperField ()

@property (nonatomic, retain, readonly) UIButton *plusButton;
@property (nonatomic, retain, readonly) UIButton *minusButton;
@property (nonatomic, retain, readonly) UIImageView *middleImage;
@property (nonatomic, retain, readonly) UITextField  *textField;

- (void)      initializeControl;
- (NSString*) getPlaceholderText;
- (void)      didChangeTextField;
@end

@implementation TextStepperField

@synthesize plusButton = _plusButton,
minusButton = _minusButton,
middleImage = _middleImage,
TypeChange = _value, 
textField = _textField,
Current,
NumDecimals=_NumDecimals, 
Maximum=_Maximum, 
Minimum=_Minimum, 
Step=_Step,
VariableRanges=_VariableRanges,
VariableSteps=_VariableSteps,
IsEditableTextField= _IsEditableTextField,
longTapping;

TextStepperFieldChangeKind _longTapLoopValue;
UIEdgeInsets insetMiddleImage={13,4,13,4};
UIEdgeInsets insetButtonImage={13,13,13,13};

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeControl];
    }
    return self;
}

- (void)awakeFromNib {
    [self initializeControl];
}

- (void)initializeControl {
    self.NumDecimals=0;
    self.Step=1;
    self.Maximum = INFINITY;
    self.Minimum = INFINITY*-1;
    self.autoresizesSubviews=YES;
    self.IsEditableTextField = TRUE;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.clipsToBounds = YES;
    CGSize BFStepperButton = CGSizeMake(45, self.frame.size.height);
    
    // middle image
    _middleImage = [[UIImageView alloc] init];
    self.middleImage.frame = CGRectMake(BFStepperButton.width, 0, self.frame.size.width - (BFStepperButton.width*2), BFStepperButton.height);
    [self.middleImage setImage:[[UIImage  imageNamed:@"TextStepper_Middle.png"]resizableImageWithCapInsets:insetMiddleImage]];
    self.middleImage.autoresizingMask = UIViewAutoresizingNone; //push to none
    self.middleImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.middleImage];
    
    // button minus in to left
    _minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.minusButton.frame = CGRectMake(0.0, 0.0, BFStepperButton.width, BFStepperButton.height);
    [self.minusButton setBackgroundImage:[[UIImage imageNamed:@"TextStepper_Left.png"] resizableImageWithCapInsets:insetButtonImage] forState:UIControlStateNormal];
    [self.minusButton setBackgroundImage:[[UIImage imageNamed:@"TextStepper_LeftPressed.png"] resizableImageWithCapInsets:insetButtonImage]forState:UIControlStateHighlighted];
    [self.minusButton setImage:[UIImage imageNamed:@"TextStepper_Minus"] forState:UIControlStateNormal];
    [self.minusButton addTarget:self action:@selector(didPressMinusButton) forControlEvents:UIControlEventTouchUpInside];
    [self.minusButton addTarget:self action:@selector(didBeginMinusLongTap) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.minusButton addTarget:self action:@selector(didEndLongTap) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    self.minusButton.autoresizingMask = UIViewAutoresizingNone; // push tu none
    self.minusButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.minusButton];
    
    // button plus in to right
    _plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.plusButton.frame = CGRectMake(self.frame.size.width - BFStepperButton.width, 0.0, BFStepperButton.width, BFStepperButton.height);
    [self.plusButton setBackgroundImage:[[UIImage imageNamed:@"TextStepper_Right.png"]resizableImageWithCapInsets:insetButtonImage] forState:UIControlStateNormal];
    [self.plusButton setBackgroundImage:[[UIImage imageNamed:@"TextStepper_RightPressed.png"] resizableImageWithCapInsets:insetButtonImage] forState:UIControlStateHighlighted];
    [self.plusButton setImage:[UIImage imageNamed:@"TextStepper_Plus"] forState:UIControlStateNormal];
    [self.plusButton addTarget:self action:@selector(didPressPlusButton) forControlEvents:UIControlEventTouchUpInside];
    [self.plusButton addTarget:self action:@selector(didBeginPlusLongTap) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.plusButton addTarget:self action:@selector(didEndLongTap)  forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    self.plusButton.autoresizingMask = UIViewAutoresizingNone; // push to none
    self.plusButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.plusButton];
    
    
    //TextField the number
    _textField = [[UITextField alloc] init];
    self.textField.textAlignment = UITextAlignmentRight;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.clearButtonMode = UITextFieldViewModeNever;
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.placeholder = [self getPlaceholderText];
    self.textField.inputView = nil;
    
    
    self.NumDecimals == 0 ? [self.textField setKeyboardType:UIKeyboardTypeNumberPad] : [self.textField setKeyboardType:UIKeyboardTypeDecimalPad];
    
    UIToolbar* toolBarView = [[UIToolbar alloc] init];
    toolBarView.barStyle = UIBarStyleBlack;
    toolBarView.translucent = YES;
    toolBarView.tintColor = nil;
    [toolBarView sizeToFit];
    
    [toolBarView setItems:[NSArray arrayWithObjects: 
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self 
                                                                         action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self 
                                                                         action:@selector(doneClicked:)],
                           nil]];
    self.textField.inputAccessoryView = toolBarView;

    CGSize sizeField= [self.textField sizeThatFits:BFStepperButton];
    self.textField.frame = CGRectMake(BFStepperButton.width+5, (BFStepperButton.height - sizeField.height)/2,self.frame.size.width - (BFStepperButton.width*2)-10, sizeField.height);
    [self.textField addTarget:self action:@selector(didChangeTextField) forControlEvents: UIControlEventEditingChanged];
    self.textField.autoresizingMask = UIViewAutoresizingNone; // push to none
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.textField];
    
    self.longTapping = NO;
}

-(void)doneClicked:(id)sender {
    [self.textField resignFirstResponder];
}

-(float) Current
{    
    return [self.textField.text floatValue];
}

-(void) setCurrent:(float)pflValue
{
    self.textField.text = [NSString stringWithFormat:[@"%.Xf" stringByReplacingOccurrencesOfString:@"X"
                                                                                        withString:[NSString stringWithFormat:@"%d", self.NumDecimals]], pflValue];
}

- (NSString*)getPlaceholderText
{
    NSMutableString *lstrDato = [NSMutableString stringWithString: @"0"];
    for (int i=0; i<self.NumDecimals; i++) 
    {
        if (lstrDato.length ==1) // is first time
        {
            [lstrDato appendString:@"."];
        }
        [lstrDato appendString:@"0"];
    }
    return lstrDato;
}

-(void) setIsEditableTextField:(BOOL)pIsEditableTextField
{
    _IsEditableTextField = pIsEditableTextField;
    
    self.textField.enabled = _IsEditableTextField;
}

-(void) setNumDecimals:(int)pNumDecimals
{
    if (_NumDecimals<0) {
        _NumDecimals =0;
    }
    
    _NumDecimals = pNumDecimals;
    
    self.textField.placeholder = [self getPlaceholderText]; // to correctly display the decimal number when deleting all charaters
    
    self.Current = self.Current; // to re-display it correctly
}


-(void) didChangeTextField
{
    if ( self.Current < self.Minimum) 
        self.Current = self.Minimum;
    
    if ( self.Current > self.Maximum) 
        self.Current = self.Maximum;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


-(void) setTypeChange:(TextStepperFieldChangeKind)pTypeChange {
    _value = pTypeChange;
    
    (self.TypeChange == TextStepperFieldChangeKindNegative ) ? [self decrement] : [self increment];
}

- (void)decrement {
    if(self.VariableRanges) {
        for(int i = 0; i < [self.VariableRanges count]; i++) {
            if (self.Current > [[self.VariableRanges objectAtIndex:i] intValue]) {
                self.Step = [(NSNumber*)[self.VariableSteps objectAtIndex:i] floatValue];
            }
        }
    }
    if (self.longTapping) {
        if (self.Current > self.Minimum) 
            self.Current -= self.Step * 10;
        else
            self.Current = self.Minimum;
    } else {
        if (self.Current > self.Minimum) 
            self.Current -= self.Step;
        else
            self.Current = self.Minimum;
    }
}

- (void)increment {
    if(self.VariableRanges) {
        for(int i = [self.VariableRanges count] - 1; i > 0; i--) {
            if (self.Current >= [[self.VariableRanges objectAtIndex:i] intValue]) {
                self.Step = [(NSNumber*)[self.VariableSteps objectAtIndex:i] floatValue];
                break;
            }
        }
    }
    if (self.longTapping) {
        if (self.Current < self.Maximum) 
            self.Current += self.Step * 10;
        else
            self.Current = self.Maximum;        
    } else {
        if (self.Current < self.Maximum) 
            self.Current += self.Step;
        else
            self.Current = self.Maximum;
    }
}

#pragma mark - Button Events

#pragma mark Plus Button Events

- (void)didPressPlusButton {
    [self.textField resignFirstResponder];
    self.TypeChange = TextStepperFieldChangeKindPositive;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)didBeginPlusLongTap {
    [self.textField resignFirstResponder];
    _longTapLoopValue = TextStepperFieldChangeKindPositive;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(backgroundLongTapLoop) object:nil];
    [self performSelector:@selector(backgroundLongTapLoop) withObject:nil afterDelay:0.5];
}

#pragma mark Minus Button Events

- (void)didPressMinusButton {
    [self.textField resignFirstResponder];
    self.TypeChange = TextStepperFieldChangeKindNegative;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)didBeginMinusLongTap {
    [self.textField resignFirstResponder];
    _longTapLoopValue = TextStepperFieldChangeKindNegative;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(backgroundLongTapLoop) object:nil];
    [self performSelector:@selector(backgroundLongTapLoop) withObject:nil afterDelay:0.5];
}

#pragma mark Long Tap Loop

- (void)didEndLongTap {
    [self.textField resignFirstResponder];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(backgroundLongTapLoop) object:nil];
    self.longTapping = NO;
}

- (void)backgroundLongTapLoop {
    self.longTapping = YES;
    [self.textField resignFirstResponder];
    [self performSelectorOnMainThread:@selector(longTapLoop) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(backgroundLongTapLoop) withObject:nil  afterDelay:0.1];
}

- (void)longTapLoop {
    [self.textField resignFirstResponder];    
    self.TypeChange= _longTapLoopValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
