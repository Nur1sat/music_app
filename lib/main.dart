import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPlaying = false;
  double value = 0;
  final player = AudioPlayer();
  Duration duration = Duration.zero;

  void initPlayer() async {
    await player.setSource(AssetSource("music.mp3"));

    player.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
      });
    });

    // Listen for position updates
    player.onPositionChanged.listen((Duration position) {
      setState(() {
        value = position.inSeconds.toDouble();
      });
    });

    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        value = 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    double maxSliderValue =
        duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/cover.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset("assets/cover.jpg", width: 250.0),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Summer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatDuration(Duration(seconds: value.toInt())),
                      style: const TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      width: 260.0,
                      child: Slider.adaptive(
                        value: value.clamp(0.0, maxSliderValue),
                        min: 0.0,
                        max: maxSliderValue,
                        onChanged: (newValue) {
                          setState(() {
                            value = newValue;
                          });
                        },
                        onChangeEnd: (newValue) async {
                          await player.seek(
                            Duration(seconds: newValue.toInt()),
                          );
                        },
                        activeColor: Colors.white,
                      ),
                    ),
                    Text(
                      formatDuration(duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 60.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _controlButton(
                      icon: Icons.fast_rewind_rounded,
                      onPressed: () async {
                        int newPosition =
                            (value - 10)
                                .clamp(
                                  0,
                                  duration.inSeconds > 0
                                      ? duration.inSeconds
                                      : 1,
                                )
                                .toInt();
                        await player.seek(Duration(seconds: newPosition));
                      },
                    ),
                    _controlButton(
                      icon: isPlaying ? Icons.pause : Icons.play_arrow,
                      isHighlighted: true,
                      onPressed: () async {
                        if (isPlaying) {
                          await player.pause();
                        } else {
                          try {
                            await player.resume();
                          } catch (e) {
                            await player.play(AssetSource("music.mp3"));
                          }
                        }
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      },
                    ),
                    _controlButton(
                      icon: Icons.fast_forward_rounded,
                      onPressed: () async {
                        int newPosition =
                            (value + 10)
                                .clamp(
                                  0,
                                  duration.inSeconds > 0
                                      ? duration.inSeconds
                                      : 1,
                                )
                                .toInt();
                        await player.seek(Duration(seconds: newPosition));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    bool isHighlighted = false,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60.0),
        color: Colors.black87,
        border: Border.all(color: isHighlighted ? Colors.pink : Colors.white38),
      ),
      width: isHighlighted ? 60.0 : 50.0,
      height: isHighlighted ? 60.0 : 50.0,
      child: InkWell(
        onTap: onPressed,
        child: Center(child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}
