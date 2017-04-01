//
//  ViewController.m
//  MazeDrag
//
//  Created by Andrew Solesa on 2017-03-31.
//  Copyright © 2017 KSG. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) UIImageView *levelView;
@property (nonatomic) UIImageView *originalPieceView;
@property (nonatomic) UIImageView *homeView;

@property NSDictionary *level0;
@property NSDictionary *level1;
@property NSDictionary *level2;
@property NSDictionary *level3;
@property NSDictionary *levels;

@property int level;
@property BOOL animationFlag;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _level0 = @{ @"name" : @"level_0", @"homeX" : @140, @"homeY" : @-10, @"pieceX" : @-140, @"pieceY" : @-10};
    _level1 = @{ @"name" : @"level_1", @"homeX" : @75, @"homeY" : @-195, @"pieceX" : @-147, @"pieceY" : @295};
    _levels = [[NSDictionary alloc] initWithObjectsAndKeys:_level0, @"0", _level1, @"1", nil];
    
    _level = 0;
    
    [self createLevel:_levels level:_level];
    
}

- (void) createLevel : (NSDictionary *) levelDict level: (int) levelNumber
{
    self.levelView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.levelView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.levelView.image = [UIImage imageNamed:[levelDict valueForKeyPath: [NSString stringWithFormat:@"%d.%@", levelNumber, @"name"]]];
    
    [self.view addSubview:self.levelView];
    
    NSLayoutConstraint *levelBottom = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0.0];
    
    NSLayoutConstraint *levelLeft = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0.0];
    
    NSLayoutConstraint *levelTop = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    NSLayoutConstraint *levelRight = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self.view addConstraint:levelLeft];
    [self.view addConstraint:levelRight];
    [self.view addConstraint:levelTop];
    [self.view addConstraint:levelBottom];
    
    NSNumber *x;
    CGFloat newX;
    NSNumber *y;
    CGFloat newY;
    
    x = [levelDict valueForKeyPath: [NSString stringWithFormat:@"%d.%@", levelNumber, @"homeX"]];
    newX = [x floatValue];
    
    y = [levelDict valueForKeyPath: [NSString stringWithFormat:@"%d.%@", levelNumber, @"homeY"]];
    newY = [y floatValue];
    
    [self createHomeX:&newX Y:&newY];
    
    x = [levelDict valueForKeyPath: [NSString stringWithFormat:@"%d.%@", levelNumber, @"pieceX"]];
    newX = [x floatValue];
    
    y = [levelDict valueForKeyPath: [NSString stringWithFormat:@"%d.%@", levelNumber, @"pieceY"]];
    newY = [y floatValue];
    
    [self createPieceX:&newX Y:&newY];
}

- (void) createHomeX : (CGFloat *) X Y: (CGFloat *) Y
{
    self.homeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.homeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.homeView.contentMode = UIViewContentModeScaleAspectFit;
    self.homeView.image = [UIImage imageNamed:@"homePlate"];
    
    [self.view addSubview:self.homeView];
    
    NSLayoutConstraint *homeX = [NSLayoutConstraint constraintWithItem:self.homeView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:*X];
    
    NSLayoutConstraint *homeY = [NSLayoutConstraint constraintWithItem:self.homeView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:*Y];
    
    
    [self.view addConstraint:homeX];
    [self.view addConstraint:homeY];
}

- (void) createPieceX : (CGFloat *) X Y: (CGFloat *) Y
{
    self.originalPieceView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.originalPieceView.translatesAutoresizingMaskIntoConstraints = NO;
    self.originalPieceView.contentMode = UIViewContentModeScaleAspectFit;
    self.originalPieceView.image = [UIImage imageNamed:@"piecePlate"];
    
    [self.view addSubview:self.originalPieceView];
    
    NSLayoutConstraint *pieceX = [NSLayoutConstraint constraintWithItem:self.originalPieceView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:*X];
    
    NSLayoutConstraint *pieceY = [NSLayoutConstraint constraintWithItem:self.originalPieceView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:*Y];
    
    
    [self.view addConstraint:pieceX];
    [self.view addConstraint:pieceY];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [self.originalPieceView addGestureRecognizer:pan];
    self.originalPieceView.userInteractionEnabled = YES;
}

- (NSNumber *) loadPiece : (NSString *) XY
{
    NSNumber *coordinate;
    
    if ([XY isEqualToString:@"X"])
    {
        coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceX"]];
    }
    else
    {
        coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceY"]];
    }
    
    return coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)panPiece:(UIPanGestureRecognizer *)pan
{
    if (!self.animationFlag)
    {
        if (pan.state == UIGestureRecognizerStateChanged)
        {
            CGPoint point = [pan locationInView:self.view];
            self.originalPieceView.center = point;
        }
        
        CGRect piece = self.originalPieceView.frame;
        
        if ([self pixelColorInImage:[self.levelView image] atX:piece.origin.x atY:piece.origin.y] == [UIColor blueColor]
            || [self pixelColorInImage:[self.levelView image] atX:piece.origin.x + piece.size.width atY:piece.origin.y + piece.size.height])
        {
            NSLog(@"HIT WATER");
            
            if (!self.animationFlag)
            {
                self.animationFlag = YES;
        
                [UIImageView animateWithDuration:2.0 animations:^(void)
                 {
                     self.originalPieceView.alpha = 0.0;
                 }
                                  completion:^(BOOL completion)
                 {
                     [self.originalPieceView removeFromSuperview];
                 
                     CGFloat newX;
                     CGFloat newY;
                     
                     newX = [[self loadPiece:@"X"] floatValue];
                     newY = [[self loadPiece:@"Y"] floatValue];
                     
                     [self createPieceX:&newX Y:&newY];
                     
                     self.animationFlag = NO;
                 }];
            }
        }
        
        if (pan.state == UIGestureRecognizerStateEnded)
        {
            if (CGRectIntersectsRect(self.originalPieceView.frame, self.homeView.frame))
            {
                if (!self.animationFlag)
                {
                    self.animationFlag = YES;
                
                    [UIImageView animateWithDuration:2.0 animations:^(void)
                     {
                         self.originalPieceView.alpha = 0.0;
                     }
                                          completion:^(BOOL completion)
                     {
                         [self.originalPieceView removeFromSuperview];
                         
                         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You beat level %d", self.level] preferredStyle:UIAlertControllerStyleAlert];
                         
                         [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                         {
                             [self closeAlertview];
                         }]];
                         
                         [self presentViewController:alertController animated:YES completion:nil];
                     }];
                }
            }
        }
    }
    
    
}

-(void)closeAlertview
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.level++;
    [self createLevel:self.levels level:self.level];
    _animationFlag = NO;
}

- (UIColor *)pixelColorInImage: (UIImage*) mazeImage atX:(int)x atY:(int)y
{
    CGImageRef imageRef = [mazeImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int index = 4*((width*round(y))+round(x));
    
    int R = rawData[index];
    
    UIColor *boundaries;
    
    switch (R)
    {
            // The numbers below are possible color's of the water tile
        case 36:
        case 37:
        case 38:
        case 40:
        case 42:
        case 44:
        case 45:
            boundaries = [UIColor blueColor];
            break;
    }
    
    return boundaries;
}

@end
