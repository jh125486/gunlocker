//
//  JHRotaryWheel.m
//  DirectionWheel
//
//  Created by Jacob Hochstetler on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>

@interface JHRotaryWheel()
    -(void)drawWheel;
    -(void)drawLabels;
    -(float)calculateDistanceFromCenter:(CGPoint)point;
    -(void)buildSectorsEven;
    -(void)buildSectorsOdd;
    -(void)rotateWithDirectionPositive:(BOOL)clockWise;
@end

static float deltaAngle;
static float minAlphaValue = 0.4f;
static float maxAlphaValue = 1.f;

@implementation JHRotaryWheel
@synthesize delegate = _delegate, container = _container, numberOfSections = _numberOfSections;
@synthesize startTransform = _startTransform;
@synthesize sectors = _sectors;
@synthesize currentSector = _currentSector;
@synthesize sectorLabels = _sectorLabels;
@synthesize labels = _labels;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate withLabels:(NSArray *)labels{
    if ((self = [super initWithFrame:frame])) {
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
        background.center = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
        [self addSubview:background];
        
        _currentSector = 0;
        _labels = labels;
        _numberOfSections = [_labels count];
        _delegate = delegate;
        _sectorLabels = [[NSMutableArray alloc] initWithCapacity:_numberOfSections];

        [self drawWheel];
        [self drawLabels];
        oldAlphaValue = minAlphaValue;
        self.transform = CGAffineTransformMakeRotation(M_PI_2); 
        [self setLabelForIndex:0];
	}
    return self;
}

-(void)drawWheel {
    _container = [[UIView alloc] initWithFrame:self.frame];
    CGFloat angleSize = 2.0f*M_PI/_numberOfSections;

    for (int i = 0; i < _numberOfSections; i++) {
        UILabel *im = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_container.frame)/2.0f - 60.f, 20.0f)];
        if (i == 0) {
            im.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BottomArrow.png"]];
        } else if (i == _numberOfSections / 2.f) {
                im.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TopArrow.png"]];
        } else {
            im.backgroundColor = [UIColor clearColor];
        }

        im.layer.anchorPoint = CGPointMake(1.0f, 0.5f);

        im.layer.position = CGPointMake(CGRectGetWidth(_container.bounds)/2.0f, 
                                        CGRectGetHeight(_container.bounds)/2.0f); 
        im.transform = CGAffineTransformMakeRotation(angleSize * i);
        im.tag = i;

        [_container addSubview:im];
    }
    _container.userInteractionEnabled = NO;
    
    [self addSubview:_container];
    
    _sectors = [NSMutableArray arrayWithCapacity:_numberOfSections];
    _numberOfSections % 2 == 0 ? [self buildSectorsEven] : [self buildSectorsOdd];

    [self.delegate wheelDidChangeValue:[self getCurrentIndex]];
}

-(void)drawLabels {
    if (_numberOfSections > 12) {
        skipLabels = YES;
        skipCount = (int)round(_numberOfSections / 4);
    }
    
    CGFloat angle = 2.0f*M_PI/[_labels count];
    UIView *outerLabelsView = [[UIView alloc] initWithFrame:self.frame];    

    for (int i = 0; i < _numberOfSections; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 50.0f)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 50.0f)];
        [view addSubview:label];
        
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 2;
        label.text = [[[_labels objectAtIndex:i] componentsSeparatedByString:@"\n"] objectAtIndex:0];
        label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f];
        if (skipLabels  && (i % skipCount)) {
            label.text = @"•";
            label.alpha = minAlphaValue;
        } else {
            label.alpha = minAlphaValue;            
        }

        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.f, 0.f);
        
        label.textAlignment = UITextAlignmentCenter;
        
        view.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        view.layer.position = CGPointMake(CGRectGetWidth(self.bounds)/2.0f, (CGRectGetHeight(self.bounds) - CGRectGetWidth(label.frame))/2.0f); 
        view.transform = CGAffineTransformMakeRotation(angle * i);

        label.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        label.transform = CGAffineTransformMakeRotation(angle * -i - M_PI_2);
        
        [label setUserInteractionEnabled:YES];
        [_sectorLabels addObject:label];
        
        [view setUserInteractionEnabled:NO];
        [outerLabelsView addSubview:view];
    }
    [outerLabelsView setUserInteractionEnabled:NO];
    
    [self addSubview:outerLabelsView];
}

