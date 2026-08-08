import 'package:flutter/material.dart';
import 'package:cerebrum_app/models/engram_models.dart';
import 'package:cerebrum_app/api/learning_center_api.dart';

class LongQuestionCompletionPage extends StatefulWidget {
  final Engram engram;
  final String userId;

  const LongQuestionCompletionPage({
    super.key,
    required this.engram,
    required this.userId,
  });

  @override
  State<LongQuestionCompletionPage> createState() =>
      _LongQuestionCompletionPageState();
}

class _LongQuestionCompletionPageState
    extends State<LongQuestionCompletionPage> {
  final _controller = TextEditingController();
  bool _submitting = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      final result = await LearningCenterApi.submitLongQuestion(
        engramId: widget.engram.id,
        userId: widget.userId,
        rawAnswer: _controller.text,
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
    final c = widget.engram.content as LongQuestionContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Long Question')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            c.questionStem,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...c.parts.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('(${p.part}) ${p.question}  [${p.marks} marks]'),
            ),
          ),
          const SizedBox(height: 16),
          if (_result == null) ...[
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your full answer here...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child:
                  _submitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Submit for grading'),
            ),
          ] else
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submitted — grading in progress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Job ID: ${_result!['job_id']}'),
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
    );
  }
}
