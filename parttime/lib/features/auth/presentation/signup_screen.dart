import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ownerCodeCtrl = TextEditingController();
  String _selectedRole = 'WORKER';
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    _ownerCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).signup(
      _emailCtrl.text.trim(),
      _pwCtrl.text,
      _nameCtrl.text.trim(),
      _selectedRole,
      _selectedRole == 'OWNER' ? _ownerCodeCtrl.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (v) =>
                    (v == null || v.isEmpty) ? '이름을 입력하세요' : null,
                ),
                const SizedBox(height: 16),

                // 아이디
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                    (v == null || v.isEmpty) ? '아이디를 입력하세요' : null,
                ),
                const SizedBox(height: 16),

                // 비밀번호
                TextFormField(
                  controller: _pwCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                    (v == null || v.length < 6) ? '6자 이상 입력하세요' : null,
                ),
                const SizedBox(height: 24),

                // 역할 선택
                const Text('역할 선택',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _RoleTile(
                      label: '알바생',
                      icon: Icons.badge_outlined,
                      color: AppColors.workerBadge,
                      selected: _selectedRole == 'WORKER',
                      onTap: () => setState(() => _selectedRole = 'WORKER'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _RoleTile(
                      label: '사장님',
                      icon: Icons.store_outlined,
                      color: AppColors.ownerBadge,
                      selected: _selectedRole == 'OWNER',
                      onTap: () => setState(() => _selectedRole = 'OWNER'),
                    )),
                  ],
                ),

                if (_selectedRole == 'OWNER') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ownerCodeCtrl,
                    decoration: const InputDecoration(
                      labelText: '사장 인증코드',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    validator: (v) => (_selectedRole == 'OWNER' &&
                            (v == null || v.isEmpty))
                        ? '사장 인증코드를 입력하세요'
                        : null,
                  ),
                ],
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  child: isLoading
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('가입하기', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
