import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/controllers/address_controller.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: Obx(() {
        if (addressController.addresses.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.location_on_outlined,
            title: 'No Addresses',
            subtitle: 'Add a delivery address to make checkout faster.',
            buttonText: 'Add Address',
            onButtonTap: () => _showAddressForm(context, addressController),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...addressController.addresses.map((addr) => _AddressCard(
                  address: addr,
                  onEdit: () => _showAddressForm(context, addressController, existingAddress: addr),
                  onDelete: () => _confirmDelete(context, addressController, addr),
                  onSetDefault: () => addressController.setAsDefault(addr.id),
                )),
            const SizedBox(height: 16),
            OutlinedPrimaryButton(
              text: 'Add New Address',
              onTap: () => _showAddressForm(context, addressController),
              icon: Icons.add_location_alt_outlined,
            ),
          ],
        );
      }),
    );
  }

  void _showAddressForm(BuildContext context, AddressController controller,
      {AddressModel? existingAddress}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddressForm(
        controller: controller,
        existingAddress: existingAddress,
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressController controller, AddressModel address) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Delete "${address.label}" address?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(address.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? AppTheme.primaryColor.withOpacity(0.4) : Colors.grey.shade200,
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  address.label,
                  style: const TextStyle(
                      color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ Default',
                    style: TextStyle(
                        color: AppTheme.successColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'default':
                      onSetDefault();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!address.isDefault)
                    const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 2),
          Text(address.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(address.fullAddress,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  final AddressController controller;
  final AddressModel? existingAddress;

  const _AddressForm({required this.controller, this.existingAddress});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _postalCtrl;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final addr = widget.existingAddress;
    _labelCtrl = TextEditingController(text: addr?.label ?? 'Home');
    _nameCtrl = TextEditingController(text: addr?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: addr?.phone ?? '');
    _addressCtrl = TextEditingController(text: addr?.address ?? '');
    _cityCtrl = TextEditingController(text: addr?.city ?? 'Dhaka');
    _districtCtrl = TextEditingController(text: addr?.district ?? 'Dhaka');
    _postalCtrl = TextEditingController(text: addr?.postalCode ?? '');
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existingAddress != null ? 'Edit Address' : 'Add New Address',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              // Label
              Row(
                children: ['Home', 'Office', 'Other'].map((label) {
                  final isSelected = _labelCtrl.text == label;
                  return GestureDetector(
                    onTap: () => setState(() => _labelCtrl.text = label),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Street Address', prefixIcon: Icon(Icons.home_outlined)),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _districtCtrl,
                      decoration: const InputDecoration(labelText: 'District'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _postalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Postal Code'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() => _isDefault = v ?? false),
                  ),
                  const Text('Set as default address', style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => PrimaryButton(
                    text: widget.existingAddress != null ? 'Update Address' : 'Save Address',
                    isLoading: widget.controller.isLoading.value,
                    onTap: _save,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final address = AddressModel(
      id: widget.existingAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: _labelCtrl.text,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim(),
      isDefault: _isDefault,
    );
    if (widget.existingAddress != null) {
      await widget.controller.updateAddress(address);
    } else {
      await widget.controller.addAddress(address);
    }
  }
}
