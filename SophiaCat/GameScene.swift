//
//  GameScene.swift
//  CollectCows
//
//  Created by Gabriela Bezerra on 28/03/23.
//

import Foundation
import SpriteKit

class GameScene: SKScene {

    // MARK: - Nodes
    let myCamera: SKCameraNode = SKCameraNode()

    let background: SKSpriteNode = SKSpriteNode(imageNamed: "bg")
    let floor: SKSpriteNode = SKSpriteNode(imageNamed: "floor")
    let obstacle: SKSpriteNode = SKSpriteNode(imageNamed: "obstacle")
    let character: SKSpriteNode = {
        let atlas = SKTextureAtlas(named: "cat")
        return SKSpriteNode(texture: atlas.textureNamed("ns1"))
    }()

    let nyanCatEffect = SKEmitterNode(fileNamed: "nyan")!

    // MARK: - SKScene Lifecycle
    /// https://developer.apple.com/documentation/spritekit/skscene#2982703
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        nodesInitialSetup()
        repeatForeverActionsSetup()
        particleSetup()
        physicsSetup()
        cameraSetup()
    }

    // MARK: - Colocando nodes na scene
    /// https://developer.apple.com/documentation/spritekit/skscene/positioning_a_scene_s_origin_within_its_view
    /// https://developer.apple.com/documentation/spritekit/nodes_for_scene_building/using_base_nodes_to_lay_out_spritekit_content
    private func nodesInitialSetup() {
        self.addChild(background)
        self.addChild(floor)
        self.addChild(obstacle)
        self.addChild(character)

        // Background
        background.position = self.position
        background.zPosition = -2

        // Floor
        floor.position = CGPoint(
            x: self.frame.midX,
            y: self.frame.maxY
        )
        floor.zRotation = .pi

        // Spikes
        obstacle.position = CGPoint(
            x: floor.frame.maxX * 0.6,
            y: floor.frame.minY * 0.85
        )
        obstacle.zRotation = .pi
        obstacle.zPosition = -1

        // Character
        character.position = CGPoint(
            x: obstacle.frame.minX * 0.25,
            y: self.frame.midY
        )
        character.size.width *= 0.5
        character.size.height *= 0.5
    }

    // MARK: - Configurando SKActions para animações
    /// https://developer.apple.com/documentation/spritekit/getting_started_with_actions
    private func repeatForeverActionsSetup() {
        character.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: SKTextureAtlas(named: "cat").textureNames.map(SKTexture.init(imageNamed:)),
                    timePerFrame: 1/15,
                    resize: false,
                    restore: true
                )
            )
        )

        obstacle.run(
            SKAction.repeatForever(
                SKAction.group([
                    SKAction.sequence([
                        SKAction.resize(byWidth: 0, height: 30, duration: 1),
                        SKAction.resize(byWidth: 0, height: -30, duration: 1),
                    ]),
                    SKAction.sequence([
                        SKAction.move(by: .init(dx: -20, dy: 0), duration: 1),
                        SKAction.move(by: .init(dx: 20, dy: 0), duration: 1)
                    ])
                ])
            )
        )
    }

    // MARK: - Configurando efeito de partículas
    /// https://developer.apple.com/documentation/spritekit/skemitternode/creating_particle_effects
    private func particleSetup() {
        self.addChild(nyanCatEffect)
        nyanCatEffect.position = character.position
        nyanCatEffect.targetNode = self
    }

    // MARK: - Configurando corpos físicos, colisão e contato dos nodes
    /// https://developer.apple.com/documentation/spritekit/skphysicsbody/about_collisions_and_contacts
    private func physicsSetup() {
        // physics body
        character.physicsBody = SKPhysicsBody(texture: character.texture!, size: character.size)
        character.physicsBody?.affectedByGravity = false
        character.physicsBody?.allowsRotation = false

        floor.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: floor.size.width * 0.8,
                height: floor.size.height * 0.8
            )
        )
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.usesPreciseCollisionDetection = true

        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.size)
        obstacle.physicsBody?.isDynamic = false

        // categories
        floor.physicsBody?.categoryBitMask = 0b0001
        obstacle.physicsBody?.categoryBitMask = 0b0010

        // colision
        character.physicsBody?.collisionBitMask = 0b0001

        // contact
        character.name = "sophia-cat"
        obstacle.name = "spike"
        character.physicsBody?.contactTestBitMask = 0b0010
        self.physicsWorld.contactDelegate = self
    }

    // MARK: - Configurando SKCamera
    /// https://developer.apple.com/documentation/spritekit/skcameranode/getting_started_with_a_camera
    private func cameraSetup() {
        myCamera.setScale(1)
        myCamera.position = character.position
        self.camera = myCamera
    }

    // MARK: - Sobrescrição dos métodos do UIResponder
    /// https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        character.run(SKAction.move(to: location, duration: 1))
    }

    // MARK: - Sobrescrição dos métodos do Frame-Cycle Events
    ///https://developer.apple.com/documentation/spritekit/skscene/responding_to_frame-cycle_events
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        nyanCatEffect.position = character.position
        camera?.position = CGPoint(
            x: character.position.x + self.frame.width/5,
            y: character.position.y
        )
    }
}


// MARK: - Detectando contato entre dois nodes com delegate
/// https://developer.apple.com/documentation/spritekit/skphysicscontactdelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        print("A:", contact.bodyA.node?.name ?? "no node")
        print("B:", contact.bodyB.node?.name ?? "no node")
        if contact.bodyB == obstacle.physicsBody {
            print("Sophia Cat foi de arrasta pra cima")
            character.run(
                SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.fadeIn(withDuration: 0.5)
                ])
            )
        }
    }
}
