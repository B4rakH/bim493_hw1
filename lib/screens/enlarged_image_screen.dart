import 'package:flutter/material.dart';

/// Full-screen enlarged image viewer with standard Back navigation.
/// Opened via double-tap gesture on the event details image.
class EnlargedImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const EnlargedImageViewerScreen({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.white54,
              );
            },
          ),
        ),
      ),
    );
  }
}
