import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Plays a vocabulary item's pronunciation clip. No real audio assets exist
/// yet (see SRS 6.1) — this degrades gracefully to a disabled button rather
/// than crashing when [audioRef] is null.
class AudioPlayButton extends StatefulWidget {
  const AudioPlayButton({super.key, required this.audioRef});

  final String? audioRef;

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  final _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final ref = widget.audioRef;
    if (ref == null) return;
    setState(() => _isPlaying = true);
    try {
      await _player.play(AssetSource(ref));
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.audioRef != null && !_isPlaying;
    return IconButton(
      icon: Icon(_isPlaying ? Icons.volume_up : Icons.volume_up_outlined),
      tooltip: widget.audioRef == null ? 'Audio not available yet' : 'Play pronunciation',
      onPressed: enabled ? _play : null,
    );
  }
}
