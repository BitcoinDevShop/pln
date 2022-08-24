import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class KeyValue extends StatelessWidget {
  final String k;
  final String? v;
  final Widget? vw;

  const KeyValue({Key? key, required this.k, this.v, this.vw})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6.0)),
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: () => v != null ? Clipboard.setData(ClipboardData(text: v)) : {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              k,
              style: Theme.of(context).textTheme.headline5,
            ),
            vw != null
                ? vw!
                : Text(
                    v!,
                  ),
          ],
        ),
      ),
    );
  }
}
