import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/castings_provider.dart';
import '../models/casting.dart';
import '../widgets/app_layout.dart';

class CastingDebugPage extends StatefulWidget {
  const CastingDebugPage({super.key});

  @override
  State<CastingDebugPage> createState() => _CastingDebugPageState();
}

class _CastingDebugPageState extends State<CastingDebugPage> {
  String _debugOutput = '';

  @override
  void initState() {
    super.initState();
    _runDebugTests();
  }

  Future<void> _runDebugTests() async {
    setState(() {
      _debugOutput = 'Starting debug tests...\n';
    });

    try {
      // Test 1: Load castings
      _addDebugLine('Test 1: Loading castings...');
      final provider = context.read<CastingsProvider>();
      await provider.loadCastings();
      _addDebugLine('Loaded ${provider.castings.length} castings');
      
      // Test 2: Create a test casting
      _addDebugLine('\nTest 2: Creating test casting...');
      final testData = {
        'title': 'Debug Test Casting',
        'description': 'This is a test casting created for debugging',
        'date': DateTime.now().toIso8601String(),
        'location': 'Test Location',
        'status': 'pending',
        'requirements': 'Test requirements',
        'rate': 100.0,
        'currency': 'USD',
        'images': [],
      };
      
      final success = await provider.createCasting(testData);
      _addDebugLine('Create casting result: $success');
      
      if (success) {
        _addDebugLine('Reloading castings after creation...');
        await provider.loadCastings();
        _addDebugLine('Now have ${provider.castings.length} castings');
      }
      
      // Test 3: Direct service test
      _addDebugLine('\nTest 3: Direct service test...');
      final directCastings = await Casting.list();
      _addDebugLine('Direct service returned ${directCastings.length} castings');
      
      _addDebugLine('\nDebug tests completed!');
      
    } catch (e) {
      _addDebugLine('Error during debug tests: $e');
    }
  }

  void _addDebugLine(String line) {
    setState(() {
      _debugOutput += '$line\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/casting-debug',
      title: 'Casting Debug',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _runDebugTests,
                  child: const Text('Run Tests'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _debugOutput = '';
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugOutput,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
