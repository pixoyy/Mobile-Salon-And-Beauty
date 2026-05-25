import 'package:flutter/material.dart';
import 'package:salon_and_beauty/core/theme/app_colors.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String searchQuery = '';

  final List<Map<String, String>> faqList = [
    {
      'question': 'Bagaimana cara melakukan booking?',
      'answer':
          'Anda dapat melakukan booking dengan langkah berikut:\n\n'
              '1. Pilih layanan yang diinginkan\n'
              '2. Pilih stylist yang tersedia\n'
              '3. Tentukan tanggal dan jam reservasi\n'
              '4. Review pesanan Anda\n'
              '5. Konfirmasi booking\n\n'
              'Setelah berhasil, booking akan muncul pada menu Riwayat Reservasi.',
    },

    {
      'question': 'Apakah bisa membatalkan reservasi?',
      'answer':
          'Ya, reservasi dapat dibatalkan sebelum jadwal booking dimulai. '
              'Masuk ke halaman booking lalu pilih tombol batalkan reservasi.',
    },

    {
      'question': 'Apakah ada biaya tambahan?',
      'answer':
          'Tidak ada biaya tambahan tersembunyi. '
              'Total pembayaran akan ditampilkan sebelum booking dikonfirmasi.',
    },

    {
      'question': 'Metode pembayaran apa saja yang tersedia?',
      'answer':
          'Pembayaran dapat dilakukan melalui:\n\n'
              '• Tunai di salon\n'
              '• Transfer bank\n'
              '• E-wallet\n'
              '• QRIS\n',
    },

    {
      'question': 'Bagaimana cara menggunakan voucher?',
      'answer':
          'Masukkan kode voucher pada halaman checkout sebelum pembayaran dilakukan.',
    },

    {
      'question': 'Bagaimana cara mengubah profile?',
      'answer':
          'Masuk ke menu Account → Edit Profile lalu ubah data yang diinginkan.',
    },

    {
      'question': 'Bagaimana cara mengubah password?',
      'answer':
          'Masuk ke menu Keamanan Akun lalu pilih ubah password.',
    },

    {
      'question': 'Bagaimana jika stylist terlambat?',
      'answer':
          'Tim salon akan menghubungi Anda dan memberikan opsi penjadwalan ulang.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaq =
        faqList.where((faq) {
          return faq['question']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAFB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            /// SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),

                  suffixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.black54,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [

                    /// FAQ LIST
                    ...filteredFaq.map(
                          (faq) => _faqTile(
                        question: faq['question']!,
                        answer: faq['answer']!,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// CONTACT CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFF0EAEA),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Hubungi Kami',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Masih butuh bantuan? Hubungi tim customer service kami.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F8),
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [

                                _contactItem(
                                  icon: Icons.phone_rounded,
                                  title: 'WhatsApp',
                                  subtitle: '0812-3456-7890',
                                ),

                                const SizedBox(height: 18),

                                _contactItem(
                                  icon: Icons.email_outlined,
                                  title: 'Email',
                                  subtitle:
                                  'contact@glamora.id',
                                ),

                                const SizedBox(height: 18),

                                _contactItem(
                                  icon:
                                  Icons.access_time_rounded,
                                  title: 'Jam Operasional',
                                  subtitle:
                                  'Senin - Minggu\n09.00 - 20.00',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqTile({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF0EAEA),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          childrenPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),

          iconColor: AppColors.text,
          collapsedIconColor: AppColors.text,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          title: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _getShortDescription(question),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 14,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Text(
                answer,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),

        Text(
          subtitle,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _getShortDescription(String question) {
    switch (question) {

      case 'Bagaimana cara melakukan booking?':
        return 'Pelajari cara melakukan reservasi melalui aplikasi Glamora.';

      case 'Apakah bisa membatalkan reservasi?':
        return 'Informasi tentang pembatalan dan perubahan jadwal reservasi.';

      case 'Apakah ada biaya tambahan?':
        return 'Informasi biaya tambahan dan detail transaksi reservasi.';

      case 'Metode pembayaran apa saja yang tersedia?':
        return 'Metode pembayaran, voucher, dan informasi transaksi lainnya.';

      case 'Bagaimana cara menggunakan voucher?':
        return 'Panduan penggunaan voucher dan promo booking.';

      case 'Bagaimana cara mengubah profile?':
        return 'Pengaturan akun dan perubahan informasi profile pengguna.';

      case 'Bagaimana cara mengubah password?':
        return 'Pengaturan keamanan akun dan ubah password pengguna.';

      case 'Bagaimana jika stylist terlambat?':
        return 'Informasi keterlambatan stylist dan penjadwalan ulang reservasi.';

      default:
        return 'Informasi bantuan pengguna aplikasi.';
    }
  }
}