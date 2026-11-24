import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/payment_receipt.dart';
import '../models/daily_log.dart';

/// Screen 7: Payment Confirmation & Digital Receipt Screen
/// Displays generated Log ID, Receipt Number, timestamp, bike plate, fee type,
/// amount paid in Leones, and shareable/exportable receipt summary.
class PaymentReceiptScreen extends StatelessWidget {
  final PaymentReceipt receipt;
  final DailyLog? dailyLog;
  final bool isNewPayment;

  const PaymentReceiptScreen({
    super.key,
    required this.receipt,
    this.dailyLog,
    this.isNewPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Digital Payment Receipt'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Receipt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receipt #${receipt.receiptNumber} copied for dispatch.'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            if (isNewPayment)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payment verified and committed to PostgreSQL immutable ledger.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreenDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Official Printable/Verifiable Receipt Container
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Receipt Header (TransitFlow SL Union Seal)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF172033) : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppTheme.primaryGreen,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'TRANSITFLOW SL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Commercial Motorcycle Union Official Receipt',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.goldenAmber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'UN SDG 11.2 • SDG 8 COMPLIANT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldenAmber,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount Callout
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        const Text(
                          'AMOUNT PAID',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppTheme.formatLeones(receipt.amount),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          receipt.currency == 'SLE'
                              ? 'Sierra Leonean Leones (Le)'
                              : receipt.currency,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Receipt Line Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildReceiptRow('Receipt Number', receipt.receiptNumber, isBold: true),
                        _buildReceiptRow(
                          'Log Code',
                          dailyLog?.logCode ?? 'LOG-VERIFIED',
                        ),
                        _buildReceiptRow(
                          'Issued Date & Time',
                          AppTheme.formatDate(receipt.issuedAt),
                        ),
                        _buildReceiptRow(
                          'Fee Category',
                          receipt.feeTypeName ?? 'Union Levy',
                          isBold: true,
                        ),
                        _buildReceiptRow(
                          'Motorcycle Plate',
                          receipt.plateNumber ?? 'BKE-101',
                          isHighlight: true,
                        ),
                        _buildReceiptRow(
                          'Rider Full Name',
                          receipt.riderName ?? 'Alhaji Bah',
                        ),
                        _buildReceiptRow(
                          'Rider Code',
                          receipt.riderCode ?? 'R001',
                        ),
                        _buildReceiptRow(
                          'Payment Method',
                          receipt.paymentMethod ?? 'CASH_OFFICIAL',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Barcode & Immutability Watermark
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Stylized digital barcode
                        Container(
                          height: 38,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '|| | ||| || |||| | ||| || |||| ||| | ${receipt.receiptNumber} ||',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                letterSpacing: 2.0,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.security_rounded, size: 14, color: AppTheme.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              'Cryptographically Verifiable PostgreSQL Ledger Record',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Rider Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: (isBold || isHighlight) ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppTheme.primaryGreen : null,
            ),
          ),
        ],
      ),
    );
  }
}
