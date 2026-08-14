import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/payroll_model.dart';
import 'payroll_provider.dart';
import 'png_download.dart';

// 횟수제 표기용: 정수면 "3회", 0.5 단위 소수면 "1.5회"처럼 보여준다.
String _formatCount(double count) {
  return count == count.roundToDouble()
      ? '${count.toInt()}회'
      : '$count회';
}

// 근무지 소속 직원별 정산 화면. 각 직원이 설정한 정산기간(기본은 달력월) 기준으로
// 상단에서 선택한 달이 속한 기간의 근무 횟수/근무시간/급여를 보여준다.
class SettlementScreen extends ConsumerStatefulWidget {
  final int workplaceId;
  final String workplaceName;

  const SettlementScreen({
    super.key,
    required this.workplaceId,
    required this.workplaceName,
  });

  @override
  ConsumerState<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends ConsumerState<SettlementScreen> {
  late DateTime _focusedMonth;
  // 캡처 대상: 화면에 스크롤되는 부분과 무관하게 전체 내역이 이 안에 다 그려지므로
  // (ListView가 아니라 Column을 쓰는 이유), toImage()로 찍으면 화면에 안 보이는
  // 아래쪽 내역까지 전부 포함된다.
  final GlobalKey _captureKey = GlobalKey();
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  Future<void> _captureAndDownload() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final filename =
          '정산_${widget.workplaceName}_${DateFormat('yyyyMM').format(_focusedMonth)}.png';
      final ok = downloadPng(bytes, filename);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '캡처 이미지를 다운로드했습니다.' : '이 기능은 웹에서만 지원됩니다.'),
          backgroundColor: ok ? null : AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('캡처 실패: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final param = (
      workplaceId: widget.workplaceId,
      year: _focusedMonth.year,
      month: _focusedMonth.month,
    );
    final settlementAsync = ref.watch(settlementProvider(param));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workplaceName} 정산'),
        actions: [
          IconButton(
            icon: _capturing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt_outlined),
            tooltip: '캡처',
            onPressed: (settlementAsync.value?.isNotEmpty ?? false)
                ? _captureAndDownload
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('yyyy년 M월').format(_focusedMonth),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: settlementAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const Center(child: Text('소속된 직원이 없습니다.'));
                }
                return SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.bg,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.workplaceName} 정산 · ${DateFormat('yyyy년 M월').format(_focusedMonth)}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          for (int i = 0; i < rows.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _SettlementRowCard(row: rows[i]),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementRowCard extends StatelessWidget {
  final SettlementModel row;
  const _SettlementRowCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final r = row;
    final isCount = r.paymentType == 'COUNT';
    final h = r.totalMinutes ~/ 60;
    final m = r.totalMinutes % 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.workerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                isCount
                    ? _formatCount(r.recordCount)
                    : '${NumberFormat('#,###').format(r.totalWage)}원',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${r.periodStart} ~ ${r.periodEnd}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            isCount
                ? '근무 ${_formatCount(r.recordCount)}'
                : '근무 ${_formatCount(r.recordCount)} · ${h}h ${m}m',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
