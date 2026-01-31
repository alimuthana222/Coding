import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/wallet_model.dart';
import '../../bloc/wallet_cubit.dart';
import '../../bloc/wallet_state.dart';

class DepositSheet extends StatefulWidget {
  const DepositSheet({super.key});

  @override
  State<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<DepositSheet> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referenceController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.zainCash;
  File? _proofImage;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _proofImage = File(image.path));
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغ صحيح')),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم الهاتف')),
      );
      return;
    }

    final success = await context.read<WalletCubit>().requestDeposit(
      amount: amount,
      method: _selectedMethod,
      paymentPhone: _phoneController.text,
      paymentReference: _referenceController.text.isNotEmpty
          ? _referenceController.text
          : null,
      proofImage: _proofImage,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  'إيداع رصيد',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method
                  Text('طريقة الدفع', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentMethodCard(
                          icon: '📱',
                          name: 'زين كاش',
                          isSelected: _selectedMethod == PaymentMethod.zainCash,
                          onTap: () => setState(() => _selectedMethod = PaymentMethod.zainCash),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PaymentMethodCard(
                          icon: '💳',
                          name: 'كي كارد الرافدين',
                          isSelected: _selectedMethod == PaymentMethod.qiCard,
                          onTap: () => setState(() => _selectedMethod = PaymentMethod.qiCard),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.info_circle, color: AppColors.info, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'خطوات الإيداع:',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStep('1', 'حوّل المبلغ إلى الرقم التالي:'),
                        Container(
                          margin: const EdgeInsets.only(right: 24, top: 4, bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedMethod == PaymentMethod.zainCash
                                    ? '07801234567'
                                    : '6280 XXXX XXXX XXXX',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Iconsax.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: _selectedMethod == PaymentMethod.zainCash
                                        ? '07801234567'
                                        : '6280XXXXXXXXXXXX',
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم النسخ')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        _buildStep('2', 'احتفظ برقم العملية'),
                        _buildStep('3', 'املأ البيانات أدناه وارفق صورة الإيصال'),
                        _buildStep('4', 'انتظر التأكيد خلال 24 ساعة'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'المبلغ (د.ع)',
                      hintText: '10000',
                      prefixIcon: Icon(Iconsax.money),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: _selectedMethod == PaymentMethod.zainCash
                          ? 'رقم زين كاش المرسل منه'
                          : 'رقم الهاتف',
                      hintText: '07xxxxxxxxx',
                      prefixIcon: const Icon(Iconsax.call),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reference
                  TextField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'رقم العملية (اختياري)',
                      hintText: 'رقم العملية من الإيصال',
                      prefixIcon: Icon(Iconsax.document),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Proof Image
                  Text('صورة إثبات الدفع', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                        image: _proofImage != null
                            ? DecorationImage(
                          image: FileImage(_proofImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _proofImage == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.camera,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط لإضافة صورة',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  BlocBuilder<WalletCubit, WalletState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isProcessing ? null : _submit,
                          child: state.isProcessing
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text('إرسال طلب الإيداع'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String icon;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}