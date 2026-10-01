import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/level.dart';
import '../../providers/downloads_provider.dart';
import '../../providers/level_list_provider.dart';

class DownloadsView extends StatefulWidget {
  const DownloadsView({super.key});

  @override
  State<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadsProvider>().load();
    });
  }

  Future<void> _download(Level level) async {
    try {
      await context.read<DownloadsProvider>().downloadLevel(level);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download ${level.name}. Check your connection and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = context.watch<LevelListProvider>().levelViewModels.map((vm) => vm.level).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final downloads = context.watch<DownloadsProvider>();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Download a level to access its lessons without an internet connection.'),
        ),
        for (final level in levels)
          Card(
            child: ListTile(
              leading: Icon(
                downloads.downloadedLevelIds.contains(level.id)
                    ? Icons.offline_pin_outlined
                    : Icons.download_outlined,
              ),
              title: Text(level.name),
              subtitle: Text(
                downloads.downloadedLevelIds.contains(level.id) ? 'Available offline' : 'Not downloaded',
              ),
              trailing: downloads.isDownloading(level.id)
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : downloads.downloadedLevelIds.contains(level.id)
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Remove download',
                          onPressed: () => context.read<DownloadsProvider>().removeDownload(level.id),
                        )
                      : IconButton(
                          icon: const Icon(Icons.download_outlined),
                          tooltip: 'Download for offline use',
                          onPressed: () => _download(level),
                        ),
            ),
          ),
      ],
    );
  }
}
