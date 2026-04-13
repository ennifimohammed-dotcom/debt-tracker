import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/debt.dart';

enum SortMode { dateDesc, amountDesc, name }

class DebtProvider extends ChangeNotifier {
  List<Debt>         _all     = [];
  Map<String,double> _summary = {};
  bool               _loading = false;
  String             _search  = '';
  String             _statusF = 'all';
  String             _dirF    = 'all';
  SortMode           _sort    = SortMode.dateDesc;

  List<Debt>         get all     => _all;
  Map<String,double> get summary => _summary;
  bool               get loading => _loading;
  String             get search  => _search;
  String             get statusF => _statusF;
  String             get dirF    => _dirF;
  SortMode           get sort    => _sort;

  List<Debt> get filtered {
    var list = List<Debt>.from(_all);
    if (_search.isNotEmpty)
      list = list.where((d) =>
        d.personName.toLowerCase().contains(_search.toLowerCase()) ||
        (d.notes?.toLowerCase().contains(_search.toLowerCase()) ?? false)).toList();
    if (_statusF != 'all') {
      final s = DebtStatus.values.firstWhere((e) => e.name == _statusF);
      list = list.where((d) => d.status == s).toList();
    }
    if (_dirF != 'all') {
      final dir = DebtDirection.values.firstWhere((e) => e.name == _dirF);
      list = list.where((d) => d.direction == dir).toList();
    }
    switch (_sort) {
      case SortMode.dateDesc:   list.sort((a, b) => b.date.compareTo(a.date));             break;
      case SortMode.amountDesc: list.sort((a, b) => b.amount.compareTo(a.amount));         break;
      case SortMode.name:       list.sort((a, b) => a.personName.compareTo(b.personName)); break;
    }
    return list;
  }

  void setSearch(String v)  { _search  = v; notifyListeners(); }
  void setStatusF(String v) { _statusF = v; notifyListeners(); }
  void setDirF(String v)    { _dirF    = v; notifyListeners(); }
  void setSort(SortMode v)  { _sort    = v; notifyListeners(); }

  Future<void> load() async {
    _loading = true; notifyListeners();
    _all     = await DbHelper.i.all();
    _summary = await DbHelper.i.summary();
    _loading = false; notifyListeners();
  }

  Future<void> add(Debt d)    async { await DbHelper.i.insert(d); await load(); }
  Future<void> edit(Debt d)   async { await DbHelper.i.update(d); await load(); }
  Future<void> remove(int id) async { await DbHelper.i.delete(id); await load(); }
}
