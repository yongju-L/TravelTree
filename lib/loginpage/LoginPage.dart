import 'package:flutter/material.dart';
import 'package:traveltree/helpers/LoginDatabaseHelper.dart';
import 'package:traveltree/initialpage/InitialPage.dart';
import 'package:traveltree/loginpage/SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginDatabaseHelper _dbHelper = LoginDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _dbHelper.connect(); // PostgreSQL 연결
  }

  Future<void> _login() async {
    // 폼 검증
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        // 이메일과 비밀번호로 사용자 인증
        final user = await _dbHelper.authenticateUser(
          email: email,
          password: password,
        );

        if (user != null) {
          // userId를 추출
          final int userId = user['id'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InitialPage(userId: userId),
            ),
          );
        } else {
          // 인증 실패 시 에러 메시지 출력
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("이메일 또는 비밀번호가 일치하지 않습니다.")),
          );
        }
      } catch (e) {
        print("Login error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _navigateToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '이메일을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '비밀번호를 입력해주세요.' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('로그인'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _navigateToSignUpPage,
                child: const Text('계정이 없으신가요? 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
