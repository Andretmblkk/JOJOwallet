import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import 'home_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isLoading = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      _showError('Mohon isi semua bidang.');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCredential.user != null) {
          AppState().userName.value = userCredential.user!.displayName ?? 'Pengguna';
          AppState().userEmail.value = userCredential.user!.email ?? '';
          _navigateToHome();
        }
      } else {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(name);
          AppState().userName.value = name;
          AppState().userEmail.value = email;
          _navigateToHome();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') message = 'Pengguna tidak ditemukan.';
      else if (e.code == 'wrong-password') message = 'Kata sandi salah.';
      else if (e.code == 'email-already-in-use') message = 'Email sudah digunakan.';
      _showError(message);
    } catch (e) {
      _showError('Terjadi kesalahan sistem.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        // Pada Android, terkadang butuh clientId eksplisit jika konfigurasi Firebase bermasalah.
        // Namun biasanya otomatis dari google-services.json.
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        AppState().userName.value = user.displayName ?? 'Pengguna';
        AppState().userEmail.value = user.email ?? '';
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      _showError('Gagal masuk dengan Google. Pastikan layanan Google Play tersedia dan konfigurasi benar.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      resizeToAvoidBottomInset: true, // Biarkan keyboard mendorong konten
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo & Judul (Style Gojek)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.account_balance_wallet,
                            size: 40,
                            color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'JOJOdompet',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Form Card (Style Gojek)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.bgWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.shadowSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLogin ? 'Masuk' : 'Daftar',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLogin
                          ? 'Masuk untuk mengelola keuangan.'
                          : 'Mulai hemat sekarang!',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    if (!isLogin) ...[
                      _buildTextField(
                        controller: _nameController,
                        icon: Icons.person_outline,
                        hint: 'Nama Lengkap',
                      ),
                      const SizedBox(height: 12),
                    ],

                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: 'Alamat Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hint: 'Kata Sandi',
                      isPassword: true,
                    ),

                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Lupa Kata Sandi?',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              )),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Tombol Utama Hijau
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(isLogin ? 'Lanjut' : 'Daftar Sekarang',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider minimalis
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.bgLight)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('atau',
                              style: TextStyle(
                                  color: AppTheme.textHint, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: AppTheme.bgLight)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSocialButton(
                        Icons.g_mobiledata, 'Masuk dengan Google',
                        onTap: _signInWithGoogle),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Toggle minimalis di bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLogin ? "Belum punya akun? " : 'Sudah punya akun? ',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: _toggleAuthMode,
                    child: Text(isLogin ? 'Daftar' : 'Masuk',
                        style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: AppTheme.textSecondary, size: 18),
                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.bgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textPrimary, size: 24),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
