import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/workplace_model.dart';
import 'workplace_forms.dart';
import 'workplace_provider.dart';

// 화면이 동작하려면 반드시 "현재 근무지" 하나가 정해져야 할 때 쓰는 게이트.
// 근무지가 없으면 역할별 생성/참가 폼을, 여러 개면 선택 UI를 보여주고,
// 근무지가 하나로 확정되면(1개뿐이거나 사용자가 선택하면) [builder]를 렌더링한다.
class WorkplaceGate extends ConsumerWidget {
  final Widget Function(BuildContext context, WorkplaceModel workplace) builder;

  const WorkplaceGate({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplacesAsync = ref.watch(myWorkplacesProvider);

    return workplacesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
      data: (workplaces) {
        if (workplaces.isEmpty) {
          return const _WorkplaceOnboarding();
        }
        final selectedId = ref.watch(selectedWorkplaceIdProvider);
        final workplace = resolveWorkplace(workplaces, selectedId);
        if (workplace == null) {
          return _WorkplacePicker(workplaces: workplaces);
        }
        return builder(context, workplace);
      },
    );
  }
}

class _WorkplaceOnboarding extends ConsumerWidget {
  const _WorkplaceOnboarding();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authStateProvider).value?.role;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              role == 'OWNER' ? '아직 만든 근무지가 없어요.' : '아직 참가한 근무지가 없어요.',
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            role == 'OWNER'
                ? const CreateWorkplaceForm()
                : const JoinWorkplaceForm(),
          ],
        ),
      ),
    );
  }
}

class _WorkplacePicker extends ConsumerWidget {
  final List<WorkplaceModel> workplaces;
  const _WorkplacePicker({required this.workplaces});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('근무지를 선택하세요',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: workplaces.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final w = workplaces[i];
              return GestureDetector(
                onTap: () =>
                    ref.read(selectedWorkplaceIdProvider.notifier).select(w.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('시급 ${w.hourlyWage}원 · ${w.ownerName}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