/*
-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.f);
    
    float radius;
    for(float i = CGRectGetWidth(rect)/16.f; i >= 0.25f ; i -= 0.25f) {
        radius = CGRectGetWidth(rect)/i;
        CGContextAddEllipseInRect(context, CGRectMake(rect.origin.x + radius/2.f, 
                                                      rect.origin.y + radius/2.f,
                                                      rect.size.width - radius,
                                                      rect.size.height - radius));
        CGContextSetLineWidth(context, 0.1f);
        CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
        CGContextStrokePath(context);
    }
}
*/

- (void)rotateCW:(int)amount {
    for (int count = 0; count < amount; count++)
        [self rotateWithDirectionPositive:YES];
}

- (void)rotateCCW:(int)amount {
    for (int count = 0; count < amount; count++)
        [self rotateWithDirectionPositive:NO];
}

-(void)rotateWithDirectionPositive:(BOOL)clockWise {
    [self resetLabelForIndex:[self getCurrentIndex]];
    
    _container.transform = CGAffineTransformRotate(_container.transform, 2*M_PI/_numberOfSections * (clockWise ? 1 : -1));
    
    CGFloat radians = atan2f(_container.transform.b, _container.transform.a);
    for (JHSector *sector in _sectors) {
        if (sector.minValue > 0 && sector.maxValue < 0) { // 4 - Check for anomaly (occurs with even number of sectors)
            if (sector.maxValue > radians || sector.minValue < radians) {
                // 5 - Find the quadrant (positive or negative)
                _currentSector = sector.sectorNumber;
            }
        } else if ([sector contains:radians]) { // 6 - All non-anomalous cases
            _currentSector = sector.sectorNumber;
        }
    }
    
    int index = [self getCurrentIndex];
    [self setLabelForIndex:index];
    [self.delegate wheelDidChangeValue:index];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self]; // 1 - Get touch position
    float distance = [self calculateDistanceFromCenter:touchPoint];
    // Filter out touches too close to the center
    if (distance < 40) return NO;
    if (distance > 100) { // touched label
        float x = touchPoint.x - _container.center.x;
        float y = touchPoint.y - _container.center.y;
        float radians = atan2(y,x);

        int sectorNumber;
        for (JHSector *sector in _sectors) {
            if (sector.minValue > 0 && sector.maxValue < 0) { // 4 - Check for anomaly (occurs with even number of sectors)
                if (sector.maxValue > radians || sector.minValue < radians) {
                    // 5 - Find the quadrant (positive or negative)
                    sectorNumber = sector.sectorNumber;
                }
            } else if ([sector contains:radians]) { // 6 - All non-anomalous cases
                sectorNumber = sector.sectorNumber;
            }
        }
        
        sectorNumber -= _numberOfSections/2.f;
        if (sectorNumber < 0) sectorNumber += _numberOfSections;
        int difference = _currentSector - sectorNumber;

        (difference < 0) ? [self rotateCCW:abs(difference)] : [self rotateCW:difference];
                
        return NO;
    }
    
    // 2 - Calculate distance from center
    float x = touchPoint.x - _container.center.x;
    float y = touchPoint.y - _container.center.y;
    deltaAngle = atan2(y,x); 
    _startTransform = _container.transform;
    
    [self resetLabelForIndex:[self getCurrentIndex]];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
    CGPoint touchPoint = [touch locationInView:self];
//    float distance = [self calculateDistanceFromCenter:touchPoint];
//    // Filter out touches too close to the center
//    if (distance < 40 || distance > 100) return NO;

    float x = touchPoint.x - _container.center.x;
    float y = touchPoint.y - _container.center.y;
    float angleDifference = deltaAngle - atan2(y,x);
    _container.transform = CGAffineTransformRotate(_startTransform, -angleDifference);
    
    [self resetLabelForIndex:[self getCurrentIndex]];

    CGFloat radians = atan2f(_container.transform.b, _container.transform.a);
    for (JHSector *sector in _sectors) {
        if (sector.minValue > 0 && sector.maxValue < 0) { // 4 - Check for anomaly (occurs with even number of sectors)
            if (sector.maxValue > radians || sector.minValue < radians) {
                // 5 - Find the quadrant (positive or negative)
                _currentSector = sector.sectorNumber;
            }
        } else if ([sector contains:radians]) { // 6 - All non-anomalous cases
            _currentSector = sector.sectorNumber;
        }
    }
    int index = [self getCurrentIndex];
    [self setLabelForIndex:index];
    [self.delegate wheelDidChangeValue:index];


    return YES;
}

