import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mouse Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Interval { I10, I50, I100, I200, I400, I800 }

Duration toDuration(Interval interval) {
  switch (interval) {
    case Interval.I10:
      return const Duration(milliseconds: 10);
    case Interval.I50:
      return const Duration(milliseconds: 50);
    case Interval.I100:
      return const Duration(milliseconds: 100);
    case Interval.I200:
      return const Duration(milliseconds: 200);
    case Interval.I400:
      return const Duration(milliseconds: 400);
    case Interval.I800:
      return const Duration(milliseconds: 800);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _hz = 0;
  Interval _interval = Interval.I50;
  late DateTime _last;
  late Timer timer;

  static Interval _loopInterval(Interval interval) {
    switch (interval) {
      case Interval.I10:
        return Interval.I50;
      case Interval.I50:
        return Interval.I100;
      case Interval.I100:
        return Interval.I200;
      case Interval.I200:
        return Interval.I400;
      case Interval.I400:
        return Interval.I800;
      case Interval.I800:
        return Interval.I10;
    }
  }

  void _updateLocation(PointerEvent details) {
    _counter++;
  }

  void _switchDuration() {
    _interval = _loopInterval(_interval);
    timer.cancel();
    timer = Timer.periodic(toDuration(_interval), _updateHz);
    _hz = 0;
    _counter = 0;
    _last = DateTime.now();
    setState(() {});
  }

  void _updateHz(Timer timer) {
    setState(() {
      final now = DateTime.now();
      final dur = now.millisecondsSinceEpoch - _last.millisecondsSinceEpoch;
      _hz = (_counter / dur * 1000).round();
      _counter = 0;
      _last = now;
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(toDuration(_interval), _updateHz);
    _last = DateTime.now();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: _switchDuration, icon: const Icon(Icons.tune)),
        title: Text(
            'Statistical Interval: ${toDuration(_interval).inMilliseconds} ms'),
      ),
      body: MouseRegion(
        onHover: _updateLocation,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_hz',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ' Hz',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
