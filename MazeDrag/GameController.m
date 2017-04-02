//
//  ViewController.m
//  MazeDrag
//
//  Created by Andrew Solesa on 2017-03-31.
//  Copyright © 2017 KSG. All rights reserved.
//

#import "GameController.h"

@interface GameController ()
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

@implementation GameController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _level0 = @{ @"name" : @"level_0", @"homeX" : @140, @"homeY" : @-10, @"pieceX" : @-140, @"pieceY" : @-10};
    _level1 = @{ @"name" : @"level_1", @"homeX" : @75, @"homeY" : @-195, @"pieceX" : @-147, @"pieceY" : @295};
    _levels = [[NSDictionary alloc] initWithObjectsAndKeys:_level0, @"0", _level1, @"1", _level2, @"2", nil];
    
    _level = 0;
    
    [self createLevel: _level];
    
}

- (void) createLevel : (int) levelNumber
{
    self.levelView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.levelView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.levelView.image = [UIImage imageNamed:[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", levelNumber, @"name"]]];
    
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
    
    CGFloat newX;
    CGFloat newY;
    
    newX = [[self loadPiece:@"X" Home: YES] floatValue];
    newY = [[self loadPiece:@"Y" Home: YES] floatValue];
    
    [self createHomeX:&newX Y:&newY];
    
    newX = [[self loadPiece:@"X" Home: NO] floatValue];
    newY = [[self loadPiece:@"Y" Home: NO] floatValue];
    
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
    
    if (_level > 0)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
        tap.numberOfTapsRequired = 1;
        [self.originalPieceView addGestureRecognizer:tap];
    }
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [self.originalPieceView addGestureRecognizer:pan];
    
    self.originalPieceView.userInteractionEnabled = YES;
}

- (NSNumber *) loadPiece : (NSString *) XY Home: (BOOL) home
{
    NSNumber *coordinate;
    
    if ([XY isEqualToString:@"X"])
    {
        if (home)
        {
            coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"homeX"]];
        }
        else
        {
            coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceX"]];
        }
    }
    else
    {
        if (home)
        {
            coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"homeY"]];
        }
        else
        {
            coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceY"]];
        }
    }
    
    return coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) tapPiece : (UITapGestureRecognizer *) tap
{
    CGRect rect = [self.originalPieceView frame];
    
    if ([self.originalPieceView frame].size.height == 30)
    {
        rect.size.width = 23.0f;
        rect.size.height = 22.0f;
    }
    else
    {
        rect.size.width = 31.0f;
        rect.size.height = 30.0f;
    }
    
    [self.originalPieceView setFrame:rect];
}

- (void) panPiece : (UIPanGestureRecognizer *) pan
{
    if (!self.animationFlag)
    {
        if (pan.state == UIGestureRecognizerStateChanged)
        {
            self.originalPieceView.center = [pan locationInView:self.view];
        }
        
        [self checkBoundaries: self.originalPieceView.frame];
        
        [self checkHome: pan];
    }
}

- (void) checkBoundaries : (CGRect) piece
{
    if ([self pixelColorInImage:[self.levelView image] atX:piece.origin.x atY:piece.origin.y] == [UIColor blueColor]
        || [self pixelColorInImage:[self.levelView image] atX:piece.origin.x + piece.size.width atY:piece.origin.y + piece.size.height])
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
                 
                 CGFloat newX;
                 CGFloat newY;
                 
                 newX = [[self loadPiece:@"X" Home: NO] floatValue];
                 newY = [[self loadPiece:@"Y" Home: NO] floatValue];
                 
                 [self createPieceX:&newX Y:&newY];
                 
                 self.animationFlag = NO;
             }];
        }
    }
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
    
    int index = 4 * ( (width * round(y) ) + round(x) );
    
    int R = rawData[index];
    
    UIColor *boundaries;
    
    switch (R)
    {
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

- (void) checkHome : (UIPanGestureRecognizer *) pan
{
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (CGRectIntersectsRect(self.originalPieceView.frame, self.homeView.frame))
        {
            if ([self.originalPieceView frame].size.height == 30)
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
                     
                         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You beat level %d", self.level + 1] preferredStyle:UIAlertControllerStyleAlert];
                     
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

- (void) closeAlertview
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.level++;
    [self createLevel: self.level];
    _animationFlag = NO;
}

@end
