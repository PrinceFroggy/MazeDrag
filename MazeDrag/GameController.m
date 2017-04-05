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
@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property __block long totalSecconds;
@property __block long pausedSeconds;

@property (nonatomic) UIImageView *home;
@property (nonatomic) UIImageView *upgrade;

@property (nonatomic) UIImageView *monster;
@property int monsterNumber;
@property int monsterTaps;

@property (nonatomic) UIImageView *draggablePiece;

@property NSDictionary *level0;
@property NSDictionary *level1;
@property NSDictionary *level2;
@property NSDictionary *level3;
@property NSDictionary *levels;

@property int level;
@property BOOL timerFlag;
@property BOOL animationFlag;

// MAP IS RENDERING PIECE LAST TO BE ABOVE ASSETS

#define HOME 0
#define UPGRADE 1
#define MONSTER 2
#define PIECE 3

#define EASY_MONSTER 0
#define MEDIUM_MONSTER 1
#define HARD_MONSTER 2

@property UIAlertController *alertController;
@end

@implementation GameController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _level0 = @{ @"name" : @"level_0", @"homeX" : @140, @"homeY" : @-10, @"pieceX" : @-140, @"pieceY" : @-10, @"monster": @NO};
    _level1 = @{ @"name" : @"level_1", @"homeX" : @75, @"homeY" : @-195, @"upgrade": @YES, @"upgradeX" : @104, @"upgradeY" : @40, @"pieceX" : @-147, @"pieceY" : @295, @"monster": @NO};
    _level2 = @{ @"name" : @"level_2", @"homeX" : @1, @"homeY" : @-275, @"upgrade": @YES, @"upgradeX" : @40, @"upgradeY" : @288, @"pieceX" : @-40, @"pieceY" : @290, @"monster": @YES, @"monsters" : @3, @"monster0" : @EASY_MONSTER, @"monster0X": @1, @"monster0Y": @140, @"monster1" : @MEDIUM_MONSTER, @"monster1X": @1, @"monster1Y": @4, @"monster2" : @HARD_MONSTER, @"monster2X": @1, @"monster2Y": @-130 };
    _level3 = @{ @"name" : @"level_3", @"homeX" : @-100, @"homeY" :@-304, @"upgrade": @NO, @"pieceX" : @150, @"pieceY" : @290, @"monster": @YES, @"monsters" : @1, @"monster0" : @EASY_MONSTER, @"monster0X": @-102, @"monster0Y": @94};
    _levels = [[NSDictionary alloc] initWithObjectsAndKeys:_level0, @"0", _level1, @"1", _level2, @"2", _level3, @"3", nil];
    
    _level = 0;
    
    [self createLevel: _level];
}

