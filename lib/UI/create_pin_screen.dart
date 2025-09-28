import 'package:flutter/material.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String pin = '';
  List<bool> pinFilled = [false, false, false, false];

  void _createPin() {
    if (pin.length == 4) {
      Navigator.pushNamed(context, '/touch-id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06, // تقليل الهوامش الجانبية
            vertical: size.height * 0.02, // تقليل الهوامش العلوية والسفلية
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.04), // تقليل المسافة

              // Back Button - إضافة زر الرجوع
              Align(
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
              ),

              SizedBox(height: size.height * 0.03), // تقليل المسافة

              Text(
                'Create your PIN',
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a four digit passcode to secure your account',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.04), // تقليل المسافة

              // 🔹 PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.02), // تقليل المسافة بين النقاط
                    width: size.width * 0.14,
                    height: size.width * 0.14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: pinFilled[index]
                            ? const Color(0xFF6C5CE7)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: pinFilled[index]
                          ? Container(
                        width: size.width * 0.04,
                        height: size.width * 0.04,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C5CE7),
                          shape: BoxShape.circle,
                        ),
                      )
                          : null,
                    ),
                  );
                }),
              ),

              SizedBox(height: size.height * 0.05), // تقليل المسافة

              // 🔹 Number Pad - مع تقليل المسافات
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.02), // تقليل الهوامش الجانبية
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: size.width / (size.height * 0.18), // تعديل النسبة
                      crossAxisSpacing: size.width * 0.06, // تقليل المسافة بين الأعمدة
                      mainAxisSpacing: size.height * 0.015, // تقليل المسافة بين الصفوف
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        return _buildBiometricButton(size); // إضافة زر البصمة بدل المساحة الفارغة
                      } else if (index == 10) {
                        return _buildNumberButton('0', size);
                      } else if (index == 11) {
                        return _buildBackspaceButton(size);
                      } else {
                        return _buildNumberButton('${index + 1}', size);
                      }
                    },
                  ),
                ),
              ),

              // 🔹 Create PIN Button
              Container(
                padding: EdgeInsets.only(
                  bottom: size.height * 0.03,
                  top: size.height * 0.01,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: size.height * 0.07,
                  child: ElevatedButton(
                    onPressed: pin.length == 4 ? _createPin : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Create PIN',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 زر الأرقام - نفس الشكل تماماً
  Widget _buildNumberButton(String number, Size size) {
    return GestureDetector(
      onTap: () {
        if (pin.length < 4) {
          setState(() {
            pin += number;
            pinFilled[pin.length - 1] = true;
          });
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: size.width * 0.09,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 زر الحذف - نفس الشكل تماماً
  Widget _buildBackspaceButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (pin.isNotEmpty) {
          setState(() {
            pinFilled[pin.length - 1] = false;
            pin = pin.substring(0, pin.length - 1);
          });
        }
      },
      child: const Center(
        child: Icon(
          Icons.backspace_outlined,
          size: 28,
          color: Colors.black,
        ),
      ),
    );
  }

  // 🔹 زر البصمة الجديد
  Widget _buildBiometricButton(Size size) {
    return GestureDetector(
      onTap: () {
        // Biometric authentication
      },
      child: const Center(
        child: Icon(
          Icons.fingerprint_rounded,
          size: 28,
          color: Colors.black,
        ),
      ),
    );
  }
}