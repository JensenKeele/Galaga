import SpriteKit
import GameplayKit

/// GameScene is the SKScene subclass associated with GameScene.sks.
/// It equalizes the horizontal spacing of enemy nodes within each row
/// when the scene loads, so enemies are evenly distributed.
class GameScene: SKScene {
    /// Names we consider as enemies. We match if a node's name contains any of these.
    private let enemyNameHints: [String] = ["enemy", "alien", "invader"]

    /// Margin from scene edges when redistributing enemies.
    private let horizontalMargin: CGFloat = 24

    /// Tolerance for grouping nodes into the same row based on Y position.
    private let rowYTolerance: CGFloat = 6

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Attempt to equalize spacing once the scene is presented.
        equalizeEnemySpacing(animated: true)
    }

    /// Finds enemy nodes and redistributes them so that spacing is equal within each row.
    /// - Parameter animated: Whether to animate the repositioning.
    func equalizeEnemySpacing(animated: Bool) {
        // Prefer a dedicated container if present; otherwise operate on the whole scene.
        let enemyContainer = childNode(withName: "enemies") ?? childNode(withName: "Enemies") ?? self

        // Collect candidate enemy nodes by common naming patterns.
        var candidates: [SKSpriteNode] = []
        func collectEnemies(in node: SKNode) {
            for child in node.children {
                if let sprite = child as? SKSpriteNode {
                    if let name = sprite.name?.lowercased(), enemyNameHints.contains(where: { name.contains($0) }) {
                        candidates.append(sprite)
                    }
                }
                // Recurse to catch deeply nested enemy nodes (e.g., from .sks hierarchies).
                collectEnemies(in: child)
            }
        }
        collectEnemies(in: enemyContainer)

        // If we didn't find any by name hints, fall back to a heuristic: all visible sprite children of the container.
        if candidates.isEmpty {
            candidates = enemyContainer.children.compactMap { $0 as? SKSpriteNode }.filter { !$0.isHidden && $0.alpha > 0.01 }
        }

        guard !candidates.isEmpty else { return }

        // Group enemies by row using their current Y positions.
        let rows = groupIntoRows(nodes: candidates, yTolerance: rowYTolerance)

        // Compute the bounds to lay out within.
        let layoutLeft = frame.minX + horizontalMargin
        let layoutRight = frame.maxX - horizontalMargin
        let availableWidth = max(0, layoutRight - layoutLeft)

        // Redistribute each row horizontally with equal spacing.
        for row in rows {
            let nodesInRow = row.sorted(by: { $0.position.x < $1.position.x })
            let y = averageY(of: nodesInRow)
            let count = nodesInRow.count

            if count == 1 {
                let targetX = frame.midX
                move(node: nodesInRow[0], to: CGPoint(x: targetX, y: y), animated: animated)
                continue
            }

            // Place nodes evenly across available width.
            let step = availableWidth / CGFloat(count - 1)
            for (i, node) in nodesInRow.enumerated() {
                let x = layoutLeft + CGFloat(i) * step
                move(node: node, to: CGPoint(x: x, y: y), animated: animated)
            }
        }
    }

    // MARK: - Helpers

    /// Groups nodes into rows by clustering on Y position with a tolerance.
    private func groupIntoRows(nodes: [SKSpriteNode], yTolerance: CGFloat) -> [[SKSpriteNode]] {
        let sorted = nodes.sorted { $0.position.y > $1.position.y } // top to bottom
        var rows: [[SKSpriteNode]] = []

        for node in sorted {
            if let lastRow = rows.last, let refY = lastRow.first?.position.y, abs(node.position.y - refY) <= yTolerance {
                rows[rows.count - 1].append(node)
            } else {
                rows.append([node])
            }
        }
        return rows
    }

    /// Average Y position of nodes in a row to keep the row straight.
    private func averageY(of nodes: [SKSpriteNode]) -> CGFloat {
        guard !nodes.isEmpty else { return 0 }
        let total = nodes.reduce(0) { $0 + $1.position.y }
        return total / CGFloat(nodes.count)
    }

    /// Moves a node to a target point, optionally animated.
    private func move(node: SKSpriteNode, to point: CGPoint, animated: Bool) {
        if animated {
            let action = SKAction.move(to: point, duration: 0.15)
            action.timingMode = .easeInEaseOut
            node.run(action)
        } else {
            node.position = point
        }
    }
}