-(void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
    // 1 - Get current container rotation in radians
    CGFloat radians = atan2f(_container.transform.b, _container.transform.a);
    CGFloat newValue = 0.0;
    // 3 - Iterate through all the sectors
    
    [self resetLabelForIndex:[self getCurrentIndex]];

    for (JHSector *sector in _sectors) {
        if (sector.minValue > 0 && sector.maxValue < 0) { // 4 - Check for anomaly (occurs with even number of sectors)
            if (sector.maxValue > radians || sector.minValue < radians) {
                // 5 - Find the quadrant (positive or negative)
                newValue = (radians > 0) ? radians - M_PI : radians + M_PI;
                _currentSector = sector.sectorNumber;
            }
        } else if ([sector contains:radians]) { // 6 - All non-anomalous cases
            newValue = radians - sector.midValue;
            _currentSector = sector.sectorNumber;
        }
    }
    
    // 7 - Set up animation for final rotation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform transform = CGAffineTransformRotate(_container.transform, -newValue);
    _container.transform = transform;
    [UIView commitAnimations];

    int index = [self getCurrentIndex];
    [self setLabelForIndex:index];
    
    [self.delegate wheelDidChangeValue:index];
}

-(float)calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2.0f, CGRectGetHeight(self.bounds)/2.0f);
    return sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2));
}

-(void)buildSectorsOdd {
	// 1 - Define sector length
    CGFloat fanWidth = M_PI*2/_numberOfSections;
	// 2 - Set initial midpoint
    CGFloat mid = 0.0f;
	// 3 - Iterate through all sectors
    for (int i = 0; i < _numberOfSections; i++) {
        JHSector *sector = [[JHSector alloc] init];
		// 4 - Set sector values
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sectorNumber = i;
        mid -= fanWidth;
        if (sector.minValue < -M_PI) {
            mid = -mid;
            mid -= fanWidth; 
        }
		// 5 - Add sector to array
        [_sectors addObject:sector];
    }
}

-(void)buildSectorsEven {
    // 1 - Define sector length
    CGFloat fanWidth = M_PI*2/_numberOfSections;
    // 2 - Set initial midpoint
    CGFloat mid = 0;
    // 3 - Iterate through all sectors
    for (int i = 0; i < _numberOfSections; i++) {
        JHSector *sector = [[JHSector alloc] init];
        // 4 - Set sector values
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sectorNumber = i;
        if (sector.maxValue-fanWidth < -M_PI) {
            mid = M_PI;
            sector.midValue = mid;
            sector.minValue = fabsf(sector.maxValue);            
        }
        mid -= fanWidth;
        // 5 - Add sector to array
        [_sectors addObject:sector];
    }
}

-(int)getCurrentIndex {
    float rads = ((JHSector*)[_sectors objectAtIndex:_currentSector]).midValue;
    if (rads < 0) {rads += 2 * M_PI;}
    return roundf(_numberOfSections * rads/(2*M_PI));
}

-(void)resetLabelForIndex:(int)index {
    UILabel *label = [_sectorLabels objectAtIndex:index];
    label.alpha = oldAlphaValue;
    if (skipLabels && (index % skipCount)) {
        label.text = @"•";
    } else {
        label.text = [[[_labels objectAtIndex:index] componentsSeparatedByString:@"\n"] objectAtIndex:0];        
    }
    label.numberOfLines = 1;
    label.shadowOffset = CGSizeMake(0.f, 0.f);
}

-(void)setLabelForIndex:(int)index {
    UILabel *label = [_sectorLabels objectAtIndex:index];
    oldAlphaValue = label.alpha;
    label.alpha = maxAlphaValue;

    if (skipLabels && (index % (skipCount/2))) {
        label.text = @"•";
    }else {
        label.text = [_labels objectAtIndex:index];
    }
    
    label.numberOfLines = 2;
    label.shadowOffset = CGSizeMake(0.f, 1.f);
}



@end
