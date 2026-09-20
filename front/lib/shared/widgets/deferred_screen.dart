import 'package:flutter/material.dart';

// deferred import로 분리된 화면을 처음 필요한 순간에 받아서 보여준다. 이미 받아둔
// 라이브러리면 loadLibrary()가 바로 끝나므로 로딩 표시는 한두 프레임만 스친다.
class DeferredScreen extends StatefulWidget {
  final Future<void> Function() load;
  final WidgetBuilder builder;

  const DeferredScreen({super.key, required this.load, required this.builder});

  @override
  State<DeferredScreen> createState() => _DeferredScreenState();
}

class _DeferredScreenState extends State<DeferredScreen> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  void _retry() => setState(() => _future = widget.load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return widget.builder(context);
        }
        return Scaffold(
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('화면을 불러오지 못했습니다.'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _retry,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
