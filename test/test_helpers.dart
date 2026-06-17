import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/extensions/string_extension.dart';

/// Matches [AppText] display strings after [StringExtension.softWrapWords].
Finder findDisplayText(String text) => find.text(text.softWrapWords());
