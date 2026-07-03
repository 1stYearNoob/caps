import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/my_data.dart';
import '../../services/auth_service.dart';
import '../../services/translation_service.dart';
import '../login_page.dart';
import '../translator_page.dart';
import '../terms_of_service_page.dart';
import '../../theme/colors/light_colors.dart';
import '../../widgets/active_project_card.dart';
import '../../widgets/task_column.dart';
import '../../widgets/top_container.dart';
import '../../widgets/how_to_plant_page.dart';
import '../tutorial/tutorial_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _profileImage;
  String _userName = '';
  bool _isLoadingName = true;

  Timer? _taskUpdateTimer;
  int _dailyScans = 0;
  bool _weatherAnalyzed = false;
  bool _adminUploaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadDailyTasks();
    _taskUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadDailyTasks();
    });
  }

  @override
  void dispose() {
    _taskUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final currentDate = getSgtDateString();
    
    // 1. Scan task
    final lastScanDate = prefs.getString('last_scan_date_sgt');
    int scanCount = 0;
    if (lastScanDate == currentDate) {
      scanCount = prefs.getInt('daily_scan_count') ?? 0;
    }
    
    // 2. Weather task
    final lastWeatherDate = prefs.getString('weather_analyzed_date_sgt');
    bool weatherDone = lastWeatherDate == currentDate;
    
    // 3. Admin upload task
    final lastAdminDate = prefs.getString('uploaded_to_admin_date_sgt');
    bool adminDone = lastAdminDate == currentDate;

    if (mounted) {
      setState(() {
        _dailyScans = scanCount;
        _weatherAnalyzed = weatherDone;
        _adminUploaded = adminDone;
      });
    }
  }

  Future<void> _fetchUserData() async {
    String? userId = AuthService().currentUserId;
    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          String name = data['name'] ?? '';

          if (name.trim().isEmpty) {
            _showNamePrompt(userId);
          } else {
            setState(() {
              _userName = name;
              _isLoadingName = false;
            });
          }
        } else {
          await AuthService().logout();
          if (mounted) {
             Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginPage()), 
                (route) => false,
             );
          }
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        setState(() {
          _isLoadingName = false;
        });
      }
    } else {
      setState(() {
        _isLoadingName = false;
      });
    }
  }

  void _showNamePrompt(String userId) {
    final TextEditingController nameController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Welcome!'.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please enter your name to continue.'.tr),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Your Name".tr,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
              actions: <Widget>[
                isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : TextButton(
                        child: Text('Save'.tr),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          if (nameController.text.trim().isEmpty) return;

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update({'name': nameController.text.trim()});

                            if (mounted) {
                              this.setState(() {
                                _userName = nameController.text.trim();
                                _isLoadingName = false;
                              });
                            }
                            Navigator.of(dialogContext).pop();
                          } catch (e) {
                            setState(() {
                              isSaving = false;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to save name.'.tr),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Text subheading(String title) {
    return Text(
      title.tr,
      style: const TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: LightColors.kBlue,
                    radius: 40.0,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'F',
                            style: const TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userName.isNotEmpty ? _userName : "Farmer".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text('Translator'.tr),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TranslatorPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text('Terms and Conditions'.tr),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServicePage(showButtons: false)),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
        children: <Widget>[
          TopContainer(
            height: 200,
            width: width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.menu, color: LightColors.kDarkBlue, size: 30.0),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: LightColors.kDarkBlue, size: 25.0),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: LightColors.kLightYellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(
                                  'Log Out'.tr,
                                  style: const TextStyle(
                                    color: LightColors.kDarkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to log out?'.tr,
                                  style: const TextStyle(
                                    color: LightColors.kDarkBlue,
                                    fontSize: 16,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel'.tr,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: LightColors.kRed,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context); // Close dialog
                                      await AuthService().logout();
                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const LoginPage()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Log Out'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [LightColors.kRed, LightColors.kDarkYellow, LightColors.kBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LightColors.kDarkYellow.withOpacity(0.5),
                                blurRadius: 12.0,
                                spreadRadius: 3.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: LightColors.kLightYellow,
                            ),
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                backgroundColor: LightColors.kBlue,
                                radius: 38.0,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Text(
                                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'F',
                                        style: const TextStyle(
                                          fontSize: 30.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _isLoadingName 
                                ? const SizedBox(
                                    height: 20, 
                                    width: 20, 
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                  )
                                : Text(
                                    '${'HI!'.tr} ${_userName.isNotEmpty ? _userName : "Farmer".tr}',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      color: LightColors.kDarkBlue,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                            Text(
                              'Farmer'.tr,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black45,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            subheading('Task To Do'),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        TaskColumn(
                          icon: Icons.alarm,
                          iconBackgroundColor: LightColors.kRed,
                          title: 'Scan'.tr,
                          subtitle: '$_dailyScans/5 ${'scans completed'.tr}',
                          showCheck: _dailyScans >= 5,
                        ),
                        const SizedBox(height: 15.0),
                        TaskColumn(
                          icon: Icons.blur_circular,
                          iconBackgroundColor: LightColors.kDarkYellow,
                          title: 'Analyze Weather'.tr,
                          subtitle: _weatherAnalyzed ? 'Completed'.tr : 'Not Started'.tr,
                          showCheck: _weatherAnalyzed,
                        ),
                        const SizedBox(height: 15.0),
                        TaskColumn(
                          icon: Icons.check_circle_outline,
                          iconBackgroundColor: LightColors.kBlue,
                          title: 'Upload to Admin'.tr,
                          subtitle: _adminUploaded ? 'Completed'.tr : 'Not Started'.tr,
                          showCheck: _adminUploaded,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        subheading('Others'),
                        const SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            ActiveProjectsCard(
                              cardColor: LightColors.kGreen,
                              icon: Icons.book,
                              title: 'Tutorial'.tr,
                              subtitle: 'How to use the app'.tr,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TutorialPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20.0),
                            ActiveProjectsCard(
                              cardColor: LightColors.kRed,
                              icon: Icons.eco,
                              title: 'How to Plant Rice'.tr,
                              subtitle: 'Guidance'.tr,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HowToPlantPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),                     
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}


