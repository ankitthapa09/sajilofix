// import 'package:flutter/material.dart';

// class ReportScreen extends StatefulWidget {
//   const ReportScreen({super.key});

//   @override
//   State<ReportScreen> createState() => _ReportScreenState();
// }

// class _ReportScreenState extends State<ReportScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Report Issue'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Progress Bar
//             LinearProgressIndicator(
//               value: currentStep / totalSteps,
//             ),
//             SizedBox(height: 20),
//             // Step Indicator
//             Text(
//               'Step $currentStep of $totalSteps',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             // Issue Category Selection
//             Text(
//               "What's the issue?",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               children: [
//                 _buildCategoryButton('Roads & Potholes', Icons.directions_car),
//                 _buildCategoryButton('Electricity', Icons.bolt),
//                 _buildCategoryButton('Water Supply', Icons.water),
//                 _buildCategoryButton('Waste Management', Icons.delete),
//                 _buildCategoryButton('Street Lights', Icons.lightbulb),
//                 _buildCategoryButton('Public Infrastructure', Icons.apartment),
//                 _buildCategoryButton('Other', Icons.note),
//               ],
//             ),
//             Spacer(),
//             // Continue and Back Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Back'),
//                 ),
//                 ElevatedButton(
//                   onPressed: nextStep,
//                   child: Text('Continue'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