- (void) createLevel : (int) level
{
    for (int i = 0; i < 3; i ++)
    {
        if ([self.view.subviews containsObject:[self.view viewWithTag:i + 100]])
        {
            self.monster = [self.view viewWithTag:i + 100];
            
            [self.monster removeFromSuperview];
        }
    }
    
    self.levelView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.levelView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.levelView.image = [UIImage imageNamed:[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", level, @"name"]]];
    
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
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLevel:)];
    [self.levelView addGestureRecognizer:swipe];
    
    self.levelView.userInteractionEnabled = YES;
    
    [self.view bringSubviewToFront:self.menuView];
    [self.view bringSubviewToFront:self.timerLabel];
    
    CGFloat newX;
    CGFloat newY;
    
    newX = [[self loadPiece:@"X" Piece: HOME] floatValue];
    newY = [[self loadPiece:@"Y" Piece: HOME] floatValue];
    
    [self createHomeAtX:newX andY:newY];
    
    if ([[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"upgrade"]] isEqual:@YES])
    {
        newX = [[self loadPiece:@"X" Piece: UPGRADE] floatValue];
        newY = [[self loadPiece:@"Y" Piece: UPGRADE] floatValue];
        
        [self createUpgradeAtX:newX andY:newY];
    }
    
    if ([[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monster"]] isEqual:@YES])
    {
        for (int monsters = 0; monsters < [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monsters"]] intValue]; monsters++)
        {
            self.monsterNumber = monsters;
            
            newX = [[self loadPiece:@"X" Piece: MONSTER] floatValue];
            newY = [[self loadPiece:@"Y" Piece: MONSTER] floatValue];
            
            // RANDOM MONSTERS
            
            // [self createMonsterAtX:newX andY:newY andMonster: (1 + arc4random() % (3 - 1+1))];
            
            // ORDERED MONSTERS
            
            [self createMonsterAtX:newX andY:newY andMonster: [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, [NSString stringWithFormat:@"monster%d", monsters]]] intValue]];
            
            [self.monster setTag: monsters + 100];
            
            self.monster = [self.view viewWithTag:monsters + 100];
        }
    }
    
    newX = [[self loadPiece:@"X" Piece: PIECE] floatValue];
    newY = [[self loadPiece:@"Y" Piece: PIECE] floatValue];
    
    [self createDraggablePieceAtX:newX andY:newY];
}

- (void) setDefaultTimer
{
    self.totalSecconds = 0;
}

- (void) createHomeAtX : (CGFloat) X andY: (CGFloat) Y
{
    self.home = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.home.translatesAutoresizingMaskIntoConstraints = NO;
    self.home.contentMode = UIViewContentModeScaleAspectFit;
    self.home.image = [UIImage imageNamed:@"home"];
    
    [self.view addSubview:self.home];
    
    NSLayoutConstraint *homeX = [NSLayoutConstraint constraintWithItem:self.home
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:X];
    
    NSLayoutConstraint *homeY = [NSLayoutConstraint constraintWithItem:self.home
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:Y];
    
    
    [self.view addConstraint:homeX];
    [self.view addConstraint:homeY];
}

- (void) createUpgradeAtX: (CGFloat) X andY: (CGFloat) Y
{
    self.upgrade = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.upgrade.translatesAutoresizingMaskIntoConstraints = NO;
    self.upgrade.contentMode = UIViewContentModeScaleAspectFit;
    self.upgrade.image = [UIImage imageNamed:@"upgrade"];
    
    [self.view addSubview:self.upgrade];
    
    NSLayoutConstraint *upgradeX = [NSLayoutConstraint constraintWithItem:self.upgrade
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:X];
    
    NSLayoutConstraint *upgradeY = [NSLayoutConstraint constraintWithItem:self.upgrade
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:Y];
    
    
    [self.view addConstraint:upgradeX];
    [self.view addConstraint:upgradeY];
}

- (void) createDraggablePieceAtX : (CGFloat) X andY: (CGFloat) Y
{
    self.draggablePiece = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.draggablePiece.translatesAutoresizingMaskIntoConstraints = NO;
    self.draggablePiece.contentMode = UIViewContentModeScaleAspectFit;
    self.draggablePiece.image = [UIImage imageNamed:@"draggablePiece"];
    
    [self.view addSubview:self.draggablePiece];
    
    NSLayoutConstraint *pieceX = [NSLayoutConstraint constraintWithItem:self.draggablePiece
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:X];
    
    NSLayoutConstraint *pieceY = [NSLayoutConstraint constraintWithItem:self.draggablePiece
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:Y];
    
    
    [self.view addConstraint:pieceX];
    [self.view addConstraint:pieceY];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    
    [self.draggablePiece addGestureRecognizer:pan];
    
    switch (self.level)
    {
        case 2:
            [self addPieceTapGesture];
            break;
            
        case 3:
            [self addPieceTapGesture];
            
            for (int monsters = 0; monsters < [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monsters"]] intValue]; monsters++)
            {
                self.monster = [self.view viewWithTag:monsters + 100];
                
                [self addMonsterTapGesture : [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, [NSString stringWithFormat:@"monster%d", monsters]]] intValue]];
            }

            break;
    }
    
    self.draggablePiece.userInteractionEnabled = YES;
}

- (void) createMonsterAtX: (CGFloat) X andY: (CGFloat) Y andMonster: (int) monsterType
{
    switch (monsterType)
    {
        case EASY_MONSTER:
        {
            self.monster = [[UIImageView alloc] init];
            self.monster.translatesAutoresizingMaskIntoConstraints = NO;
            self.monster.contentMode = UIViewContentModeScaleAspectFit;
            self.monster.image = [UIImage imageNamed:@"monster0"];
            
            [self.view addSubview:self.monster];
            
            NSLayoutConstraint *pieceX = [NSLayoutConstraint constraintWithItem:self.monster
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:X];
            
            NSLayoutConstraint *pieceY = [NSLayoutConstraint constraintWithItem:self.monster
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:Y];
            
            
            [self.view addConstraint:pieceX];
            [self.view addConstraint:pieceY];
            
            break;
        }
            
        case MEDIUM_MONSTER:
        {
            self.monster = [[UIImageView alloc] init];
            self.monster.translatesAutoresizingMaskIntoConstraints = NO;
            self.monster.contentMode = UIViewContentModeScaleAspectFit;
            self.monster.image = [UIImage imageNamed:@"monster1"];
            
            [self.view addSubview:self.monster];
            
            NSLayoutConstraint *pieceX = [NSLayoutConstraint constraintWithItem:self.monster
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:X];
            
            NSLayoutConstraint *pieceY = [NSLayoutConstraint constraintWithItem:self.monster
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:Y];
            
            
            [self.view addConstraint:pieceX];
            [self.view addConstraint:pieceY];
            
            break;
        }
            
        case HARD_MONSTER:
        {
            self.monster = [[UIImageView alloc] init];
            self.monster.translatesAutoresizingMaskIntoConstraints = NO;
            self.monster.contentMode = UIViewContentModeScaleAspectFit;
            self.monster.image = [UIImage imageNamed:@"monster2"];
            
            [self.view addSubview:self.monster];
            
            NSLayoutConstraint *pieceX = [NSLayoutConstraint constraintWithItem:self.monster
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:X];
            
            NSLayoutConstraint *pieceY = [NSLayoutConstraint constraintWithItem:self.monster
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:Y];
            
            
            [self.view addConstraint:pieceX];
            [self.view addConstraint:pieceY];
            
            break;
        }
    }
}

- (NSNumber *) loadPiece : (NSString *) XY Piece: (int) piece
{
    NSNumber *coordinate;
    
    if ([XY isEqualToString:@"X"])
    {
        switch (piece)
        {
            case HOME:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"homeX"]];
                break;
            }
                
            case UPGRADE:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"upgradeX"]];
                break;
            }
                
            case MONSTER:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, [NSString stringWithFormat:@"monster%dX", self.monsterNumber]]];
                break;
            }
                
            case PIECE:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceX"]];
                break;
            }
        }
    }
    else
    {
        switch (piece)
        {
            case HOME:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"homeY"]];
                break;
            }
                
            case UPGRADE:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"upgradeY"]];
                break;
            }
             
            case MONSTER:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, [NSString stringWithFormat:@"monster%dY", self.monsterNumber]]];
                break;
            }
                
            case PIECE:
            {
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceY"]];
                break;
            }
        }
    }
    
    return coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) swipeLevel : (UISwipeGestureRecognizer *) swipe
{
    if (self.totalSecconds != 0)
    {
        self.pausedSeconds = self.totalSecconds;
    
        [self.timer invalidate];
    }
    
    [self.menuView setHidden: NO];
    [self.view bringSubviewToFront:self.menuView];
}

