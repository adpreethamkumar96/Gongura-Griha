import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// OTP Verification Screen
///
/// Screen for entering OTP sent to phone number.
class OtpScreen extends StatefulWidget {
  final String? phoneNumber;

  const OtpScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorText;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto focus on OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorText = 'Please enter complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Implement actual OTP verification
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // For demo, any 6-digit OTP works
    // In production, verify with backend
    final isNewUser = true; // TODO: Get from API response

    setState(() {
      _isLoading = false;
    });

    if (isNewUser) {
      context.go(AppRoutes.register);
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;

    // TODO: Implement actual resend OTP logic
    _startResendTimer();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTypography.h3,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Phone',
                style: AppTypography.h2,
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Enter the 6-digit code sent to\n',
                    ),
                    TextSpan(
                      text: '+91 ${widget.phoneNumber ?? '**********'}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // OTP Input
              Center(
                child: Pinput(
                  controller: _otpController,
                  focusNode: _focusNode,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration?.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration?.copyWith(
                      border: Border.all(color: AppColors.error),
                    ),
                  ),
                  onChanged: (value) {
                    if (_errorText != null) {
                      setState(() {
                        _errorText = null;
                      });
                    }
                  },
                  onCompleted: (value) {
                    _verifyOtp();
                  },
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _errorText!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Resend OTP
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend OTP in ${_resendSeconds}s',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: AppTypography.buttonMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              // Verify button
              PrimaryButton(
                text: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
