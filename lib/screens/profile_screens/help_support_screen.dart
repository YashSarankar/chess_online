import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@chessonline.com',
      queryParameters: {
        'subject': 'Chess Online Support Request',
      },
    );
    
    try {
      if (!await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8.w),
                  const Text('No email app found'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.w),
                const Text('Could not open email app'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Last updated: ${DateTime.now().year}\n\n'
            '1. Information Collection\n'
            'We collect information necessary for processing payments and verifying identity, including:\n'
            '• Name and email\n'
            '• Payment information\n'
            '• Game statistics and transaction history\n\n'
            '2. Data Security\n'
            'We implement industry-standard security measures to protect your personal and financial information.\n\n'
            '3. Information Usage\n'
            'Your information is used for:\n'
            '• Processing transactions\n'
            '• Account verification\n'
            '• Game functionality\n'
            '• Legal compliance\n\n'
            '4. Third-Party Services\n'
            'We use secure third-party payment processors for all financial transactions.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Terms of Service',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '1. Monetary Games\n'
            '• Players must be of legal age to participate in monetary games\n'
            '• A 5% commission is charged on all winnings\n'
            '• Players agree to fair play and no cheating\n\n'
            '2. Payment Terms\n'
            '• All transactions are final\n'
            '• Winnings are distributed after commission deduction\n'
            '• Minimum and maximum bet limits apply\n\n'
            '3. User Conduct\n'
            '• No use of chess engines or external assistance\n'
            '• No intentional disconnections\n'
            '• Violation may result in account termination\n\n'
            '4. Dispute Resolution\n'
            '• All disputes will be reviewed by our team\n'
            '• Our decisions are final and binding\n\n'
            '5. Account Termination\n'
            'We reserve the right to terminate accounts for:\n'
            '• Violation of terms\n'
            '• Suspicious activity\n'
            '• Fraudulent behavior',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Game Rules',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '1. Game Modes\n\n'
            'Online Mode (Monetary):\n'
            '• Players can bet money on matches\n'
            '• Winner receives opponent\'s bet minus 5% commission\n'
            '• Minimum bet: \$1\n'
            '• Maximum bet: \$1000\n'
            '• Both players must confirm bet before start\n'
            '• Disconnection results in forfeit\n\n'
            'Offline Mode:\n'
            '• Free play with time controls:\n'
            '  - Bullet (1 min)\n'
            '  - Blitz (3 min)\n'
            '  - Rapid (5 min)\n'
            '  - Classical (10 min)\n\n'
            'Bot Mode:\n'
            '• Practice against AI\n'
            '• Multiple difficulty levels\n'
            '• No monetary stakes\n\n'
            '2. Fair Play\n'
            '• No engine assistance\n'
            '• No external help\n'
            '• Violation results in permanent ban\n\n'
            '3. Disconnections\n'
            '• 30-second reconnection window\n'
            '• Forfeit after timeout\n'
            '• Bet is awarded to opponent',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send us an email at:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'support@chessonline.com',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(
                        text: 'support@chessonline.com',
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[900]!,
              Colors.purple[900]!,
              Colors.blue[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Help & Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    // Contact Support Card
                    _buildSupportCard(
                      title: 'Contact Support',
                      description: 'Having issues? Get in touch with our support team',
                      icon: Icons.support_agent,
                      onTap: () => _showContactDialog(context),
                    ),

                    SizedBox(height: 24.h),

                    // FAQ Section
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                    SizedBox(height: 16.h),

                    _buildFAQItem(
                      question: 'What game modes are available?',
                      answer: 'There are three main game modes:\n\n'
                             '• Play vs Bot - Challenge our chess AI\n'
                             '• Multiplayer - Play online against other players\n'
                             '• Time Control - Offline mode with customizable time settings',
                    ),

                    _buildFAQItem(
                      question: 'How do I start a game?',
                      answer: 'On the home screen, tap "Select Game Mode" to choose between:\n\n'
                             '• Play vs Bot\n'
                             '• Online Multiplayer\n'
                             '• Time Control (with preset time formats)',
                    ),

                    _buildFAQItem(
                      question: 'How does the bot difficulty work?',
                      answer: 'The chess bot offers different levels of challenge. Choose a difficulty level that matches your skill - perfect for practice or improving your game.',
                    ),

                    _buildFAQItem(
                      question: 'How does online multiplayer work?',
                      answer: 'In multiplayer mode, you\'ll be matched with other online players. Your rank is calculated based on your performance in these matches.',
                    ),

                    _buildFAQItem(
                      question: 'What is Time Control mode?',
                      answer: 'Time Control mode offers four preset time formats:\n\n'
                             '• Bullet - 1 minute per player\n'
                             '• Blitz - 3 minutes per player\n'
                             '• Rapid - 5 minutes per player\n'
                             '• Classical - 10 minutes per player',
                    ),

                    SizedBox(height: 24.h),

                    // Quick Links
                    Text(
                      'Quick Links',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                    SizedBox(height: 16.h),

                    _buildQuickLink(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => _showPrivacyPolicy(context),
                    ),

                    _buildQuickLink(
                      title: 'Terms of Service',
                      icon: Icons.description_outlined,
                      onTap: () => _showTermsOfService(context),
                    ),

                    _buildQuickLink(
                      title: 'Game Rules',
                      icon: Icons.rule_outlined,
                      onTap: () => _showGameRules(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.purple[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[700]!.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.1),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          children: [
            Text(
              answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildQuickLink({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }
} 