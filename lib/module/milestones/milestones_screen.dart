import 'package:flutter/material.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
      ),
      body: Stepper(
        currentStep: _index,
        onStepCancel: () {
          if (_index > 0) {
            setState(() {
              _index -= 1;
            });
          }
        },
        onStepContinue: () {
          if (_index <= 0) {
            setState(() {
              _index += 1;
            });
          }
        },
        onStepTapped: (int index) {
          setState(() {
            _index = index;
          });
        },
        steps: <Step>[
          _buildStep(
            title: 'Step 1 title',
            content: 'Content for Step 1',
          ),
          const Step(
            title: Text('Step 2 title'),
            content: Text('Content for Step 2'),
          ),
        ],
      ),
    );
  }

  Step _buildStep({
    required String title,
    required String content,
  }) {
    return Step(
      title: Text(title),
      content: Container(
        alignment: Alignment.centerLeft,
        child: Text(content),
      ),
    );
  }
}
