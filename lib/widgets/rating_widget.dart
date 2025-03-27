import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final bool isInteractive;

  const RatingWidget({
    Key? key,
    this.initialRating = 0.0,
    required this.onRatingChanged,
    this.isInteractive = true,
  }) : super(key: key);

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.isInteractive
              ? () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                  widget.onRatingChanged(_rating);
                }
              : null,
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
        );
      }),
    );
  }
}