- (void) addPieceTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
    tap.numberOfTapsRequired = 1;
    [self.draggablePiece addGestureRecognizer:tap];
}

- (void) addMonsterTapGesture : (int) monsterType
{
    for (int monsters = 0; monsters < [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monsters"]] intValue]; monsters++)
    {
        switch (monsterType)
        {
            case 0:
            {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEasyMonster:)];
                tap.numberOfTapsRequired = 1;
                [self.monster addGestureRecognizer:tap];
                break;
            }
                
            case 1:
            {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMediumMonster:)];
                tap.numberOfTapsRequired = 1;
                [self.monster addGestureRecognizer:tap];
                break;
            }
                
            case 2:
            {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHardMonster:)];
                tap.numberOfTapsRequired = 1;
                [self.monster addGestureRecognizer:tap];
                break;
            }
        }
        
        self.monster.userInteractionEnabled = YES;
    }

}

- (void) tapPiece : (UITapGestureRecognizer *) tap
{
    CGRect rect = [self.draggablePiece frame];
    
    if ([self.draggablePiece frame].size.height == 30)
    {
        rect.size.width = 23.0f;
        rect.size.height = 22.0f;
    }
    else
    {
        rect.size.width = 31.0f;
        rect.size.height = 30.0f;
    }
    
    [self.draggablePiece setFrame:rect];
}

