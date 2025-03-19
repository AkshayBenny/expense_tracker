import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PasswordResetSentScreen extends StatelessWidget {
  const PasswordResetSentScreen({Key? key}) : super(key: key);

  Future<void> _openGmail() async {
    const url = 'googlegmail://'; // Attempt to open the Gmail app
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Fall back to opening Gmail in the browser.
      const fallbackUrl = 'https://mail.google.com/';
      if (await canLaunch(fallbackUrl)) {
        await launch(fallbackUrl);
      } else {
        throw 'Could not launch Gmail';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Reset Password",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "A password reset link has been sent to the email you have entered if you already have an account.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _openGmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E5AF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Open Gmail",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
