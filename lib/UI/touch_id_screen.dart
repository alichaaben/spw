import 'package:flutter/material.dart';

class TouchIdScreen extends StatefulWidget {
  const TouchIdScreen({super.key});

  @override
  State<TouchIdScreen> createState() => _TouchIdScreenState();
}

class _TouchIdScreenState extends State<TouchIdScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isEnabled = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start pulsating animation
    _startPulsatingAnimation();
  }

  void _startPulsatingAnimation() {
    _animationController.repeat(reverse: true);
  }

  void _stopPulsatingAnimation() {
    _animationController.stop();
    _animationController.animateTo(1.0, duration: const Duration(milliseconds: 300));
  }

  void _enableTouchId() {
    setState(() {
      _isAnimating = true;
      _isEnabled = true;
    });

    _stopPulsatingAnimation();

    // Simulate biometric setup process
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
        Navigator.pushNamed(context, '/success');
      }
    });
  }

  void _skip() {
    Navigator.pushNamed(context, '/success');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  children: [
                    // Back Button
                    _buildBackButton(),

                    SizedBox(height: size.height * 0.04),

                    // Animated Fingerprint Illustration
                    _buildFingerprintIllustration(),

                    SizedBox(height: size.height * 0.06),

                    // Title Section
                    _buildTitleSection(isSmallScreen),

                    SizedBox(height: size.height * 0.03),

                    // Features List
                    _buildFeaturesList(),

                    const Spacer(),

                    // Enable Button
                    _buildEnableButton(size),

                    SizedBox(height: size.height * 0.02),

                    // Skip Button
                    _buildSkipButton(),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.grey.shade700),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }

  Widget _buildFingerprintIllustration() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle with pulse effect
            if (!_isEnabled)
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withOpacity(_opacityAnimation.value * 0.3),
                    width: 1,
                  ),
                ),
              ),

            // Middle circle
            if (!_isEnabled)
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withOpacity(_opacityAnimation.value * 0.5),
                    width: 1,
                  ),
                ),
              ),

            // Inner circle
            if (!_isEnabled)
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withOpacity(_opacityAnimation.value * 0.7),
                    width: 1,
                  ),
                ),
              ),

            // Main fingerprint circle
            Transform.scale(
              scale: _isEnabled ? 1.0 : _scaleAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isEnabled
                      ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00B894), Color(0xFF00A885)],
                  )
                      : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isEnabled ? const Color(0xFF00B894) : const Color(0xFF6C5CE7))
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _isAnimating
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                )
                    : Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleSection(bool isSmallScreen) {
    return Column(
      children: [
        Text(
          _isEnabled ? "Biometric Enabled!" : "Enable Biometric Access",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        Text(
          _isEnabled
              ? "Your biometric authentication has been successfully set up for secure and fast access."
              : "Enable Face ID/Touch ID to login & authorize transactions faster and more securely.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.rocket_launch_rounded, 'text': 'Faster login and payments'},
      {'icon': Icons.security_rounded, 'text': 'Enhanced security protection'},
      {'icon': Icons.face_retouching_natural_rounded, 'text': 'Convenient authentication'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: features.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: const Color(0xFF6C5CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature['text'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildEnableButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, size.height * 0.065),
          backgroundColor: _isEnabled
              ? const Color(0xFF00B894)
              : const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: (_isEnabled
              ? const Color(0xFF00B894)
              : const Color(0xFF6C5CE7)).withOpacity(0.3),
        ),
        onPressed: _isEnabled ? null : _enableTouchId,
        child: _isAnimating
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _isEnabled ? "Biometric Enabled" : "Enable Biometric",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _skip,
      child: Text(
        "Skip, I'll do this later",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}