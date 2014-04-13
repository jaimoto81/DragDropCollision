//
//  MyScene.m
//  DragDrop
//
//  Created by Jaimoto Flauterö Valencia on 12/04/14.
//  Copyright (c) 2014 BQuest. All rights reserved.
//

#import "MyScene.h"

@interface MyScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;

@end
@implementation MyScene

static NSString * const kAnimalNodeName = @"movable";
static const uint32_t dogCategory =  0x1 << 0;
static const uint32_t catCategory =  0x1 << 1;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 1) Loading the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"blue-shooting-stars"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        // 2) Loading the images
        NSArray *imageNames = @[@"bird", @"cat", @"dog", @"turtle"];
        for(int i = 0; i < [imageNames count]; ++i) {
            NSString *imageName = [imageNames objectAtIndex:i];
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            [sprite setName:kAnimalNodeName];
            
            float offsetFraction = ((float)(i + 1)) / ([imageNames count] + 1);
            [sprite setPosition:CGPointMake(size.width * offsetFraction, size.height / 3)];
            
            if ( [imageName isEqualToString:@"dog"]) {
                sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size]; // 1
                sprite.physicsBody.dynamic = YES; // 2
                sprite.physicsBody.categoryBitMask = dogCategory; // 3
                sprite.physicsBody.contactTestBitMask = catCategory; // 4
                sprite.physicsBody.collisionBitMask = 0; // 5
                NSLog(@"Física al Perro");
            } else if ([imageName isEqualToString:@"cat"]) {
                sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
                sprite.physicsBody.dynamic = YES;
                sprite.physicsBody.categoryBitMask = catCategory;
                sprite.physicsBody.contactTestBitMask = dogCategory;
                sprite.physicsBody.collisionBitMask = 0;
                sprite.physicsBody.usesPreciseCollisionDetection = YES;
            }
            
            [_background addChild:sprite];
            
            
            
            
        }
        
        // 3) Add Physics
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self selectNodeForTouch:positionInScene];
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    //1
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
    //2
	if(![_selectedNode isEqual:touchedNode]) {
		[_selectedNode removeAllActions];
		[_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        
		_selectedNode = touchedNode;
		//3
		if([[touchedNode name] isEqualToString:kAnimalNodeName]) {
			SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],
													  [SKAction rotateByAngle:0.0 duration:0.1],
													  [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];
			[_selectedNode runAction:[SKAction repeatActionForever:sequence]];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint positionInScene = [touch locationInNode:self];
	CGPoint previousPosition = [touch previousLocationInNode:self];
    
	CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
    
	[self panForTranslation:translation];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = self.size;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -[_background size].width+ winSize.width);
    retval.y = [self position].y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_selectedNode position];
    if([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    } else {
        CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
        [_background setPosition:[self boundLayerPos:newPos]];
    }
}

- (void)selectedNode:(SKSpriteNode *)projectile didCollide:(SKSpriteNode *)selectedNode {
    NSLog(@"Hit");
   // [projectile removeFromParent];
   // [monster removeFromParent];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
   // NSLog(@"Contacto");
    
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
        NSLog(@"Guau");
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
        NSLog(@"Miau");
    }
    
    // 2
    if ((firstBody.categoryBitMask & catCategory) != 0 &&
        (secondBody.categoryBitMask & dogCategory) != 0)
    {
        [self selectedNode:(SKSpriteNode *) firstBody.node didCollide:(SKSpriteNode *) secondBody.node];
    }
}

@end
