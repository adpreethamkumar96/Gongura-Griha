import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';

/// Edit Address Screen
///
/// Form to edit an existing delivery address.
class EditAddressScreen extends StatefulWidget {
  final String addressId;

  const EditAddressScreen({
    super.key,
    required this.addressId,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;

  String _selectedType = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;

  final List<String> _addressTypes = ['Home', 'Office', 'Other'];

  // Mock address data based on ID
  Map<String, dynamic> get _mockAddress => {
        '1': {
          'type': 'Home',
          'name': 'Ramesh Kumar',
          'phone': '9876543210',
          'address': '123, Green Valley Apartments',
          'landmark': 'Near City Mall',
          'city': 'Hyderabad',
          'state': 'Telangana',
          'pincode': '500001',
          'isDefault': true,
        },
        '2': {
          'type': 'Office',
          'name': 'Ramesh Kumar',
          'phone': '9876543210',
          'address': '456, Tech Park Building, 5th Floor',
          'landmark': 'HITEC City',
          'city': 'Hyderabad',
          'state': 'Telangana',
          'pincode': '500081',
          'isDefault': false,
        },
      }[widget.addressId] ??
      {
        'type': 'Home',
        'name': '',
        'phone': '',
        'address': '',
        'landmark': '',
        'city': '',
        'state': '',
        'pincode': '',
        'isDefault': false,
      };

  @override
  void initState() {
    super.initState();
    final address = _mockAddress;
    _nameController = TextEditingController(text: address['name'] as String);
    _phoneController = TextEditingController(text: address['phone'] as String);
    _addressController =
        TextEditingController(text: address['address'] as String);
    _landmarkController =
        TextEditingController(text: address['landmark'] as String);
    _cityController = TextEditingController(text: address['city'] as String);
    _stateController = TextEditingController(text: address['state'] as String);
    _pincodeController =
        TextEditingController(text: address['pincode'] as String);
    _selectedType = address['type'] as String;
    _isDefault = address['isDefault'] as bool;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Address'),
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
              Text(
                'Contact Details',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
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
                label: 'Phone Number',
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

              // Address Section
              Text(
                'Address Details',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _addressController,
                label: 'Address (House No, Building, Street)',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _landmarkController,
                label: 'Landmark (Optional)',
                prefixIcon: Icons.flag_outlined,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
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
                      label: 'State',
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

              CustomTextField(
                controller: _pincodeController,
                label: 'Pincode',
                prefixIcon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                maxLength: 6,
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

              // Update Button
              PrimaryButton(
                text: 'Update Address',
                isLoading: _isLoading,
                onPressed: _updateAddress,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }
}
