import 'dart:async';

import 'package:flutter/material.dart';

// deferred import로 분리된 화면을 처음 필요한 순간에 받아서 보여준다. 이미 받아둔
// 라이브러리면 loadLibrary()가 바로 끝나므로 로딩 표시는 한두 프레임만 스친다.
// prefetch에 다음에 갈 만한 화면을 넘기면, 이 화면이 뜬 뒤 백그라운드에서 미리 받아둔다
// (실패해도 무시 — 실제로 그 화면에 들어갈 때 다시 시도한다).
class DeferredScreen extends StatefulWidget {
  final Future<void> Function() load;
  final WidgetBuilder builder;
  final List<Future<void> Function()> prefetch;

  const DeferredScreen({
    super.key,
    required this.load,
    required this.builder,
    this.prefetch = const [],
  });

  @override
  State<DeferredScreen> createState() => _DeferredScreenState();
}

class _DeferredScreenState extends State<DeferredScreen> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() async {
    await widget.load();
    for (final p in widget.prefetch) {
      unawaited(p().catchError((_) {}));
    }
  }

  void _retry() => setState(() => _future = _load());

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
