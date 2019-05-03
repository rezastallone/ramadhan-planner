import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taskist/quran/events/change_language_event.dart';
import 'package:taskist/quran/helpers/my_event_bus.dart';
import 'package:taskist/quran/helpers/shimmer_helpers.dart';
import 'package:taskist/quran/models/chapters_models.dart';
import 'package:taskist/quran/models/quran_data_model.dart';
import 'package:taskist/quran/screens/quran_juz_screen.dart';
import 'package:taskist/quran/screens/quran_sura_screen.dart';
import 'package:taskist/quran/services/quran_data_services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'dart:math' as math;

class QuranListScreen extends StatefulWidget {
  final int currentTabIndex;

  QuranListScreen({
    @required this.currentTabIndex,
  });

  @override
  State<StatefulWidget> createState() {
    return _QuranListScreenState();
  }
}

class _QuranListScreenState extends State<QuranListScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> listWidgets;

  StreamSubscription changeLocaleSubsciption;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listWidgets = [
      QuranSuraScreen(),
      QuranJuzScreen(),
    ];

    return listWidgets[widget.currentTabIndex];
  }
}
