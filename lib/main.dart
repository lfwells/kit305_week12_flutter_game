import 'package:flame/game.dart';
import 'package:flutter/material.dart';


import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

void main() {
  runApp(GameWidget(game:SpriteBodyExample()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Text("todo")//")const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


class SpriteBodyExample extends Forge2DGame with TapDetector {
  static const String description = '''
    In this example we show how to add a sprite on top of a `BodyComponent`.
    Tap the screen to add more pizzas.
  ''';

  SpriteBodyExample() : super(gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    //addAll(createBoundaries(this));
    add(Ground());

  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final position = info.eventPosition.game;
    add(Pizza(position, radius: 5));
    print("add?");
  }
}

class Pizza extends BodyComponent {
  final Vector2 position;
  final double radius;
  Pizza(
      this.position, {required this.radius});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //final sprite = await gameRef.loadSprite('pizza.png');
    renderBody = false;

    //add a shape component to this
    add(CircleComponent(radius:radius, position:Vector2(-radius, -radius), paint:Paint()..color = Colors.red));
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
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
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
    add(RectangleComponent(size:Vector2(200.0, 20), position:Vector2(-100,-10), paint:Paint()..color = Colors.green));
  }
}