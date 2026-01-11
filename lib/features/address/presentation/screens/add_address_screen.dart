import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/models/address_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';

/// Add Address Screen
///
/// Form to add a new delivery address with detailed fields and pincode auto-fill.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _flatHouseController = TextEditingController();
  final _floorController = TextEditingController();
  final _buildingController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _selectedType = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isLookingUpPincode = false;

  final List<String> _addressTypes = ['Home', 'Office', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _flatHouseController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  /// Lookup city and state from pincode using postal API
  Future<void> _lookupPincode(String pincode) async {
    if (pincode.length != 6) return;

    setState(() => _isLookingUpPincode = true);

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.postalpincode.in/pincode/$pincode',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffices = data[0]['PostOffice'] as List;
          if (postOffices.isNotEmpty) {
            final firstOffice = postOffices[0];
            setState(() {
              _cityController.text = firstOffice['District'] ?? '';
              _stateController.text = firstOffice['State'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      // Silently fail - user can enter manually
      debugPrint('Pincode lookup failed: $e');
    } finally {
      setState(() => _isLookingUpPincode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Type
              Text(
                'Address Type',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _buildAddressTypeSelector(),

              const SizedBox(height: 24),

              // Contact Details Section
              _buildSectionHeader('Contact Details', Icons.person_outline),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name *',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                prefixIcon: Icons.phone_outlined,
                prefixText: '+91 ',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length != 10) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Address Details Section
              _buildSectionHeader('Address Details', Icons.location_on_outlined),
              const SizedBox(height: 12),

              // House/Flat Number
              CustomTextField(
                controller: _flatHouseController,
                label: 'House/Flat No. *',
                prefixIcon: Icons.home_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter house/flat number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Floor and Building in a row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _floorController,
                      label: 'Floor (Optional)',
                      prefixIcon: Icons.layers_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _buildingController,
                      label: 'Building Name',
                      prefixIcon: Icons.apartment_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Street/Area
              CustomTextField(
                controller: _streetController,
                label: 'Street/Area/Locality *',
                prefixIcon: Icons.signpost_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street/area';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Landmark
              CustomTextField(
                controller: _landmarkController,
                label: 'Landmark (Optional)',
                prefixIcon: Icons.flag_outlined,
                hint: 'Near temple, school, etc.',
              ),

              const SizedBox(height: 24),

              // Location Details Section
              _buildSectionHeader('Location Details', Icons.pin_drop_outlined),
              const SizedBox(height: 12),

              // Pincode (first - triggers auto-fill)
              CustomTextField(
                controller: _pincodeController,
                label: 'Pincode *',
                prefixIcon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                maxLength: 6,
                suffix: _isLookingUpPincode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onChanged: (value) {
                  if (value.length == 6) {
                    _lookupPincode(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pincode';
                  }
                  if (value.length != 6) {
                    return 'Please enter a valid 6-digit pincode';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),
              Text(
                'Enter pincode to auto-fill city and state',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 16),

              // City and State
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City *',
                      prefixIcon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State *',
                      prefixIcon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Set as Default
              CheckboxListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value ?? false);
                },
                title: const Text('Set as default address'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),

              const SizedBox(height: 24),

              // Save Button
              PrimaryButton(
                text: 'Save Address',
                isLoading: _isLoading,
                onPressed: _saveAddress,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleSmall),
      ],
    );
  }

  Widget _buildAddressTypeSelector() {
    return Row(
      children: _addressTypes.map((type) {
        final isSelected = _selectedType == type;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(type),
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(type),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedType = type);
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'office':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  AddressType _getAddressType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return AddressType.home;
      case 'office':
        return AddressType.office;
      default:
        return AddressType.other;
    }
  }

  /// Build full address string from individual fields
  String _buildFullAddress() {
    final parts = <String>[];

    if (_flatHouseController.text.isNotEmpty) {
      parts.add(_flatHouseController.text.trim());
    }
    if (_floorController.text.isNotEmpty) {
      parts.add('Floor ${_floorController.text.trim()}');
    }
    if (_buildingController.text.isNotEmpty) {
      parts.add(_buildingController.text.trim());
    }
    if (_streetController.text.isNotEmpty) {
      parts.add(_streetController.text.trim());
    }

    return parts.join(', ');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await addressService.addAddress(
        userId: userId,
        name: _nameController.text.trim(),
        phone: '+91 ${_phoneController.text.trim()}',
        address: _buildFullAddress(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        type: _getAddressType(_selectedType),
        isDefault: _isDefault,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
