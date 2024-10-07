import 'package:flutter/material.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String? leaveType;
  TextEditingController usnController = TextEditingController();
  TextEditingController rollNoController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  DateTime? fromDate;
  DateTime? tillDate;
  TimeOfDay? fromTime;
  TimeOfDay? tillTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Request'),
        backgroundColor: Colors.blue, // Replace with your app's primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: usnController,
                decoration: InputDecoration(
                  labelText: 'USN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rollNoController,
                decoration: InputDecoration(
                  labelText: 'Roll No',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: leaveType,
                hint: Text('Select Leave Type'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'full-day', child: Text('Full Day Off')),
                  DropdownMenuItem(value: 'part-day', child: Text('Part Day Off')),
                  DropdownMenuItem(value: 'on-job', child: Text('On Job')),
                ],
                onChanged: (value) {
                  setState(() {
                    leaveType = value;
                  });
                },
              ),
              if (leaveType == 'full-day') ...[
                const SizedBox(height: 20),
                const Text('Full Day Leave Details'),
                ElevatedButton(
                  onPressed: () async {
                    fromDate = await selectDate(context);
                    if (fromDate != null) {
                      tillDate = await selectDate(context);
                    }
                    setState(() {});
                  },
                  child: Text('Select Leave Dates'),
                ),
                if (fromDate != null && tillDate != null)
                  Text('From: ${fromDate!.toLocal()} - Till: ${tillDate!.toLocal()}'),
              ] else if (leaveType == 'part-day') ...[
                const SizedBox(height: 20),
                const Text('Part Day Leave Details'),
                ElevatedButton(
                  onPressed: () async {
                    fromTime = await selectTime(context);
                    if (fromTime != null) {
                      tillTime = await selectTime(context);
                    }
                    setState(() {});
                  },
                  child: Text('Select Time'),
                ),
                if (fromTime != null && tillTime != null)
                  Text('From: ${fromTime!.format(context)} - Till: ${tillTime!.format(context)}'),
              ] else if (leaveType == 'on-job') ...[
                const SizedBox(height: 20),
                const Text('On Job Leave Details'),
                ElevatedButton(
                  onPressed: () async {
                    fromDate = await selectDate(context);
                    if (fromDate != null) {
                      tillDate = await selectDate(context);
                    }
                    setState(() {});
                  },
                  child: Text('Select On-Job Dates'),
                ),
                if (fromDate != null && tillDate != null)
                  Text('From: ${fromDate!.toLocal()} - Till: ${tillDate!.toLocal()}'),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate input and submit request
                  if (usnController.text.isEmpty ||
                      rollNoController.text.isEmpty ||
                      reasonController.text.isEmpty ||
                      leaveType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all required fields.')),
                    );
                    return;
                  }

                  // Handle submission logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Request submitted successfully!')),
                  );

                  // Clear fields after submission
                  usnController.clear();
                  rollNoController.clear();
                  reasonController.clear();
                  setState(() {
                    leaveType = null; // Reset leaveType
                    fromDate = null; // Reset dates
                    tillDate = null;
                    fromTime = null; // Reset times
                    tillTime = null;
                  });
                },
                child: Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
  }

  Future<TimeOfDay?> selectTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }
}
