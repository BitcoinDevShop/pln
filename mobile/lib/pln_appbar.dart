import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'constants.dart';

class PlnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function()? backAction;
  final void Function()? closeAction;
  final bool home;

  const PlnAppBar(
      {Key? key,
      required this.title,
      this.backAction,
      this.closeAction,
      this.home = false})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.symmetric(vertical: 24.0),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          home
              ? GestureDetector(
                  onTap: () => context.go("/welcome"),
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(color: blue)),
                )
              : Text(title, style: Theme.of(context).textTheme.headline1),
          backAction != null
              ? InkWell(
                  onTap: backAction,
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                    size: 24.0,
                    semanticLabel: 'Back',
                  ))
              : const SizedBox(
                  width: 24,
                ),
          closeAction != null
              ? InkWell(
                  onTap: closeAction,
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                    size: 24.0,
                    semanticLabel: 'Close',
                  ),
                )
              : const SizedBox(
                  width: 24,
                ),
        ],
      ),
    );
  }
}
