import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int? _selectedAddressId;
  String _selectedPaymentMethod = 'cod';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: cartAsync.when(
        data: (cart) => _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Shipping Address'),
                    const SizedBox(height: 12),
                    _buildAddressSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 12),
                    _buildPaymentSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Order Summary'),
                    const SizedBox(height: 12),
                    _buildOrderSummary(cart.total),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (cart) => _buildBottomBar(cart.total),
        orElse: () => null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddressSection() {
    final apiService = ref.read(apiServiceProvider);
    return FutureBuilder<User>(
      future: apiService.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Failed to load addresses');
        }

        final addresses = snapshot.data!.addresses;
        if (addresses.isEmpty) {
          return _buildNoAddressCard();
        }

        // Auto-select default address if none selected
        if (_selectedAddressId == null && addresses.isNotEmpty) {
          final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
          _selectedAddressId = defaultAddr.id;
        }

        return Column(
          children: addresses.map((addr) => _buildAddressCard(addr)).toList(),
        );
      },
    );
  }

  Widget _buildAddressCard(Address address) {
    final isSelected = _selectedAddressId == address.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = address.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${address.addressLine1}, ${address.city}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  Text('${address.state}, ${address.postalCode}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  Text('Phone: ${address.phone}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('No addresses found'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/addresses'),
            child: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: [
        _buildPaymentOption('cod', 'Cash on Delivery', Icons.money),
        _buildPaymentOption('payu', 'Online Payment (PayU)', Icons.payment),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '₹${total.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Shipping', 'FREE', isGreen: true),
          const Divider(height: 24),
          _buildSummaryRow('Total', '₹${total.toStringAsFixed(0)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
            color: isGreen ? Colors.green : (isBold ? Colors.black : Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedAddressId == null ? null : _handlePlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(apiServiceProvider).placeOrder(
        _selectedAddressId!,
        _selectedPaymentMethod,
      );

      // Refresh cart state
      ref.read(cartProvider.notifier).fetchCart();

      if (!mounted) return;

      if (_selectedPaymentMethod == 'payu') {
        // Here we would normally initiate PayU flow
        // For now, redirect to orders
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed! Proceeding to payment... (Simulation)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
      
      context.go('/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
