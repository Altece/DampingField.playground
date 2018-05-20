# DampingField.playground

I'm creating a custom field to slow down the motion of objects after a user performs a pan gesture. Using normal friction makes the objects feel too slippery, so I'm trying to apply spring physics in place of friction.

I have a function that seems to correctly calculate the behavior I'm looking for.

    extension UIFieldBehavior {
        static func dampingField(_ constant: CGFloat) -> UIFieldBehavior {
            return UIFieldBehavior.field { field, position, velocity, mass, charge, time in
                let speed = sqrt(pow(velocity.dx, 2) + pow(velocity.dy, 2))
                let angle = acos(velocity.dx / speed)
                let force = -constant * speed
                guard angle.isNaN == false, force.isNaN == false
                    else { return .zero }
                return  CGVector(dx: cos(angle) * force, dy: sin(angle) * force)
            }
        }
    }

However, vertical motion isn't behaving as I expected. Any motion towards the reference view's top causes the object to accelerate faster.

I've been playing with trigonometry for a while, but I'm stumped. There's an example swift playground on GitHub demonstrating this problem.

What am I overlooking in my math?
