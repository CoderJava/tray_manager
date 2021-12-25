import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:tray_manager/tray_manager.dart';

const _kIconTypeDefault = 'default';
const _kIconTypeOriginal = 'original';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  String _iconType = _kIconTypeOriginal;
  var _counter = 0;

  Timer? _timer;

  @override
  void initState() {
    TrayManager.instance.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    TrayManager.instance.removeListener(this);
    super.dispose();
  }

  void _handleSetIcon(String iconType, String title) async {
    _iconType = iconType;
    String iconPath = Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png';

    if (_iconType == 'original') {
      iconPath = Platform.isWindows ? 'images/tray_icon_original.ico' : 'images/tray_icon_original.png';
    }

    await TrayManager.instance.setIcon(iconPath, title: title);
  }

  void _startIconFlashing() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _counter += 1;
      var tempCounter = _counter;
      var hour = 0;
      var minute = 0;
      var second = 0;
      if (tempCounter >= 3600) {
        hour = tempCounter ~/ 3600;
        tempCounter = tempCounter % 3600;
      }
      if (tempCounter >= 60) {
        minute = tempCounter ~/ 60;
        tempCounter = tempCounter % 60;
      }
      second = tempCounter;
      final strHour = hour.toString().padLeft(2, '0');
      final strMinute = minute.toString().padLeft(2, '0');
      final strSecond = second.toString().padLeft(2, '0');
      final title = '$strHour:$strMinute:$strSecond';
      _handleSetIcon(
        _iconType == _kIconTypeOriginal ? _kIconTypeDefault : _kIconTypeOriginal,
        title,
      );
    });
    setState(() {});
  }

  void _stopIconFlashing() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('destroy'),
              onTap: () {
                TrayManager.instance.destroy();
              },
            ),
            PreferenceListItem(
              title: Text('setIcon'),
              accessoryView: Row(
                children: [
                  Builder(builder: (_) {
                    bool isFlashing = (_timer != null && _timer!.isActive);
                    return CupertinoButton(
                      child: isFlashing ? Text('stop flash') : Text('start flash'),
                      onPressed: isFlashing ? _stopIconFlashing : _startIconFlashing,
                    );
                  }),
                  /*CupertinoButton(
                    child: Text('Default'),
                    onPressed: () => _handleSetIcon(_kIconTypeDefault),
                  ),
                  CupertinoButton(
                    child: Text('Original'),
                    onPressed: () => _handleSetIcon(_kIconTypeOriginal),
                  ),*/
                ],
              ),
              // onTap: () => _handleSetIcon(_kIconTypeDefault),
            ),
            // PreferenceListItem(
            //   title: Text('setToolTip'),
            //   onTap: () async {
            //     await TrayManager.instance.setToolTip('tray_manager');
            //   },
            // ),
            PreferenceListItem(
              title: Text('setContextMenu'),
              onTap: () async {
                List<MenuItem> items = [
                  MenuItem(title: 'Undo'),
                  MenuItem(title: 'Redo'),
                  MenuItem.separator,
                  MenuItem(title: 'Cut'),
                  MenuItem(title: 'Copy'),
                  MenuItem(
                    title: 'Copy As',
                    items: [
                      MenuItem(title: 'Copy Remote File Url'),
                      MenuItem(title: 'Copy Remote File Url From...'),
                    ],
                  ),
                  MenuItem(title: 'Paste'),
                  MenuItem.separator,
                  MenuItem(title: 'Find', isEnabled: false),
                  MenuItem(title: 'Replace'),
                ];
                await TrayManager.instance.setContextMenu(items);
              },
            ),
            PreferenceListItem(
              title: Text('popUpContextMenu'),
              onTap: () async {
                await TrayManager.instance.popUpContextMenu();
              },
            ),
            PreferenceListItem(
              title: Text('getBounds'),
              onTap: () async {
                Rect bounds = await TrayManager.instance.getBounds();
                Size size = bounds.size;
                Offset origin = bounds.topLeft;
                BotToast.showText(
                  text: '${size.toString()}\n${origin.toString()}',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onTrayIconMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    print(TrayManager.instance.getBounds());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    print(menuItem.toJson());
    BotToast.showText(
      text: '${menuItem.toJson()}',
    );
  }
}
