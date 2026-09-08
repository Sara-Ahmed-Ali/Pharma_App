import 'package:flutter/foundation.dart';

/// Shared controller for the MainShell bottom navigation tabs.
///
/// Lets child screens (cart, orders, ...) switch the shell's active tab,
/// e.g. returning to Home from an empty-cart state.
final ValueNotifier<int> mainTabIndex = ValueNotifier<int>(0);