- (void) panPiece : (UIPanGestureRecognizer *) pan
{
    if (!self.timerFlag)
    {
        self.totalSecconds = 61;
        
        self.timer = [NSTimer
                      scheduledTimerWithTimeInterval:1
                      repeats:YES
                      block:^(NSTimer * _Nonnull timer)
                      {
                          self.totalSecconds--;
                          long minutes = self.totalSecconds / 60;
                          int seconds = self.totalSecconds % 60;
                          
                          self.timerLabel.text = [NSString stringWithFormat:@"%ld:%02d", minutes, seconds];
                          
                          if (self.totalSecconds == 0)
                          {
                              [self pieceDeath];
                          }
                      }];
        
        _timerFlag = YES;
    }
    
    if (!self.animationFlag)
    {
        if (pan.state == UIGestureRecognizerStateChanged)
        {
            self.draggablePiece.center = [pan locationInView:self.view];
        }
        
        [self checkWaterBoundaries: self.draggablePiece.frame];
        
        [self checkHomeBoundaries: pan];
        
        [self checkUpgradeBoundaries: pan];
        
        [self checkMonsterBoundaries: pan];
    }
}

- (void) checkWaterBoundaries : (CGRect) piece
{
    if ([self pixelColorInImage:[self.levelView image] atX:piece.origin.x atY:piece.origin.y] == [UIColor blueColor]
        || [self pixelColorInImage:[self.levelView image] atX:piece.origin.x + piece.size.width atY:piece.origin.y + piece.size.height])
    {
        [self pieceDeath];
    }
}

- (void) pieceDeath
{
    if (!self.animationFlag)
    {
        self.animationFlag = YES;
        
        [self.timer invalidate];
        
        [UIImageView animateWithDuration:2.0 animations:^(void)
         {
             self.draggablePiece.alpha = 0.0;
         }
                              completion:^(BOOL completion)
         {
             [self.draggablePiece removeFromSuperview];
             
             [self setDefaultTimer];
             self.timerLabel.text = @"";

             if ([self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"upgrade"]])
             {
                 [self regenerateUpgrade];
             }
             
             if ([self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monster"]])
             {
                 for (int monsters = 0; monsters < [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monsters"]] intValue]; monsters++)
                 {
                     self.monster = [self.view viewWithTag:monsters + 100];
                     
                     for (UIGestureRecognizer *gr in self.monster.gestureRecognizers)
                     {
                         [self.monster removeGestureRecognizer:gr];
                     }
                     
                     [self regenerateMonster:self.monster];
                 }

             }
             
             CGFloat newX;
             CGFloat newY;
             
             newX = [[self loadPiece:@"X" Piece: PIECE] floatValue];
             newY = [[self loadPiece:@"Y" Piece: PIECE] floatValue];
             
             [self createDraggablePieceAtX:newX andY:newY];
             
             [self.view bringSubviewToFront:self.draggablePiece];
             
             self.timerFlag = NO;
             self.animationFlag = NO;
         }];
    }
    
}

- (void) regenerateUpgrade
{
    if (self.upgrade.alpha == 0.0)
    {
        self.upgrade.alpha = 1.0;
    }
}

- (void) regenerateMonster : (UIImageView *) view
{
    if (view.alpha == 0.0)
    {
        view.alpha = 1.0;
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

- (void) checkHomeBoundaries : (UIPanGestureRecognizer *) pan
{
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (CGRectIntersectsRect(self.draggablePiece.frame, self.home.frame))
        {
            if ([self.draggablePiece frame].size.height == 30)
            {
                if (!self.animationFlag)
                {
                    self.animationFlag = YES;
                    
                    [self.timer invalidate];
                    
                    [UIImageView animateWithDuration:2.0 animations:^(void)
                     {
                         self.draggablePiece.alpha = 0.0;
                     }
                                          completion:^(BOOL completion)
                     {
                         [self.draggablePiece removeFromSuperview];
                         
                         [self setDefaultTimer];
                         self.timerLabel.text = @"";
                         
                         self.alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You beat level %d", self.level + 1] preferredStyle:UIAlertControllerStyleAlert];
                         
                         [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                          {
                                                              [self closeCongratulationsView];
                                                          }]];
                         
                         [self presentViewController:self.alertController animated:YES completion:nil];
                         
                         self.timerFlag = NO;
                         self.animationFlag = NO;
                     }];
                }
            }
        }
    }
}

- (void) closeCongratulationsView
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    self.level++;
    [self createLevel: self.level];
}

- (void) checkUpgradeBoundaries : (UIPanGestureRecognizer *) pan
{
    if ([self isUpgradeAvailable])
    {
        if (pan.state == UIGestureRecognizerStateEnded)
        {
            if (CGRectIntersectsRect(self.draggablePiece.frame, self.upgrade.frame))
            {
                if ([self.draggablePiece frame].size.height == 30)
                {
                    if (!self.animationFlag)
                    {
                        self.animationFlag = YES;
                        
                        [UIImageView animateWithDuration:2.0 animations:^(void)
                         {
                             self.upgrade.alpha = 0.0;
                         }
                                              completion:^(BOOL completion)
                         {
                             switch (self.level)
                             {
                                 case 1:
                                 {
                                    self.alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You unlocked the tap upgrade!"] preferredStyle:UIAlertControllerStyleAlert];
                             
                                     [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                              {
                                                                  [self closeUpgradeView];
                                                              }]];
                                     break;
                                 }
                                 
                                 case 2:
                                 {
                                     self.alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You unlocked the attack upgrade!"] preferredStyle:UIAlertControllerStyleAlert];
                                     
                                     [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                                      {
                                                                          [self closeUpgradeView];
                                                                      }]];
                                     break;
                                 }
                             }
                             
                             [self presentViewController:self.alertController animated:YES completion:nil];
                             
                             self.animationFlag = NO;
                         }];
                    }
                }
            }
        }
    }
}

