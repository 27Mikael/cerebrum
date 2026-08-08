import 'package:flutter/material.dart';
import 'package:cerebrum_app/models/engram_models.dart';
import 'package:cerebrum_app/api/learning_center_api.dart';

class ShortQuestionCompletionPage extends StatefulWidget {
  final Engram engram;
  final String userId;

  const ShortQuestionCompletionPage({
    super.key,
    required this.engram,
    required this.userId,
  });

  @override
  State<ShortQuestionCompletionPage> createState() =>
      _ShortQuestionCompletionPageState();
}

class _ShortQuestionCompletionPageState
    extends State<ShortQuestionCompletionPage> {
  final Map<int, TextEditingController> _controllers = {};
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int questionNumber) {
    return _controllers.putIfAbsent(
      questionNumber,
      () => TextEditingController(),
    );
  }

  Future<void> _submit(List<ShortQuestionItem> questions) async {
    setState(() => _submitting = true);
    try {
      final responses =
          questions.map((q) {
            return {
              'question_id': q.questionNumber.toString(),
              'raw_answer': _controllerFor(q.questionNumber).text,
            };
          }).toList();

      await LearningCenterApi.submitShortQuestion(
        engramId: widget.engram.id,
        userId: widget.userId,
        responses: responses,
        targetCognitiveLevel: widget.engram.targetCognitiveLevel,
      );
      setState(() => _submitted = true);
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
    final c = widget.engram.content as ShortQuestionContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Short Questions')),
      body:
          _submitted
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text('Submitted!'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ...c.questions.map((q) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.stem,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (q.hint != null && q.hint!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Hint: ${q.hint}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controllerFor(q.questionNumber),
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Your answer...',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  ElevatedButton(
                    onPressed: _submitting ? null : () => _submit(c.questions),
                    child:
                        _submitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Submit All'),
                  ),
                ],
              ),
    );
  }
}
