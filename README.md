# DampingField.playground

## Question

I'm creating a custom field to slow down the motion of objects after a user performs a pan gesture. Using normal friction makes the objects feel too slippery, so I'm trying to apply spring physics in place of friction.

I have a function that seems to correctly calculate the behavior I'm looking for.

```swift
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
```

However, vertical motion isn't behaving as I expected. Any motion towards the reference view's top causes the object to accelerate faster.

I've been playing with trigonometry for a while, but I'm stumped.

[Stack Overflow Question](https://stackoverflow.com/q/50439223/1202880)

## Answer

The answer literally came to me in a dream, lol.

The unexpected behavior was that the force in the negative-y direction was negative when it should have been positive&mdash;causing an increase in the resulting velocity's absolute value.

Sure enough, adding a check to make sure that the force's y-component always had the opposite sign of the given velocity's y-component solved the problem.

```swift
var vector = CGVector(dx: cos(angle) * force, dy: sin(angle) * force)
if vector.dy.sign == velocity.dy.sign {
    vector.dy *= -1
}
return vector
```

Trying to think through why only the y-component was being wrongly signed, I noticed that the angle was calculated with respect to the x-axis.

```swift
let angle = acos(velocity.dx / speed)
```

I figured I'd try calculating the y-coordinate's force in terms of the angle with respect to the y-axis, and this too fixed the problem.

```swift
return CGVector(dx: cos(angle) * force, dy: sin(asin(velocity.dy / speed)) * force)
```

Thinking about it for a bit, I realized that, since `asin` and `acos` are the inverse of `sin` and `cos` respectively, the code could be reduced to remove the use of `sin` and `cos` entirely.

```swift
return CGVector(dx: velocity.dx / speed * force, dy: velocity.dy / speed * force)
```

Really, though, I didn't need to bring trigonometry into this at all, since operations on vectors' components are equivalent to operations on the vector itself. Now my force works as expected and is simpler to reason about.

```swift
extension UIFieldBehavior {
    static func dampingField(_ constant: CGFloat) -> UIFieldBehavior {
        return UIFieldBehavior.field { field, position, velocity, mass, charge, time in
            return  CGVector(dx: -constant * velocity.dx, dy: -constant * velocity.dy)
        }
    }
}
```
