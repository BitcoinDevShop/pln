import 'package:flutter/material.dart';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              k,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          vw != null
              ? vw!
              : Flexible(
                  child: Text(
                    v!,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
        ],
      ),
    );
  }
}
