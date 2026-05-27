import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onVerified,
  });

  final String verificationId;
  final String phoneNumber;
  final Future<void> Function(String uid) onVerified;

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.trim().length != 6) {
      setState(() => _error = 'Please enter the 6-digit OTP');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await AuthService.instance.verifyOTP(
        verificationId: widget.verificationId,
        otp: _otpCtrl.text.trim(),
      );
      await widget.onVerified(result.user!.uid);
    } catch (e) {
      setState(() {
        _error = 'Invalid OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.sms_outlined,
                size: 48, color: AppColors.primary),
            const SizedBox(height: 20),
            Text('OTP bheja gaya',
                style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              '${widget.phoneNumber} pe 6-digit OTP bheja gaya hai.',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 12),
              decoration: const InputDecoration(
                hintText: '------',
                counterText: '',
              ),
              onChanged: (v) {
                if (v.length == 6) _verify();
              },
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error,
                  style: const TextStyle(
                      color: AppColors.expense, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text('Verify & Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}