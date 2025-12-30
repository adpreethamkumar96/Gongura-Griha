import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Language Selection Screen
///
/// Allows users to select their preferred app language.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'hi',
      'name': 'Hindi',
      'nativeName': 'हिंदी',
      'flag': '🇮🇳',
    },
    {
      'code': 'te',
      'name': 'Telugu',
      'nativeName': 'తెలుగు',
      'flag': '🇮🇳',
    },
    {
      'code': 'ta',
      'name': 'Tamil',
      'nativeName': 'தமிழ்',
      'flag': '🇮🇳',
    },
    {
      'code': 'kn',
      'name': 'Kannada',
      'nativeName': 'ಕನ್ನಡ',
      'flag': '🇮🇳',
    },
    {
      'code': 'ml',
      'name': 'Malayalam',
      'nativeName': 'മലയാളം',
      'flag': '🇮🇳',
    },
    {
      'code': 'mr',
      'name': 'Marathi',
      'nativeName': 'मराठी',
      'flag': '🇮🇳',
    },
    {
      'code': 'bn',
      'name': 'Bengali',
      'nativeName': 'বাংলা',
      'flag': '🇮🇳',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withAlpha(51)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select your preferred language. The app will restart to apply changes.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Language List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = language['code'] == _selectedLanguage;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Text(
                    language['flag']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    language['name']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    language['nativeName']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          color: AppColors.textTertiary,
                        ),
                  onTap: () => _selectLanguage(language['code']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(String code) {
    if (code == _selectedLanguage) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Language'),
        content: const Text(
          'The app needs to restart to apply the language change. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _selectedLanguage = code);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed to ${_languages.firstWhere((l) => l['code'] == code)['name']}',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              // In a real app, this would trigger locale change
              context.pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
