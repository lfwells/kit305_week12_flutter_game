import 'dart:core';

import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';


import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

void main() {
  runApp(GameWidget(
      game:DesertGolfing(),
      overlayBuilderMap: {
        'menu': (BuildContext context, DesertGolfing gameRef) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    gameRef.overlays.remove('menu');
                  },
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameRef.makeBallBig();
                  },
                  child: const Text('Make Ball Big'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameRef.overlays.remove('menu');
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
        },
      },
      initialActiveOverlays: [
        'menu',
      ],
  ));
}


class DesertGolfing extends Forge2DGame with TapDetector, PanDetector, HasCollisionDetection {
  static const String description = '''
    In this example we show how to add a sprite on top of a `BodyComponent`.
    Tap the screen to add more pizzas.
  ''';

  DesertGolfing() : super(gravity: Vector2(0, 10.0));

  late final Ball ball;
  double shootSpeed = 0;
  double maxShootSpeed = 50;
  double shootSpeedDelta = 50;
  bool isChargingShot = false;

  final startingPosition = Vector2(5, 60);

  void makeBallBig()
  {
    //scale the ball by 2
    (ball.body.fixtures.first.shape as CircleShape).radius * 2;
    ball.spriteComponent.size *= 2;
  }

  @override
  Future<void> onLoad() async {
    //addAll(createBoundaries(this));
    add(Ground());
    add(Hole(position: Vector2(30, 60), size: Vector2.all(3)));



    ball = Ball(startingPosition, radius: 2);
    add(ball);

  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    isChargingShot = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isChargingShot)
    {
      shootSpeed += shootSpeedDelta * dt;
      shootSpeed = min(shootSpeed, maxShootSpeed);
    }
  }


  @override
  void onTapUp(TapUpInfo info) {

    var speed = shootSpeed;
    final position = info.eventPosition.game;
    ball.body.linearVelocity = (position - ball.body.position).normalized() * speed;

    isChargingShot = false;
    shootSpeed = 0;
  }
}

class Ball extends BodyComponent<DesertGolfing> with ContactCallbacks {
  final Vector2 position;
  final double radius;

  Ball(this.position, {required this.radius});

  late final SpriteComponent spriteComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await gameRef.loadSprite('lindsayball2.png');
    renderBody = false;

    //add a shape component to this
    spriteComponent = SpriteComponent(
        sprite: sprite,
        position: Vector2(-radius, -radius),
        size: Vector2(radius * 2, radius * 2),
        angle: 0
    );
    add(spriteComponent);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      userData: this, // To be able to determine object in collision
      restitution: 0.4,
      density: 1.0,
      friction: 0.5,
    );

    final bodyDef = BodyDef(
      position: position,
      angle: 0,
      type: BodyType.dynamic,
      //linearVelocity: Vector2(0, -20),
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);

    print('endContact $other');
    if (other is Hole)
    {
      print("hit hole");
      //restart the game
      Future.delayed(Duration(milliseconds: 1000), () {
        body.setTransform(gameRef.startingPosition, 0);
        body.linearVelocity = Vector2.zero();
        body.angularVelocity = 0;

        gameRef.overlays.add('menu');
      });
    }
  }
}

class Ground extends BodyComponent {
  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(100, 10);

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.0,
      density: 1.0,
      friction: 0.5,
    );

    final bodyDef = BodyDef(
      position: Vector2(0, 75),
      angle: 0,
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //final sprite = await gameRef.loadSprite('pizza.png');
    renderBody = false;

    //add a shape component to this
    var rect = RectangleComponent(
        size:Vector2(200.0, 20),
        position:Vector2(-100,-10),
        paint:Paint()
          ..color = Colors.green
    );
    //add a texture to the rect
    add(rect);
  }
}


class Hole extends BodyComponent with ContactCallbacks {

  Vector2 position;
  Vector2 size;
  Hole({required this.position, required this.size});

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(size.x, size.y);

    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      restitution: 0.0,
      density: 1.0,
      friction: 0.5,
    );

    final bodyDef = BodyDef(
      position: position,
      angle: 0,
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await gameRef.loadSprite('background.png');
    renderBody = false;


    //add a shape component to this
    var rect = SpriteComponent(
      size:size * 2.0,
      position:Vector2(-size.x,-size.y),
      sprite:sprite
    );
    //add a texture to the rect
    add(rect);

  }
}