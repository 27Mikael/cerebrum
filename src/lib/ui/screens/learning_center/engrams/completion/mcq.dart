import 'package:flutter/material.dart';
import 'package:cerebrum_app/models/engram_models.dart';
import 'package:cerebrum_app/api/learning_center_api.dart';

class McqCompletionPage extends StatefulWidget {
  final Engram engram;
  final String userId;

  const McqCompletionPage({
    super.key,
    required this.engram,
    required this.userId,
  });

  @override
  State<McqCompletionPage> createState() => _McqCompletionPageState();
}

class _McqCompletionPageState extends State<McqCompletionPage> {
  String? _selected;
  bool _submitting = false;
  Map<String, dynamic>? _result;

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _submitting = true);
    try {
      final result = await LearningCenterApi.submitMcq(
        engramId: widget.engram.id,
        userId: widget.userId,
        selectedOption: _selected!,
        targetCognitiveLevel: widget.engram.targetCognitiveLevel,
      );
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.engram.content as McqContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Choice')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.stem,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...c.options.entries.map((opt) {
              final isSelected = _selected == opt.key;
              return Card(
                color: isSelected ? Colors.blue.shade50 : null,
                child: ListTile(
                  leading: CircleAvatar(child: Text(opt.key)),
                  title: Text(opt.value),
                  selected: isSelected,
                  onTap:
                      _result == null
                          ? () => setState(() => _selected = opt.key)
                          : null,
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_result == null)
              ElevatedButton(
                onPressed: _selected == null || _submitting ? null : _submit,
                child:
                    _submitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Submit'),
              )
            else
              Card(
                color:
                    (_result!['is_correct'] as bool)
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_result!['is_correct'] as bool)
                            ? 'Correct!'
                            : 'Not quite.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Mastery: ${_result!['mastery_state']}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
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
