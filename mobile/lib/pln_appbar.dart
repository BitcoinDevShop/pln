import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mutiny/widgets/background_button.dart';

class PlnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function()? backAction;
  final void Function()? closeAction;
  final bool home;
  final Color accentColor;

  const PlnAppBar(
      {Key? key,
      required this.title,
      this.backAction,
      this.closeAction,
      this.home = false,
      required this.accentColor})
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
                  child: Image.asset("images/mutiny_logo.png", height: 25),
                )
              : Container(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 2.0, color: accentColor),
                    ),
                  ),
                  child:
                      Text(title, style: Theme.of(context).textTheme.headline1),
                ),
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
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BackgroundButton(
                    accentColor: accentColor,
                    onPressed: closeAction,
                    child: Image.asset(
                      height: 21,
                      width: 21,
                      "images/ex.png",
                      filterQuality: FilterQuality.none,
                    ),
                  ))
              : const SizedBox(
                  width: 24,
                ),
        ],
      ),
    );
  }
}
