import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor_2/video_editor.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class EditVideoEditorPage extends StatefulWidget {
  const EditVideoEditorPage({super.key, required this.video});

  final XFile video;

  @override
  State<EditVideoEditorPage> createState() => _EditVideoEditorPageState();
}

class _EditVideoEditorPageState extends State<EditVideoEditorPage> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  int cropGridViewerKey = 0;

  late final _controller = VideoEditorController.file(
    widget.video,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 5),
    trimStyle: const TrimSliderStyle(
      positionLineWidth: 2,
      onTrimmedColor: Colors.blue,
      iconColor: Colors.blue,
      onTrimmingColor: Colors.blue,
    ),
    cropStyle: const CropGridStyle(gridSize: 1),
  );

  String _generateRandomFilename() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (index) => chars[Random().nextInt(chars.length)]).join() + '.gif';
  }
  
  Future<File> _exportGif() async {
    final start = _controller.startTrim;
    final end = _controller.endTrim;
    final inputPath = widget.video.path;
    final appDocDir = await getApplicationDocumentsDirectory();
    final outputPath = '${appDocDir.path}/${_generateRandomFilename()}';

    final _flutterFFmpeg = FlutterFFmpeg();
    final command =  '-i $inputPath -ss ${start.inSeconds} -t ${end.inSeconds - start.inSeconds} -vf "fps=30,scale=320:-1:flags=lanczos" -f gif $outputPath';
    await _flutterFFmpeg.execute(command);

    final previousFile = File(inputPath);
    if (await previousFile.exists()) {
      await previousFile.delete();
    }

    return File(outputPath);
  }

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (mounted) {
        Navigator.pop(context);
      }
    }, test: (e) => e is VideoMinDurationError);
    _controller.video.play();

  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _controller.initialized
            ? SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: CropGridViewer.preview(
                                key: ValueKey(cropGridViewerKey),
                                controller: _controller,
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.symmetric(vertical: height / 4),
                                    child: TrimSlider(
                                      maxViewportRatio: 8,
                                      controller: _controller,
                                      height: height,
                                      horizontalMargin: height / 4,
                                      child: TrimTimeline(
                                        controller: _controller,
                                        padding: const EdgeInsets.only(top: 10),
                                      ),
                                    ),
                                  ),
                                  _topNavBar()
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return Expanded(
      child: Row(
        children: [
          const Spacer(flex: 1),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
          const Spacer(flex: 7),
          InkWell(
            onTap: () async {
               Navigator.pop(context);
              final gifFile = await _exportGif();
              headPortraitChangeManagement.selectAndShootImage(gifFile);
             
            },
            child: const Text(
              '确定',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
