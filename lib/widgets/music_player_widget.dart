import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/love_models.dart';

class MusicPlayerWidget extends StatefulWidget {
  final List<Song> songs;
  final int currentSongIndex;
  final bool isPlaying;
  final bool isExpanded;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onShowPlaylist;

  const MusicPlayerWidget({
    super.key,
    required this.songs,
    required this.currentSongIndex,
    required this.isPlaying,
    required this.isExpanded,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrev,
    required this.onShowPlaylist,
  });

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    final currentSong = widget.currentSongIndex >= 0 && widget.currentSongIndex < widget.songs.length
        ? widget.songs[widget.currentSongIndex]
        : null;

    return GestureDetector(
      onTap: widget.isExpanded ? null : widget.onPlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.isExpanded ? 200 : 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppTheme.loveGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button - luôn luôn hoạt động
              GestureDetector(
                onTap: widget.onPlayPause,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isPlaying && widget.currentSongIndex >= 0
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.pinkAccent,
                    size: 20,
                  ),
                ),
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 2),
                // Nút Previous
                GestureDetector(
                  onTap: widget.onPrev,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Icon(Icons.skip_previous, color: Colors.white, size: 14),
                  ),
                ),
                const SizedBox(width: 2),
                // Tên bài hát
                SizedBox(
                  width: 56,
                  child: Text(
                    currentSong?.name ?? "Chưa chọn bài",
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 2),
                // Nút Next
                GestureDetector(
                  onTap: widget.onNext,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Icon(Icons.skip_next, color: Colors.white, size: 14),
                  ),
                ),
                const SizedBox(width: 2),
                // Nút Playlist
                GestureDetector(
                  onTap: widget.onShowPlaylist,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Icon(Icons.queue_music, color: Colors.white70, size: 13),
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================== PLAYLIST DIALOG ==================
class PlaylistDialog extends StatelessWidget {
  final List<Song> songs;
  final int currentSongIndex;
  final bool isPlaying;
  final ValueChanged<int> onPlaySong;

  const PlaylistDialog({
    super.key,
    required this.songs,
    required this.currentSongIndex,
    required this.isPlaying,
    required this.onPlaySong,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.music_note, color: Colors.pinkAccent),
          const SizedBox(width: 8),
          const Text("🎵 Thư viện nhạc"),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: songs.length,
          itemBuilder: (ctx, i) {
            final isCurrent = i == currentSongIndex;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.pink.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  isCurrent && isPlaying ? Icons.equalizer : Icons.music_note,
                  color: isCurrent ? Colors.pinkAccent : Colors.grey,
                ),
                title: Text(
                  songs[i].name,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.pinkAccent : Colors.black87,
                  ),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.play_circle_fill, color: Colors.pinkAccent)
                    : null,
                onTap: () {
                  onPlaySong(i);
                  Navigator.pop(ctx);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Đóng"),
        ),
      ],
    );
  }
}