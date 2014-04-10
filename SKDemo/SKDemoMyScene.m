//
//  SKDemoMyScene.m
//  SKDemo
//
//  Created by Heng Wang on 4/9/14.
//  Copyright (c) 2014 Heng Wang. All rights reserved.
//

#import "SKDemoMyScene.h"
#import "SKDemoGameOverScene.h"

static const uint32_t projectileCategory = 0x1 << 0;
static const uint32_t monsterCategory = 0x1 << 1;

static inline CGPoint rwAdd(CGPoint a, CGPoint b){
    return CGPointMake(a.x+b.x, a.y+b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b){
    return CGPointMake(a.x-b.x, a.y-b.y);
}

static inline CGPoint rwMulti(CGPoint a, float b){
    return CGPointMake(a.x*b, a.y*b);
}

static inline float rwLength(CGPoint a){
    return sqrtf(a.x*a.x + a.y*a.y);
}

static inline CGPoint rwNormalize(CGPoint a){
    float length = rwLength(a);
    return CGPointMake(a.x/length, a.y/length);
}

@interface SKDemoMyScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;

@end


@implementation SKDemoMyScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        NSLog(@"Size: %@", NSStringFromCGSize(size));

        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];

        self.player.position = CGPointMake(100, 100);

        [self addChild:self.player];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
    }
    return self;
}

/*
 -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Called when a touch begins

    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];

        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player"];

        sprite.position = location;

        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];

        [sprite runAction:[SKAction repeatActionForever:action]];

        [self addChild:sprite];
    }
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
    // 1. Choose one of the touches to work
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2. Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES; // This is important to set for fast moving bodies (like projectiles), because otherwise there is a chance that two fast moving bodies can pass through each other without a collision being detected.
    
    // 3. Determine the offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4. Bail out if you are shooting down or backwards, this game does not allow the ninja to shoot backwards.
    if (offset.x <=0 ) return;
    
    // 5. OK to add now - we've double check the position
    [self addChild:projectile];
    
    // 6. Get the direction where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7. Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmout = rwMulti(direction, 1000);
    
    // 8. Add the shoot amount to the current position
    CGPoint realDest = rwAdd(projectile.position, shootAmout);
    
    // 9. Create the action
    float velocity = 450.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];

}


- (void)addMonster {

    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;  // Sets the sprite to be dynamic. This means that the physics engine will not control the movement of the monster – you will through the code you’ve already written (using move actions).
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory; // Indicates what categories of objects this object should notify the contact listener when they intersect. You choose projectiles here.
    monster.physicsBody.collisionBitMask = 0; // Indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). You don’t want the monster and projectile to bounce off each other – it’s OK for them to go right through each other in this game – so you set this to 0.
    
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height/2;
    int maxY = self.frame.size.height - monster.size.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine the speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random()%rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    // Remove the node from the scence when no longer to be displayed. IMPORTANT!!!
    //[monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        SKScene * gameOverScene = [[SKDemoGameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    // As soon as you remove a sprite from its parent, it is no longer in the scene hierarchy so no more actions will take place from that point on. So you don’t want to remove the sprite from the scene until you’ve transitioned to the lose scene. Actually you don’t even need to call to actionMoveDone anymore since you’re transitioning to a new scene, but I’ve left it here for educational purposes.
    [monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval) timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}


- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"HIT");
    [projectile removeFromParent];
    [monster removeFromParent];
    
    self.monstersDestroyed++;
    if (self.monstersDestroyed > 15) {
        SKTransition * reveal = [SKTransition flipVerticalWithDuration:0.5];
        SKScene * gameOverScene = [[SKDemoGameOverScene alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition:reveal];
    }
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody, *secondBody;
    // This method passes you the two bodies that collide, but does not guarantee that they are passed in any particular order. So this bit of code just arranges them so they are sorted by their category bit masks so you can make some assumptions later. This bit of code came from Apple’s Adventure sample.
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // Finally, it checks to see if the two bodies that collide are the projectile and monster, and if so calls the method you wrote earlier.
    if ((firstBody.categoryBitMask & projectileCategory) != 0 && (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
    

}
- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // Handle time delta
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {    // more than 1 second since last update
        timeSinceLast = 1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    [self updateWithTimeSinceLastUpdate:timeSinceLast];

}

@end
