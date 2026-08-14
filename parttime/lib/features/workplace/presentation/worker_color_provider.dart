import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/secure_storage.dart';

part 'worker_color_provider.g.dart';

// 근로자 달력 마커용 고정 팔레트. 사장이 따로 지정하지 않은 근로자는 이 안에서
// workerId 기반으로 결정되는 색을 기본값으로 쓴다("최초엔 랜덤으로 초기화").
const List<Color> kWorkerColorPalette = [
  Color(0xFFE53935), // red
  Color(0xFF1E88E5), // blue
  Color(0xFF43A047), // green
  Color(0xFFFB8C00), // orange
  Color(0xFF8E24AA), // purple
  Color(0xFF00897B), // teal
  Color(0xFFD81B60), // pink
  Color(0xFF6D4C41), // brown
  Color(0xFF3949AB), // indigo
  Color(0xFFC0CA33), // lime
];

int defaultWorkerColorIndex(int workerId) =>
    workerId.hashCode.abs() % kWorkerColorPalette.length;

Color colorForWorker(int workerId, Map<int, int> overrides) {
  final index = overrides[workerId] ?? defaultWorkerColorIndex(workerId);
  return kWorkerColorPalette[index];
}

// 근무지별 근로자 색상 커스텀 지정 (기기 로컬 저장, 없는 근로자는 기본 팔레트색을 씀)
@riverpod
class WorkerColorOverrides extends _$WorkerColorOverrides {
  @override
  Future<Map<int, int>> build(int workplaceId) async {
    return ref.read(secureStorageProvider).getWorkerColorOverrides(workplaceId);
  }

  Future<void> setColorIndex(int workplaceId, int workerId, int colorIndex) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveWorkerColorOverride(workplaceId, workerId, colorIndex);
    state = AsyncData({...(state.value ?? {}), workerId: colorIndex});
  }
}
