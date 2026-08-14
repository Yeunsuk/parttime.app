import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_version.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadLastCredentials();
  }

  // 로그아웃해도 마지막으로 로그인했던 아이디/비밀번호는 그대로 남겨둔다.
  Future<void> _loadLastCredentials() async {
    final storage = ref.read(secureStorageProvider);
    final email = await storage.getLastEmail();
    final password = await storage.getLastPassword();
    if (!mounted) return;
    setState(() {
      if (email != null) _emailCtrl.text = email;
      if (password != null) _pwCtrl.text = password;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).login(
      _emailCtrl.text.trim(),
      _pwCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 성공 시 라우터 redirect가 자동 처리
    ref.listen(authStateProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                const Text('안녕하세요 👋',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('로그인하여 시작하세요.',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 48),

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
                const SizedBox(height: 32),

                // 로그인 버튼
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('로그인', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // 회원가입 이동
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text(
                      '계정이 없으신가요? 회원가입',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('v$appVersion',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
