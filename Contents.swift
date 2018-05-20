import UIKit
import PlaygroundSupport

extension UIFieldBehavior {
    static func dampingField(_ constant: CGFloat) -> UIFieldBehavior {
        return UIFieldBehavior.field { field, position, velocity, mass, charge, time in
            let speed = sqrt(pow(velocity.dx, 2) + pow(velocity.dy, 2))
            let angle = acos(velocity.dx / speed)
            let force = -constant * speed
            guard angle.isNaN == false, force.isNaN == false else { return .zero }
            return  CGVector(dx: cos(angle) * force, dy: sin(angle) * force)
        }
    }
}

class MyViewController : UIViewController {
    var animator: UIDynamicAnimator!
    let behavior = UIDynamicBehavior()
    let collision = UICollisionBehavior()
    let damping = UIFieldBehavior.dampingField(2)
    let inertia = UIDynamicItemBehavior()
    let recognizer = UIPanGestureRecognizer()
    var anchor: UIAttachmentBehavior!
    let label = UILabel()

    var block: UIView!

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        block = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        block.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        view.addSubview(block)

        recognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))
        block.addGestureRecognizer(recognizer)

        self.view = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        block.center = view.center

        animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(behavior)

        collision.translatesReferenceBoundsIntoBoundary = true
        behavior.addChildBehavior(collision)
        behavior.addChildBehavior(damping)
        behavior.addChildBehavior(inertia)

        collision.addItem(block)
        damping.addItem(block)
        inertia.addItem(block)

        inertia.addLinearVelocity(CGPoint(x: 0, y: -10), for: block)
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            damping.removeItem(block)
            inertia.removeItem(block)
            anchor = UIAttachmentBehavior(item: block, attachedToAnchor: recognizer.location(in: view))
            animator.addBehavior(anchor)
        case .changed:
            anchor.anchorPoint = recognizer.location(in: view)
            anchor.damping = 0.5
        case .ended:
            animator.removeBehavior(anchor)
            damping.addItem(block)
            inertia.addItem(block)
            inertia.addLinearVelocity(recognizer.velocity(in: view), for: block)
        case .cancelled:
            animator.removeBehavior(anchor)
            damping.addItem(block)
            inertia.addItem(block)
        default: break
        }
    }
}

PlaygroundPage.current.liveView = MyViewController()
