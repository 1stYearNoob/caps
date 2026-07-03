import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../data/my_data.dart';
import '../../services/auth_service.dart';
import '../../services/roboflow_service.dart';
import '../../services/translation_service.dart';
import '../../theme/colors/light_colors.dart';
import '../scan_result_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedDate = 'All';
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('scan_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> history = [];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        Timestamp? ts = data['timestamp'] as Timestamp?;
        DateTime date = ts != null ? ts.toDate() : DateTime.now();
        
        bool isHealthy = data['isHealthy'] ?? false;
        bool isNotDetected = data['diseaseName'] == 'Not Detected';
        
        Color severityColor = isNotDetected ? Colors.grey : (isHealthy ? LightColors.kGreen : LightColors.kRed);
        String severity = isNotDetected ? 'Unknown' : (isHealthy ? 'Healthy' : 'Disease');

        history.add({
          'dateHeader': DateFormat('MMMM d, yyyy').format(date),
          'time': DateFormat('h:mm a').format(date),
          'diseaseName': data['diseaseName'] ?? 'Unknown',
          'confidence': ((data['confidence'] ?? 0.0) * 100).toStringAsFixed(1),
          'isHealthy': isHealthy,
          'severityColor': severityColor,
          'severity': severity,
          'imagePath': data['imagePath'] as String?,
        });
      }
      if (mounted) {
        setState(() {
          _scanHistory = history;
          _isLoading = false;
        });
      }
    });
  }

  Map<String, List<Map<String, dynamic>>> getGroupedHistory() {
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var scan in _scanHistory) {
      String header = scan['dateHeader'];
      if (!groupedData.containsKey(header)) {
        groupedData[header] = [];
      }
      groupedData[header]!.add(scan);
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    final allGroupedHistory = getGroupedHistory();
    final List<String> availableDates = ['All', ...allGroupedHistory.keys.toList()];

    // Apply Active Filter to calculate dynamic stats
    final filteredHistory = _selectedDate == 'All' 
        ? allGroupedHistory 
        : { _selectedDate: allGroupedHistory[_selectedDate]! };

    int totalScans = 0;
    int healthyScans = 0;

    for (var dateGroup in filteredHistory.values) {
      totalScans += dateGroup.length;
      for (var scan in dateGroup) {
        if (scan['isHealthy'] == true) {
          healthyScans++;
        }
      }
    }
    
    int diseaseScans = totalScans - healthyScans;

    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              decoration: const BoxDecoration(
                color: LightColors.kDarkYellow,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan History'.tr,
                    style: const TextStyle(
                      color: LightColors.kDarkBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _selectedDate == 'All' 
                        ? 'Your overall field analyses overview.'.tr
                        : '${'Analysis overview for'.tr} $_selectedDate.',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Dynamic Statistics Cards Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Total Scans'.tr, totalScans.toString(), Icons.analytics, LightColors.kDarkBlue),
                      _buildStatCard('Healthy'.tr, healthyScans.toString(), Icons.check_circle, LightColors.kGreen),
                      _buildStatCard('Issues Found'.tr, diseaseScans.toString(), Icons.warning_rounded, LightColors.kRed),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Timeline'.tr,
                    style: const TextStyle(
                      color: LightColors.kDarkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Dropdown Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDate,
                        icon: const Icon(Icons.arrow_drop_down, color: LightColors.kDarkBlue),
                        style: const TextStyle(
                          color: LightColors.kDarkBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedDate = newValue;
                            });
                          }
                        },
                        items: availableDates.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredHistory.isEmpty
                      ? Center(
                          child: Text(
                            'No scan history found.'.tr,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          children: filteredHistory.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text Header for the Date Group
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: LightColors.kDarkBlue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  // Build the History Cards that fall under this date
                                  ...entry.value.map((scan) => _buildHistoryCard(scan)).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color iconColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 5),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
              color: LightColors.kDarkBlue,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.tr,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> scan) {
    bool isHealthy = scan['isHealthy'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: () {
            double confValue = 0.0;
            try {
              confValue = (double.tryParse(scan['confidence']) ?? 0.0) / 100.0;
            } catch (_) {}

            final topDetection = Detection(
              0, // x
              0, // y
              0, // width
              0, // height
              confValue,
              scan['diseaseName'],
            );

            File? imgFile;
            if (scan['imagePath'] != null) {
              imgFile = File(scan['imagePath']);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResultPage(
                  image: imgFile,
                  detections: [topDetection],
                  isFromHistory: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // Image/Icon Placeholder for the scanned leaf
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: isHealthy ? LightColors.kGreen.withOpacity(0.1) : LightColors.kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (scan['imagePath'] != null && File(scan['imagePath']).existsSync())
                      ? Image.file(
                          File(scan['imagePath']),
                          fit: BoxFit.cover,
                          width: 65,
                          height: 65,
                        )
                      : Icon(
                          isHealthy ? Icons.eco : Icons.coronavirus,
                          color: isHealthy ? LightColors.kGreen : LightColors.kRed,
                          size: 30.0,
                        ),
                ),
                const SizedBox(width: 15.0),
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan['diseaseName'].toString().tr,
                        style: const TextStyle(
                          color: LightColors.kDarkBlue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled, size: 14, color: Colors.black54),
                          const SizedBox(width: 5),
                          Text(
                            scan['time'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: scan['severityColor'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              scan['severity'].toString().tr,
                              style: TextStyle(
                                color: scan['severityColor'],
                                fontWeight: FontWeight.w700,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${'Confidence'.tr}: ${scan['confidence']}%',
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}
