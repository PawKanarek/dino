import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Ball extends BodyComponent with TapCallbacks {
  Vector2? initialPosition;
  Ball(this.initialPosition);

  @override
  Body createBody() {
    var fixture = FixtureDef(
      CircleShape()..radius = 5,
      restitution: 0.8,
      density: 1.0,
      friction: 0.4,
    );

    var bodyDef = BodyDef(
      angularDamping: 0.8,
      position: initialPosition ?? Vector2.zero(),
      type: BodyType.dynamic,
    );

    return game.world.createBody(bodyDef)..createFixture(fixture);
  }

  @override
  void onTapDown(event) {
    body.applyLinearImpulse(Vector2.random() * 5000);
  }
}
