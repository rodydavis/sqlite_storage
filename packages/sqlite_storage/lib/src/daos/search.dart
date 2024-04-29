import 'package:drift/drift.dart';

import '../database.dart';

part 'search.g.dart';

@DriftAccessor(include: {'../sql/search.drift'})
class SearchDao extends DatabaseAccessor<DriftStorage> with _$SearchDaoMixin {
  SearchDao(super.db);

  Selectable<SearchIndexData> searchLike(
    String val, {
    bool anyPrefix = true,
    bool anySuffix = true,
  }) {
    String q = val;
    if (anyPrefix) q = '%$q';
    if (anySuffix) q = '$q%';
    return _searchValueLike(q);
  }

  Selectable<SearchValueFtsResult> searchFts(String val) {
    return _searchValueFts(val);
  }
}
