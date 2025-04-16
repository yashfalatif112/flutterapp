import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/widgets/dialog.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6ED),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Rating',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
                hintText: 'Electrician',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title & Description
            Text(
              'Rate your employer',
              style:
                  GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // User Card
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/images/profile.jpg'), // Replace with your image
              ),
              title: Text('Theresa Webb',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              subtitle: Text('Carpenter', style: GoogleFonts.roboto()),
            ),
            const SizedBox(height: 12),

            // Stars
            Text('How was it?', style: GoogleFonts.roboto(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => const Icon(Icons.star_border, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),

            // TextField
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Leave your thoughts',
                hintStyle: GoogleFonts.roboto(),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ThankYouDialog(
                        titleText: 'Thanks for Review',
                        subtitleText:
                            'Your experience has been shared successfully',
                        buttonText: 'Continue',
                        onPressed: () {
                          
                        },),
                  );
                },
                child: Text('Submit',
                    style:
                        GoogleFonts.roboto(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
