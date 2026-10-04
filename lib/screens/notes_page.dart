import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NotesPage extends StatefulWidget {
  final bool darkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  const NotesPage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  bool loading = true;
  String? error;
  final searchCtrl = TextEditingController();
  String sort = 'date_desc';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final list = await ApiService.fetchNotes(
        search: searchCtrl.text.trim(),
        sort: sort,
      );
      setState(() { notes = list; loading = false; });
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('UNAUTHORIZED')) {
        widget.onLogout();
        return;
      }
      setState(() {
        error = 'Сервер не отвечает.\nПроверьте, что uvicorn запущен.';
        loading = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  void _showDialog({Note? note}) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final textCtrl = TextEditingController(text: note?.text ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'Новая заметка' : 'Редактировать'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Текст',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final t = textCtrl.text.trim();
              final ti = titleCtrl.text.trim();
              if (t.isEmpty && ti.isEmpty) return;
              Navigator.pop(context);
              try {
                if (note == null) {
                  await ApiService.createNote(ti.isEmpty ? 'Без названия' : ti, t);
                  _snack('Заметка создана');
                } else {
                  await ApiService.updateNote(note.id,
                      title: ti.isEmpty ? 'Без названия' : ti, text: t);
                  _snack('Заметка обновлена');
                }
                _load();
              } catch (e) { _snack('Ошибка: $e'); }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Note n) async {
    try {
      await ApiService.deleteNote(n.id);
      _snack('Заметка удалена');
      _load();
    } catch (e) { _snack('Ошибка: $e'); }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Сортировка',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final e in {
              'date_desc': 'Сначала новые',
              'date_asc': 'Сначала старые',
              'alpha_asc': 'А → Я',
              'alpha_desc': 'Я → А',
            }.entries)
              RadioListTile<String>(
                value: e.key,
                groupValue: sort,
                title: Text(e.value),
                onChanged: (v) {
                  Navigator.pop(context);
                  setState(() => sort = v!);
                  _load();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        actions: [
          IconButton(
            tooltip: widget.darkMode ? 'Светлая тема' : 'Тёмная тема',
            icon: Icon(widget.darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: 'Сортировка',
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Выйти?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
                  ],
                ),
              );
              if (ok == true) widget.onLogout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Поиск по заголовку и тексту...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { searchCtrl.clear(); _load(); })
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? _errorView()
                    : notes.isEmpty
                        ? const Center(child: Text('Ничего не найдено'))
                        : ListView.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, i) => _noteTile(notes[i]),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );

  Widget _noteTile(Note n) => Dismissible(
        key: ValueKey(n.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Удалить?'),
                  content: Text(n.title),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => _delete(n),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(child: Text('${n.id}')),
            title: Text(n.title.isEmpty ? 'Без названия' : n.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (n.text.isNotEmpty)
                  Text(n.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(n.createdAt.toLocal()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showDialog(note: n),
            ),
          ),
        ),
      );
}