import 'package:flutter/material.dart';
import 'package:cerebrum_app/models/engram_models.dart';
import 'package:cerebrum_app/api/learning_center_api.dart';

class FlashcardCompletionPage extends StatefulWidget {
  final Engram engram;
  final String userId;

  const FlashcardCompletionPage({
    super.key,
    required this.engram,
    required this.userId,
  });

  @override
  State<FlashcardCompletionPage> createState() =>
      _FlashcardCompletionPageState();
}

class _FlashcardCompletionPageState extends State<FlashcardCompletionPage> {
  bool _flipped = false;
  bool _submitting = false;
  String? _ratedAs;

  Future<void> _rate(String rating) async {
    setState(() => _submitting = true);
    try {
      await LearningCenterApi.submitFlashcard(
        engramId: widget.engram.id,
        userId: widget.userId,
        selfRating: rating,
        targetCognitiveLevel: widget.engram.targetCognitiveLevel,
      );
      setState(() => _ratedAs = rating);
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
    final c = widget.engram.content as FlashcardContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap:
                  _ratedAs == null
                      ? () => setState(() => _flipped = !_flipped)
                      : null,
              child: Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _flipped ? Colors.indigo.shade50 : Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Text(
                    _flipped ? c.back : c.front,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_flipped)
              const Text(
                'Tap the card to reveal the answer',
                style: TextStyle(color: Colors.black54),
              ),
            const SizedBox(height: 24),
            if (_flipped && _ratedAs == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _rateButton('again', Colors.red, _submitting, _rate),
                  _rateButton('hard', Colors.orange, _submitting, _rate),
                  _rateButton('good', Colors.blue, _submitting, _rate),
                  _rateButton('easy', Colors.green, _submitting, _rate),
                ],
              ),
            if (_ratedAs != null) ...[
              Text(
                'Rated: $_ratedAs',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rateButton(
    String label,
    Color color,
    bool disabled,
    Future<void> Function(String) onRate,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: disabled ? null : () => onRate(label),
      child: Text(label),
    );
  }
}