- (BOOL) isUpgradeAvailable
{
    return self.upgrade.alpha == 1.0 ? YES : NO;
}

- (void) closeUpgradeView
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    
    switch (self.level)
    {
        case 1:
        {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
            tap.numberOfTapsRequired = 1;
            [self.draggablePiece addGestureRecognizer:tap];
            break;
        }
            
        case 2:
        {
            for (int monsters = 0; monsters < [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monsters"]] intValue]; monsters++)
            {
                self.monster = [self.view viewWithTag:monsters + 100];
                
                switch ([[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, [NSString stringWithFormat:@"monster%d", monsters]]] intValue])
                {
                    case 0:
                    {
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEasyMonster:)];
                        tap.numberOfTapsRequired = 1;
                        [self.monster addGestureRecognizer:tap];
                        break;
                    }
                        
                    case 1:
                    {
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMediumMonster:)];
                        tap.numberOfTapsRequired = 1;
                        [self.monster addGestureRecognizer:tap];
                        break;
                    }
                        
                    case 2:
                    {
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHardMonster:)];
                        tap.numberOfTapsRequired = 1;
                        [self.monster addGestureRecognizer:tap];
                        break;
                    }
                }
                
                self.monster.userInteractionEnabled = YES;
            }
            break;
        }
    }
}

- (void) checkMonsterBoundaries : (UIPanGestureRecognizer *) pan
{
    for (int monsters = 0; monsters < [[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"monsters"]] intValue]; monsters++)
    {
        self.monster = [self.view viewWithTag:monsters + 100];
        
        if ([self isMonsterAvailable:self.monster])
        {
            if (CGRectIntersectsRect(self.draggablePiece.frame, self.monster.frame))
            {
                [self pieceDeath];
            }
        }
    }
}

- (void) tapEasyMonster : (UITapGestureRecognizer *) tap
{
    if ([self isMonsterAvailableTapped:tap])
    {
        int previousX = self.draggablePiece.frame.origin.x;
        int previousY = self.draggablePiece.frame.origin.y;
        
        if ([self.draggablePiece frame].size.height == 30)
        {
            if ([self distanceToView:self.draggablePiece andMonster:tap.view] > 30 && [self distanceToView:self.draggablePiece andMonster:tap.view] < 50)
            {
                self.monsterTaps++;
                
                [UIImageView animateWithDuration:0.5 animations:^(void)
                 {
                     self.draggablePiece.frame = CGRectMake(tap.view.frame.origin.x, tap.view.frame.origin.y, self.draggablePiece.frame.size.width, self.draggablePiece.frame.size.height );
                 }
                                      completion:^(BOOL completion)
                 {
                     [UIImageView animateWithDuration:0.5 animations:^(void)
                      {
                          self.draggablePiece.frame = CGRectMake(previousX, previousY, self.draggablePiece.frame.size.width, self.draggablePiece.frame.size.height );
                      }
                                           completion:^(BOOL completion)
                      {
                          if (self.monsterTaps == 1)
                          {
                              [UIImageView animateWithDuration:2.0 animations:^(void)
                               {
                                   tap.view.alpha = 0.0;
                               }
                                                    completion:^(BOOL completion)
                               {
                                   self.monsterTaps = 0;
                               }];
                          }
                      }];
                 }];
            }
        }
    }
}

