import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // เพิ่ม import นี้
// import '../services/api_service.dart'; // ปิดการใช้ API เดิม
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // เปลี่ยนชื่อจาก _username เป็น _email ให้ตรงกับ Firebase
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'กรุณากรอกอีเมลและรหัสผ่าน');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // เรียกใช้ Firebase Authentication ในการล็อกอิน
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      
      // ถ้ายืนยันตัวตนสำเร็จ (credential.user ไม่เป็น null)
      if (credential.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EventListScreen()),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      // ดักจับ Error เฉพาะของ Firebase เพื่อแสดงข้อความให้ผู้ใช้เข้าใจง่าย
      String errorMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่';
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'ไม่พบผู้ใช้นี้ในระบบ หรือรูปแบบอีเมลไม่ถูกต้อง';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'บัญชีนี้ถูกระงับการใช้งาน';
      }
      setState(() => _error = errorMessage);
    } catch (e) {
      setState(() => _error = 'เกิดข้อผิดพลาด: ระบบขัดข้อง');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // // 💡 ฟังก์ชัน Seeder สำหรับจำลองข้อมูล
  // Future<void> _seedGuests() async {
  //   // 1. เตรียมรายชื่อจำลอง (คุณสามารถเพิ่มหรือแก้ให้ตรงกับรายชื่อจริงได้เลย)
  //   final List<Map<String, dynamic>> dummyGuests = [
  //     {
  //       "email": "66160100@go.buu.ac.th",
  //       "first_name": "ณัฐพงศ์",
  //       "last_name": "คงศิลป์",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160230@go.buu.ac.th",
  //       "first_name": "นิธิวดี",
  //       "last_name": "บัวผัน",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160083@go.buu.ac.th",
  //       "first_name": "ชิตดนัย",
  //       "last_name": "รัตนเทียนทอง",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160101@go.buu.ac.th",
  //       "first_name": "ณัฐพงษ์",
  //       "last_name": "คำมา",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160081@go.buu.ac.th",
  //       "first_name": "กัจจาฤกษ์",
  //       "last_name": "ศรีภิรมย์",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160350@go.buu.ac.th",
  //       "first_name": "ณปรารินทร์",
  //       "last_name": "เสียงดี",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160102@go.buu.ac.th",
  //       "first_name": "ธนูศิลป์",
  //       "last_name": "ลีนาราช",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160342@go.buu.ac.th",
  //       "first_name": "กิดากร",
  //       "last_name": "รัตนหิรัญ",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160370@go.buu.ac.th",
  //       "first_name": "รวีโรจน์",
  //       "last_name": "สนธิ",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160106@go.buu.ac.th",
  //       "first_name": "ศุภณัฐ",
  //       "last_name": "พันโกฏิ",
  //       "is_checked_in": false
  //     },
  //     {
  //       "email": "66160088@go.buu.ac.th",
  //       "first_name": "โยธิน",
  //       "last_name": "สีใสธรรม",
  //       "is_checked_in": false
  //     }
  //   ];

  //   try {
  //     // โชว์ Loading หรือ Print บอกสถานะ
  //     debugPrint("🚀 กำลังเริ่ม Seed ข้อมูล ${dummyGuests.length} รายการ...");
      
  //     final collection = FirebaseFirestore.instance.collection('guests');

  //     // 2. Loop ข้อมูลแล้วสั่ง .add() ทีละคน
  //     for (var guest in dummyGuests) {
  //       await collection.add(guest);
  //     }

  //     debugPrint("✅ ซีดเดอร์ทำงานเสร็จสิ้น! โยนข้อมูลลง Firebase สำเร็จ");
      
  //     // (Optional) แสดง SnackBar แจ้งเตือนหน้าจอ
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Migrate ข้อมูลเรียบร้อยแล้ว! 🎉')),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("❌ เกิดข้อผิดพลาด: $e");
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 💡 1. เพิ่ม FloatingActionButton ชั่วคราวตรงนี้!
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _seedGuests, // เรียกฟังก์ชัน Seed
      //   backgroundColor: Colors.blue,
      //   child: const Icon(Icons.upload_file, color: Colors.white),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.6),
            radius: 0.8,
            colors: [Color(0xFFFFBBBB), Color(0xFFFFF0F0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo
                const Text(
                  'Eventra',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                // Email Field (เปลี่ยนจาก Username)
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress, // เพิ่มคีย์บอร์ดแบบอีเมล
                  decoration: InputDecoration(
                    hintText: 'Email', // เปลี่ยน Hint เป็น Email
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _signIn(), // เรียก Seeder หลังจากล็อกอินสำเร็จ
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 14)),
                ],
                const SizedBox(height: 12),
                // Forgot password
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: const Text(
                      'forgot password',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 32),
                // Sign Up Link
                

              ],
            ),
          ),
        ),
      ),
    );
  }
}