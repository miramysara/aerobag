import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

//APP COLORS
class AppColors {
  static const Color colorPrimary = Color(0xFF0B2D6B);
  static const Color colorOnPrimary = Color(0xFFFFFFFF);
  static const Color colorAccent = Color(0xFF1E88E5);
  static const Color colorSky = Color(0xFFE6F0FB);
  static const Color colorBgTop = Color(0xFFDCEAF8);
  static const Color colorBgBottom = Color(0xFFF5F8FC);
  static const Color colorCard = Color(0xE6FFFFFF);
  static const Color colorBorder = Color(0xFFDCE4EE);
  static const Color colorText = Color(0xFF0B1F44);
  static const Color colorMuted = Color(0xFF6B7A90);
  static const Color colorDanger = Color(0xFFD93025);
}

//MENU ITEMS
enum MenuAction { home, about }

//MAIN APPLICATION
class MyApp extends StatelessWidget {
  // Stateless: nothing
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroBag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.colorPrimary)
            .copyWith(
              primary: AppColors.colorPrimary,
              onPrimary: AppColors.colorOnPrimary,
            ),
        cardTheme: CardThemeData(
          color: AppColors.colorCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

//HOME PAGE
class HomePage extends StatefulWidget {
  // Stateful:screen changes
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController weightController =
      TextEditingController(); //text typed in the weight box
  final TextEditingController rateController =
      TextEditingController(); //text typed in the rate box

  String? selectedClass; // null
  bool hasResult = false;
  double baggageWeight = 0;
  double freeAllowance = 0;
  double excessWeight = 0;
  double excessCharge = 0;
  double serviceTax = 0;
  double totalPayable = 0;

  MenuAction currentPage = MenuAction.home;

  //About page
  final String authorName = 'Amirah Maisarah Binti Abdul Razak';
  final String matricNo = '2025426422';
  final String course = 'ICT602 Mobile Technology and Development';
  final String githubUrl = 'https://github.com/miramysara/aerobag';

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  //CALCULATE FUNCTION
  void calculateFee() {
    double weight;
    try {
      //in case the weight is not a number
      weight = double.parse(weightController.text.trim());
    } on FormatException catch (e) {
      debugPrint('FormatException: $e');
      showMessage(
        weightController.text.trim().isEmpty
            ? 'Please enter the baggage weight.'
            : 'Baggage weight must be a number.',
      );
      return;
    }

    if (selectedClass == null) {
      showMessage('Please select a ticket class.');
      return;
    }

    final double? rate = double.tryParse(
      rateController.text.trim(),
    ); //gives null if the rate is not a number
    if (rate == null) {
      showMessage('Please enter a valid rate per kg.');
      return;
    }

    if (weight <= 0 || weight > 100) {
      showMessage('Baggage weight must be between 0.1 and 100 kg.');
      return;
    }

    if (rate <= 0 || rate > 500) {
      showMessage('Rate per kg must be between RM0.01 and RM500.');
      return;
    }

    double allowance = 20;
    if (selectedClass == 'Business') allowance = 40;

    double excess = weight - allowance;
    if (excess < 0) excess = 0;

    setState(() {
      // Save the results and update
      hasResult = true;
      baggageWeight = weight;
      freeAllowance = allowance;
      excessWeight = excess;
      excessCharge = excess * rate; //excess weight x rate per kg
      serviceTax = excessCharge * 0.08; // 8% service tax
      totalPayable = excessCharge + serviceTax;
    });
  }

  //RESET FORM
  void resetForm() {
    setState(() {
      weightController.clear();
      rateController.clear();
      selectedClass = null;
      hasResult = false;
    });
  }

  //MESSAGE FUNCTION
  void showMessage(String text) {
    setState(() => hasResult = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: AppColors.colorPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  //SHARE FUNCTION
  Future<void> shareResult() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'AeroBag - Excess Baggage Fee Estimate\n'
            'Ticket class: $selectedClass\n'
            'Excess baggage weight: ${excessWeight.toStringAsFixed(2)} kg\n'
            'Excess baggage charge: RM ${excessCharge.toStringAsFixed(2)}\n'
            'Service tax (8%): RM ${serviceTax.toStringAsFixed(2)}\n'
            'Total amount payable: RM ${totalPayable.toStringAsFixed(2)}',
        subject: 'My AeroBag excess baggage fee estimate',
      ),
    );
  }

  //GITHUB
  Future<void> openGitHub() async {
    try {
      await launchUrl(Uri.parse(githubUrl)); // url_launcher
    } catch (e) {
      debugPrint('Launch error: $e');
      showMessage('Unable to open the GitHub link.');
    }
  }

  //DECORATION
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.colorBgTop,
            AppColors.colorBgBottom,
            AppColors.colorBgTop,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.colorPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          actions: [
            PopupMenuButton<MenuAction>(
              // Navigation menu with Home and About (Lab 3)
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (MenuAction action) {
                switch (action) {
                  case MenuAction.home:
                    setState(() => currentPage = MenuAction.home);
                    break;
                  case MenuAction.about:
                    setState(() => currentPage = MenuAction.about);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem(value: MenuAction.home, child: Text('Home')),
                PopupMenuItem(value: MenuAction.about, child: Text('About')),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(
          // Checks the screen width (Lab 7)
          builder: (context, constraints) {
            final double width = constraints.maxWidth > 760
                ? 760
                : constraints.maxWidth;
            final bool wide =
                width >= 600; // true = two columns on Chrome/tablet
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: currentPage == MenuAction.home
                        ? buildHomePage(wide)
                        : buildAboutPage(
                            wide,
                          ), // Show the Home page or the About page
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //HERO TITLE
  Widget heroTitle(String title, String subtitle, List<Widget> extra) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.colorAccent.withValues(alpha: 0.35),
                AppColors.colorAccent.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 56, bottom: 24),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.colorPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.colorMuted,
                  height: 1.4,
                ),
              ),
              ...extra,
            ],
          ),
        ),
      ],
    );
  }

  // INFO CHIP
  Widget infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.colorBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.colorAccent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.colorText,
            ),
          ),
        ],
      ),
    );
  }

  //SECTION HEADER
  Widget sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.colorAccent, AppColors.colorPrimary],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.colorText,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.colorMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //FIELD LABEL
  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.colorText,
        ),
      ),
    );
  }

  // TEXT BOX STYLE
  InputDecoration inputStyle(String hint, String suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA3AEBE)),
      suffixText: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.colorBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.colorAccent, width: 1.6),
      ),
    );
  }

  //TWO COLUMNS
  Widget twoColumns(bool wide, Widget left, Widget right) {
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 20),
          Expanded(child: right),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [left, const SizedBox(height: 18), right],
    );
  }

  // HOME PAGE CONTENT
  Widget buildHomePage(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heroTitle(
          'AeroBag',
          'Excess Baggage Fee Calculator\nKnow what you pay before you reach the check-in counter.',
          [
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                infoChip(Icons.airline_seat_recline_normal, 'Economy 20 kg'),
                infoChip(Icons.airline_seat_flat, 'Business 40 kg'),
                infoChip(Icons.percent, '8% service tax'),
              ],
            ),
          ],
        ),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionHeader(
                  Icons.luggage,
                  'Baggage Details',
                  'Weight, ticket class and rate',
                ),
                const SizedBox(height: 22),
                twoColumns(
                  wide,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldLabel('Baggage weight'),
                      TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: inputStyle('e.g. 25', 'kg'),
                      ),
                      const SizedBox(height: 18),
                      fieldLabel('Excess rate per kg'),
                      TextField(
                        controller: rateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: inputStyle('e.g. 15', 'RM'),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldLabel('Ticket class'),
                      RadioGroup<String>(
                        // Only one ticket class can be selected (Lab 4)
                        groupValue: selectedClass,
                        onChanged: (v) => setState(() => selectedClass = v),
                        child: Column(
                          children: [
                            classRadio(
                              'Economy',
                              '20 kg free allowance',
                              Icons.airline_seat_recline_normal,
                            ),
                            const SizedBox(height: 10),
                            classRadio(
                              'Business',
                              '40 kg free allowance',
                              Icons.airline_seat_flat,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: gradientButton(
                        Icons.calculate_outlined,
                        'Calculate Fee',
                        calculateFee,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      key: const Key('btnReset'),
                      onPressed: resetForm,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.colorMuted,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionHeader(
                  Icons.receipt_long,
                  'Fee Summary',
                  'Your excess baggage breakdown',
                ),
                const SizedBox(height: 20),
                hasResult ? buildResult(wide) : buildEmptyResult(), // Show the result only after Calculate is pressed
              ],
            ),
          ),
        ),
      ],
    );
  }

  //BUTTON
  Widget gradientButton(IconData icon, String label, VoidCallback onPressed) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.colorAccent, AppColors.colorPrimary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton.icon(
        key: const Key('btnCalculate'),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  //RESULT
  Widget buildResult(bool wide) {
    final double usage = baggageWeight / freeAllowance;
    final bool isOver = excessWeight > 0;

    return twoColumns(
      wide,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Allowance used ($selectedClass ${freeAllowance.toStringAsFixed(0)} kg)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.colorMuted,
                ),
              ),
              Text(
                '${(usage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isOver ? AppColors.colorDanger : AppColors.colorAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usage > 1 ? 1 : usage,
              minHeight: 8,
              backgroundColor: AppColors.colorSky,
              color: isOver ? AppColors.colorDanger : AppColors.colorAccent,
            ),
          ),
          const SizedBox(height: 12),
          resultRow(
            'Excess baggage weight',
            '${excessWeight.toStringAsFixed(2)} kg',
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
          resultRow(
            'Excess baggage charge',
            'RM ${excessCharge.toStringAsFixed(2)}',
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
          resultRow('Service tax (8%)', 'RM ${serviceTax.toStringAsFixed(2)}'),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.colorSky,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total amount payable',
                  style: TextStyle(fontSize: 13, color: AppColors.colorMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${totalPayable.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.colorPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isOver
                      ? 'Your bag is ${excessWeight.toStringAsFixed(2)} kg over the free allowance.'
                      : 'Within the free allowance. No extra charge.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.colorText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: shareResult,
            icon: const Icon(Icons.ios_share, size: 18),
            label: const Text(
              'Share result',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.colorPrimary,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.colorBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //EMPTY RESULT
  Widget buildEmptyResult() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.colorSky.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.flight_takeoff, size: 34, color: AppColors.colorAccent),
          SizedBox(height: 10),
          Text(
            'No estimate yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.colorText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Fill in your baggage details and tap Calculate Fee.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.colorMuted),
          ),
        ],
      ),
    );
  }

  //TICKET CLASS RADIO BUTTON
  Widget classRadio(String value, String subtitle, IconData icon) {
    final bool isSelected = selectedClass == value;
    return RadioListTile<String>(
      value: value,
      title: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.colorText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: AppColors.colorMuted),
      ),
      secondary: Icon(
        icon,
        color: isSelected ? AppColors.colorAccent : AppColors.colorMuted,
      ),
      tileColor: Colors.white,
      selectedTileColor: AppColors.colorSky,
      selected: isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.colorAccent : AppColors.colorBorder,
          width: isSelected ? 1.6 : 1,
        ),
      ),
    );
  }

  //RESULT ROW
  Widget resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.colorMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.colorText,
            ),
          ),
        ],
      ),
    );
  }

  //ABOUT PAGE CONTENT
  Widget buildAboutPage(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorAccent.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/icon/icon.png',
                width: 104,
                height: 104,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.luggage,
                  size: 80,
                  color: AppColors.colorPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'AeroBag',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.colorPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Excess Baggage Fee Calculator',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.colorMuted),
        ),
        const SizedBox(height: 28),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                overline('ABOUT THE APP'),
                const SizedBox(height: 10),
                const Text(
                  'A simple way for travellers to estimate excess baggage charges before arriving '
                  'at the airport, based on ticket class and the airline rate per kg.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.colorText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                featureRow(
                  Icons.scale_outlined,
                  'Calculates excess baggage weight',
                ),
                featureRow(
                  Icons.receipt_long_outlined,
                  'Shows charge with 8% service tax',
                ),
                featureRow(Icons.ios_share, 'Share your estimate with others'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                overline('DEVELOPER'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/myramysara.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.colorAccent,
                                AppColors.colorPrimary,
                              ],
                            ),
                          ),
                          child: Text(
                            initials(authorName),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.colorText,
                            ),
                          ),
                          const Text(
                            'Student Developer',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.colorMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.colorBorder),
                detailRow('Matric No', matricNo),
                const Divider(height: 1, color: AppColors.colorBorder),
                detailRow('Course', course),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        GestureDetector(
          onTap: openGitHub, // Tap the card to open GitHub (Lab 3: GestureDetector)
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.colorPrimary, Color(0xFF16418F)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOURCE CODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'View on GitHub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        githubUrl,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_outward,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        Text(
          '© 2026 $authorName. All rights reserved.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.colorMuted),
        ),
        const SizedBox(height: 4),
        const Text(
          'Built with Flutter for ICT602',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFFA3AEBE)),
        ),
      ],
    );
  }

  Widget overline(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: AppColors.colorAccent,
      ),
    );
  }

  Widget featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.colorSky,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.colorAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.colorMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String initials(String name) {
    String result = '';
    for (String word in name.trim().split(' ')) {
      if (word.isNotEmpty && result.length < 2) {
        result += word[0].toUpperCase();
      }
    }
    return result;
  }
}
