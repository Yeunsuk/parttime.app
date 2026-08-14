import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'workplace_provider.dart';

// 근무지 생성 폼 (사장)
class CreateWorkplaceForm extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  const CreateWorkplaceForm({super.key, this.onSuccess});

  @override
  ConsumerState<CreateWorkplaceForm> createState() => _CreateWorkplaceFormState();
}

class _CreateWorkplaceFormState extends ConsumerState<CreateWorkplaceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(myWorkplacesProvider.notifier).create(
          _nameCtrl.text.trim(),
          int.parse(_wageCtrl.text),
        );
    if (mounted && !ref.read(myWorkplacesProvider).hasError) {
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(myWorkplacesProvider).isLoading;

    ref.listen(myWorkplacesProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('근무지 생성',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '근무지 이름'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '근무지 이름을 입력하세요' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _wageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '시급'),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return (n == null || n < 0) ? '올바른 시급을 입력하세요' : null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('생성하기'),
          ),
        ],
      ),
    );
  }
}

// 초대코드로 근무지 참가 폼 (알바생)
class JoinWorkplaceForm extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  const JoinWorkplaceForm({super.key, this.onSuccess});

  @override
  ConsumerState<JoinWorkplaceForm> createState() => _JoinWorkplaceFormState();
}

class _JoinWorkplaceFormState extends ConsumerState<JoinWorkplaceForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(myWorkplacesProvider.notifier).join(_codeCtrl.text.trim());
    if (mounted && !ref.read(myWorkplacesProvider).hasError) {
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(myWorkplacesProvider).isLoading;

    ref.listen(myWorkplacesProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('초대코드로 참가',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: '초대코드'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '초대코드를 입력하세요' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('참가하기'),
          ),
        ],
      ),
    );
  }
}