- (void) tapMediumMonster : (UITapGestureRecognizer *) tap
{
    if ([self isMonsterAvailableTapped:tap])
    {
        int previousX = self.draggablePiece.frame.origin.x;
        int previousY = self.draggablePiece.frame.origin.y;
        
        if ([self.draggablePiece frame].size.height == 30)
        {
            if ([self distanceToView:self.draggablePiece andMonster:tap.view] > 30 && [self distanceToView:self.draggablePiece andMonster:tap.view] < 50)
            {
                self.monsterTaps++;
                
                [UIImageView animateWithDuration:0.5 animations:^(void)
                 {
                     self.draggablePiece.frame = CGRectMake(tap.view.frame.origin.x, tap.view.frame.origin.y, self.draggablePiece.frame.size.width, self.draggablePiece.frame.size.height );
                 }
                                      completion:^(BOOL completion)
                 {
                     [UIImageView animateWithDuration:0.5 animations:^(void)
                      {
                          self.draggablePiece.frame = CGRectMake(previousX, previousY, self.draggablePiece.frame.size.width, self.draggablePiece.frame.size.height );
                      }
                                           completion:^(BOOL completion)
                      {
                          if (self.monsterTaps == 2)
                          {
                              [UIImageView animateWithDuration:2.0 animations:^(void)
                               {
                                   tap.view.alpha = 0.0;
                               }
                                                    completion:^(BOOL completion)
                               {
                                   self.monsterTaps = 0;
                               }];
                          }
                      }];
                 }];
            }
        }
    }

}

- (void) tapHardMonster : (UITapGestureRecognizer *) tap
{
    if ([self isMonsterAvailableTapped:tap])
    {
        int previousX = self.draggablePiece.frame.origin.x;
        int previousY = self.draggablePiece.frame.origin.y;
        
        if ([self.draggablePiece frame].size.height == 30)
        {
            if ([self distanceToView:self.draggablePiece andMonster:tap.view] > 30 && [self distanceToView:self.draggablePiece andMonster:tap.view] < 50)
            {
                self.monsterTaps++;
                
                [UIImageView animateWithDuration:0.5 animations:^(void)
                 {
                     self.draggablePiece.frame = CGRectMake(tap.view.frame.origin.x, tap.view.frame.origin.y, self.draggablePiece.frame.size.width, self.draggablePiece.frame.size.height );
                 }
                                      completion:^(BOOL completion)
                 {
                     [UIImageView animateWithDuration:0.5 animations:^(void)
                      {
                          self.draggablePiece.frame = CGRectMake(previousX, previousY, self.draggablePiece.frame.size.width, self.draggablePiece.frame.size.height );
                      }
                                           completion:^(BOOL completion)
                      {
                          if (self.monsterTaps == 3)
                          {
                              [UIImageView animateWithDuration:2.0 animations:^(void)
                               {
                                   tap.view.alpha = 0.0;
                               }
                                                    completion:^(BOOL completion)
                               {
                                   self.monsterTaps = 0;
                               }];
                          }
                      }];
                 }];
            }
        }
    }

}

- (BOOL) isMonsterAvailable: (UIImageView *) view
{
    return view.alpha == 1.0 ? YES : NO;
}

- (BOOL) isMonsterAvailableTapped: (UITapGestureRecognizer *) tap
{
    return tap.view.alpha == 1.0 ? YES : NO;
}

-(double)distanceToView:(UIImageView *)piece andMonster: (UIView *) monster
{
    return sqrt(pow(piece.frame.origin.x - monster.frame.origin.x, 2) + pow(piece.frame.origin.y - monster.frame.origin.y, 2));
}

- (IBAction)resumeGame:(UIButton *)sender
{
    [self.menuView setHidden:YES];
    
    if (_totalSecconds != 0)
    {
        self.totalSecconds = self.pausedSeconds;
    
        self.timer = [NSTimer
                      scheduledTimerWithTimeInterval:1
                      repeats:YES
                      block:^(NSTimer * _Nonnull timer)
                      {
                          self.totalSecconds--;
                          long minutes = self.totalSecconds / 60;
                          int seconds = self.totalSecconds % 60;
                      
                          self.timerLabel.text = [NSString stringWithFormat:@"%ld:%02d", minutes, seconds];
                      
                          if (self.totalSecconds == 0)
                          {
                              [self pieceDeath];
                          }
                      }];
    }

}

@end
