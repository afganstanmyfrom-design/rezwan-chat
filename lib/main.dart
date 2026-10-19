import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

final lang = ValueNotifier<String>('en');
final dark = ValueNotifier<bool>(false);
SupabaseClient get sb => Supabase.instance.client;
String get me => sb.auth.currentUser!.id;

const S = {
  'en': {
    'email': 'Email', 'pass': 'Password', 'login': 'Log in', 'signup': 'Sign up',
    'toSignup': "Don't have an account? Sign up", 'toLogin': 'Have an account? Log in',
    'checkEmail': 'Check your email (and Spam) and tap the confirmation link, then log in.',
    'setup': 'Create your profile', 'username': 'Unique ID (a-z, 0-9, _)', 'name': 'Display name',
    'save': 'Save', 'taken': 'This ID is already taken or invalid', 'search': 'Search by ID',
    'add': 'Add', 'added': 'Added to contacts', 'notfound': 'No user found', 'msg': 'Message',
    'chats': 'Chats', 'settings': 'Settings', 'language': 'Language', 'dark': 'Dark mode',
    'about': 'About', 'logout': 'Log out', 'empty': 'No contacts yet. Tap the search icon and add someone by ID.',
    'dev': 'About the Developer', 'edu': '1st Semester, Computer Science Student',
    'desc': 'Rezvan Chat is a simple, fast and private messaging app built as a student project, where people connect using a unique ID instead of a phone number.',
    'error': 'Something went wrong',
    'tabChats': 'Chats', 'tabCalls': 'Calls', 'tabUpdates': 'Updates', 'callsSoon': 'Calls are coming soon', 'soon': 'Coming soon',
    'newGroup': 'New group', 'find': 'Search...', 'noUpdates': 'No updates from your contacts yet', 'recent': 'Recent updates',
    'block': 'Block', 'unblock': 'Unblock', 'blockedMsg': 'Blocked. Unblock this contact in their profile to send messages.',
    'bio': 'About', 'blockedList': 'Blocked contacts', 'noBlocked': 'No blocked contacts', 'readReceipts': 'Read receipts',
    'showSeen': 'Show online and last seen', 'clearCache': 'Clear saved chats', 'cleared': 'Cleared',
    'edit': 'Edit', 'edited': 'edited', 'forward': 'Forward', 'forwarded': 'Forwarded', 'star': 'Star', 'unstar': 'Unstar', 'cancel': 'Cancel',
    'starredMsgs': 'Starred messages', 'noStarred': 'No starred messages yet', 'addChat': 'Add and chat',
    'typing': 'typing...', 'online': 'online', 'lastSeen': 'last seen', 'deleted': 'This message was deleted',
    'reply': 'Reply', 'del': 'Delete for everyone', 'photo': 'Photo', 'voice': 'Voice message',
    'myStory': 'My story', 'editProfile': 'Edit profile', 'help': 'How to use', 'saved': 'Saved',
    'profile': 'Profile', 'removeContact': 'Remove contact',
    'features': 'Features: text, photo and voice messages, reactions, replies, read ticks, online status, typing indicator, photo stories, Persian and English, dark mode.',
    'helpText': '1. Sign up with your email and password.\n\n2. Choose a unique ID, a name and a photo.\n\n3. Tap the add-person icon, search your friend ID and add them.\n\n4. Open the chat and send text, photos or voice (tap the mic to start, tap again to send).\n\n5. Long-press a message to react, reply or delete it.\n\n6. Tap the name at the top of a chat to see the profile.\n\n7. Stories: tap your circle to view, long-press it to add a photo (lasts 24 hours).',
  },
  'fa': {
    'email': 'ایمیل', 'pass': 'رمز عبور', 'login': 'ورود', 'signup': 'ثبت‌نام',
    'toSignup': 'حساب ندارید؟ ثبت‌نام', 'toLogin': 'حساب دارید؟ ورود',
    'checkEmail': 'ایمیل خود (و Spam) را بررسی کنید، روی لینک تأیید بزنید و سپس وارد شوید.',
    'setup': 'ساخت پروفایل', 'username': 'آیدی یکتا (a-z، 0-9، _)', 'name': 'نام نمایشی',
    'save': 'ذخیره', 'taken': 'این آیدی قبلاً گرفته شده یا نامعتبر است', 'search': 'جستجو با آیدی',
    'add': 'افزودن', 'added': 'به مخاطبین اضافه شد', 'notfound': 'کاربری پیدا نشد', 'msg': 'پیام',
    'chats': 'چت‌ها', 'settings': 'تنظیمات', 'language': 'زبان', 'dark': 'حالت تاریک',
    'about': 'درباره', 'logout': 'خروج', 'empty': 'هنوز مخاطبی ندارید. روی آیکون جستجو بزنید و با آیدی کسی را اضافه کنید.',
    'dev': 'درباره سازنده', 'edu': 'سمستر اول، محصل کمپیوتر ساینس',
    'desc': 'رضوان چت یک پیام‌رسان ساده، سریع و خصوصی است که به عنوان پروژه محصلی ساخته شده و کاربران با آیدی یکتا (به جای شماره تلفن) با هم ارتباط می‌گیرند.',
    'error': 'مشکلی پیش آمد',
    'tabChats': 'گفتگوها', 'tabCalls': 'تماس‌ها', 'tabUpdates': 'بروزرسانی‌ها', 'callsSoon': 'تماس‌ها به‌زودی اضافه می‌شوند', 'soon': 'به‌زودی',
    'newGroup': 'گروه جدید', 'find': 'جستجو...', 'noUpdates': 'هنوز بروزرسانی‌ای از مخاطبین نیست', 'recent': 'بروزرسانی‌های اخیر',
    'block': 'مسدود کردن', 'unblock': 'رفع مسدودی', 'blockedMsg': 'مسدود است. برای ارسال پیام، از پروفایل او رفع مسدودی کنید.',
    'bio': 'درباره', 'blockedList': 'مخاطبین مسدود', 'noBlocked': 'مخاطب مسدودی ندارید', 'readReceipts': 'تیک خوانده‌شدن',
    'showSeen': 'نمایش آنلاین و آخرین بازدید', 'clearCache': 'پاک کردن چت‌های ذخیره‌شده', 'cleared': 'پاک شد',
    'edit': 'ویرایش', 'edited': 'ویرایش‌شده', 'forward': 'فوروارد', 'forwarded': 'فوروارد شد', 'star': 'ستاره‌دار کردن', 'unstar': 'حذف ستاره', 'cancel': 'لغو',
    'starredMsgs': 'پیام‌های ذخیره‌شده', 'noStarred': 'هنوز پیام ستاره‌داری نیست', 'addChat': 'افزودن و گفتگو',
    'typing': 'در حال نوشتن...', 'online': 'آنلاین', 'lastSeen': 'آخرین بازدید', 'deleted': 'این پیام حذف شد',
    'reply': 'پاسخ', 'del': 'حذف برای همه', 'photo': 'عکس', 'voice': 'پیام صوتی',
    'myStory': 'استوری من', 'editProfile': 'ویرایش پروفایل', 'help': 'راهنمای استفاده', 'saved': 'ذخیره شد',
    'profile': 'پروفایل', 'removeContact': 'حذف مخاطب',
    'features': 'امکانات: پیام متنی، عکس و صوتی، ریاکشن، پاسخ، تیک خوانده‌شدن، آنلاین، در حال نوشتن، استوری عکس، فارسی و انگلیسی، حالت تاریک.',
    'helpText': '۱. با ایمیل و رمز ثبت‌نام کنید.\n\n۲. یک آیدی یکتا، اسم و عکس انتخاب کنید.\n\n۳. روی آیکون افزودن مخاطب بزنید، آیدی دوستتان را جستجو و اضافه کنید.\n\n۴. چت را باز کنید و متن، عکس یا صدا بفرستید (میکروفون را یک بار بزنید تا ضبط شروع شود و دوباره بزنید تا ارسال شود).\n\n۵. روی پیام نگه دارید تا ریاکشن بدهید، پاسخ دهید یا حذف کنید.\n\n۶. روی اسم بالای چت بزنید تا پروفایل را ببینید.\n\n۷. استوری: روی دایره خودتان بزنید تا ببینید، نگه دارید تا عکس اضافه کنید (۲۴ ساعت می‌ماند).',
  }
};
String t(String k) => S[lang.value]![k] ?? k;

Future<String> upload(File f, String ext) async {
  final path = '$me/${DateTime.now().millisecondsSinceEpoch}.$ext';
  await sb.storage.from('media').upload(path, f);
  return sb.storage.from('media').getPublicUrl(path);
}

void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    ErrorWidget.builder = (d) => Material(child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: SelectableText(d.toString()))));
    try {
      await boot();
      runApp(const App());
    } catch (e, st) {
      runApp(MaterialApp(home: Scaffold(body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: SelectableText('STARTUP ERROR:\n$e\n\n$st'))))));
    }
  }, (e, st) {});
}

Future<void> boot() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  prefs = await SharedPreferences.getInstance();
  final p = prefs;
  lang.value = p.getString('lang') ?? 'en';
  dark.value = p.getBool('dark') ?? false;
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: lang,
        builder: (_, __, ___) => ValueListenableBuilder(
          valueListenable: dark,
          builder: (_, d, __) => MaterialApp(
            title: 'Rezvan Chat',
            debugShowCheckedModeBanner: false,
            themeMode: d ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
            darkTheme: ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.dark, useMaterial3: true),
            builder: (c, w) => Directionality(
                textDirection: lang.value == 'fa' ? TextDirection.rtl : TextDirection.ltr, child: w!),
            home: StreamBuilder<AuthState>(
              stream: sb.auth.onAuthStateChange,
              builder: (_, __) => sb.auth.currentSession == null ? const AuthPage() : const Gate(),
            ),
          ),
        ),
      );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final e = TextEditingController(), p = TextEditingController();
  bool signup = false, busy = false;
  Future<void> go() async {
    setState(() => busy = true);
    try {
      if (signup) {
        await sb.auth.signUp(email: e.text.trim(), password: p.text);
        if (mounted) { toast(context, t('checkEmail')); setState(() => signup = false); }
      } else {
        await sb.auth.signInWithPassword(email: e.text.trim(), password: p.text);
      }
    } on AuthException catch (x) {
      if (mounted) toast(context, x.message);
    } catch (_) {
      if (mounted) toast(context, t('error'));
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(actions: [
          TextButton(
              onPressed: () => setLang(lang.value == 'en' ? 'fa' : 'en'),
              child: Text(lang.value == 'en' ? 'فارسی' : 'English'))
        ]),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Icon(Icons.chat_bubble, size: 80, color: Colors.teal),
              const Text('Rezvan Chat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: e, keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: t('email'), border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: p, obscureText: true,
                  decoration: InputDecoration(labelText: t('pass'), border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                  child: FilledButton(onPressed: busy ? null : go, child: Text(t(signup ? 'signup' : 'login')))),
              TextButton(onPressed: () => setState(() => signup = !signup),
                  child: Text(t(signup ? 'toLogin' : 'toSignup'))),
            ]),
          ),
        ),
      );
}

Future<void> setLang(String l) async {
  lang.value = l;
  (await SharedPreferences.getInstance()).setString('lang', l);
}

class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  late Future<Map<String, dynamic>?> f = load();
  Future<Map<String, dynamic>?> load() => sb.from('profiles').select().eq('id', me).maybeSingle();
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: f,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (s.data == null) return SetupPage(onDone: () => setState(() => f = load()));
          return const Home();
        },
      );
}

class SetupPage extends StatefulWidget {
  final VoidCallback onDone;
  const SetupPage({super.key, required this.onDone});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final u = TextEditingController(), n = TextEditingController();
  File? img;
  bool busy = false;
  Future<void> pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (x != null) setState(() => img = File(x.path));
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      final url = img == null ? null : await upload(img!, 'jpg');
      await sb.from('profiles').insert({
        'id': me, 'username': u.text.trim().toLowerCase(), 'display_name': n.text.trim(), 'avatar_url': url});
      widget.onDone();
    } catch (_) {
      if (mounted) toast(context, t('taken'));
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('setup')), actions: [
          IconButton(onPressed: () => sb.auth.signOut(), icon: const Icon(Icons.logout))]),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: GestureDetector(onTap: pick,
              child: CircleAvatar(radius: 56, backgroundImage: img == null ? null : FileImage(img!),
                  child: img == null ? const Icon(Icons.add_a_photo, size: 36) : null))),
          const SizedBox(height: 20),
          TextField(controller: u, decoration: InputDecoration(labelText: t('username'), prefixText: '@', border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: n, decoration: InputDecoration(labelText: t('name'), border: const OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: busy ? null : save, child: Text(t('save'))),
        ]),
      );
}

Widget avatar(Map p, {double r = 22}) => CircleAvatar(radius: r,
    backgroundImage: p['avatar_url'] == null ? null : NetworkImage(p['avatar_url']),
    child: p['avatar_url'] == null ? Text((p['display_name'] as String)[0].toUpperCase()) : null);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final q = TextEditingController();
  Map<String, dynamic>? r;
  bool done = false;
  Future<void> find() async {
    final x = await sb.from('profiles').select().eq('username', q.text.trim().toLowerCase().replaceAll('@', '')).maybeSingle();
    setState(() { r = x; done = true; });
  }

  Future<void> add() async {
    await sb.from('contacts').upsert({'owner': me, 'contact': r!['id']});
    if (mounted) toast(context, t('added'));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('search'))),
        body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(controller: q, onSubmitted: (_) => find(),
              decoration: InputDecoration(prefixText: '@', border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: find))),
          const SizedBox(height: 16),
          if (r != null && r!['id'] != me)
            ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserPreviewPage(user: r!))), leading: avatar(r!), title: Text(r!['display_name']), subtitle: Text('@${r!['username']}'),
                trailing: FilledButton(onPressed: add, child: Text(t('add'))))
          else if (done) Text(t('notfound')),
        ])),
      );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('about'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Icon(Icons.chat_bubble, size: 72, color: Colors.teal),
          const Center(child: Text('Rezvan Chat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
          const Center(child: Text('Version 1.0')),
          const SizedBox(height: 16),
          Text(t('desc')), const SizedBox(height: 12), Text(t('features')),
          const Divider(height: 40),
          Text(t('dev'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Mohammad Ibrahim Rezvan'),
          Text(t('edu')),
          const Text('Aria Private University'),
          const Text('2026'),
        ]),
      );
}

String hm(String s) { final d = DateTime.parse(s).toLocal(); return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'; }
String preview(Map m) {
  if (m['deleted'] == true) return t('deleted');
  if (m['type'] == 'image') return '📷 ${t('photo')}';
  if (m['type'] == 'audio') return '🎤 ${t('voice')}';
  return m['body'];
}
bool isOnline(Map p) => p['last_seen'] != null && DateTime.now().difference(DateTime.parse(p['last_seen'])) < const Duration(seconds: 70);

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final people = <String, Map<String, dynamic>>{};
  final contactIds = <String>{};
  final loading = <String>{};
  List<Map<String, dynamic>> stories = [];
  Timer? timer;
  int tab = 0;
  bool searching = false;
  String q = '';
  late final Stream<List<Map<String, dynamic>>> ms = sb.from('messages').stream(primaryKey: ['id']).order('created_at', ascending: false);
  @override
  void initState() { super.initState(); for (final x in cachedList(ck('home_people'))) { people[x['id']] = x; if (x['id'] != me) contactIds.add(x['id']); } beat(); timer = Timer.periodic(const Duration(seconds: 30), (_) => beat()); load(); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> beat() async { if (!(prefs.getBool('seen') ?? true)) return; try { await sb.from('profiles').update({'last_seen': DateTime.now().toUtc().toIso8601String()}).eq('id', me); } catch (_) {} }
  Future<void> getPeople(Iterable<String> ids) async {
    final need = ids.where((i) => !people.containsKey(i) && !loading.contains(i)).toList();
    if (need.isEmpty) return;
    loading.addAll(need);
    try {
      final r = await sb.from('profiles').select().inFilter('id', need);
      for (final p in r) { people[p['id']] = Map<String, dynamic>.from(p); }
      prefs.setString(ck('home_people'), jsonEncode(people.values.toList()));
      if (mounted) setState(() {});
    } catch (_) {}
  }
  Future<void> load() async {
    try {
      final c = await sb.from('contacts').select('contact').eq('owner', me);
      contactIds.addAll(c.map((e) => e['contact'] as String));
      final s = await sb.from('stories').select().order('created_at');
      stories = List<Map<String, dynamic>>.from(s);
      await getPeople([me, ...contactIds]);
      if (mounted) setState(() {});
    } catch (_) {}
  }
  Future<void> addStory() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1280);
    if (x == null) return;
    try { await sb.from('stories').insert({'owner': me, 'url': await upload(File(x.path), 'jpg')}); await load(); }
    catch (_) { if (mounted) toast(context, t('error')); }
  }
  Widget storyItem(String id, String name, List<Map<String, dynamic>>? list, {bool mine = false}) => GestureDetector(
        onTap: () {
          if (list != null && list.isNotEmpty) { Navigator.push(context, MaterialPageRoute(builder: (_) => StoryView(list: list, name: name, onChanged: load))); }
          else if (mine) { addStory(); }
        },
        onLongPress: mine ? addStory : null,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Column(children: [
          Container(padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: list == null ? Colors.grey : Colors.teal, width: 2.5)),
              child: avatar(people[id] ?? {'display_name': '?'}, r: 26)),
          const SizedBox(height: 4),
          SizedBox(width: 64, child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
        ])),
      );
  Widget storiesBar() {
    final by = <String, List<Map<String, dynamic>>>{};
    for (final s in stories) { final o = s['owner'] as String; if (o == me || contactIds.contains(o)) by.putIfAbsent(o, () => []).add(s); }
    final mine = by.remove(me);
    return SizedBox(height: 92, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
      storyItem(me, t('myStory'), mine, mine: true),
      for (final e in by.entries) if (people[e.key] != null) storyItem(e.key, people[e.key]!['display_name'], e.value),
    ]));
  }

  Map<String, List<Map<String, dynamic>>> grouped() {
    final by = <String, List<Map<String, dynamic>>>{};
    for (final s in stories) { final o = s['owner'] as String; if (o == me || contactIds.contains(o)) by.putIfAbsent(o, () => []).add(s); }
    return by;
  }

  void menu(String v) {
    if (v == 'group') toast(context, t('soon'));
    if (v == 'starred') Navigator.push(context, MaterialPageRoute(builder: (_) => const StarredPage()));
    if (v == 'settings') Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
    if (v == 'help') Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
    if (v == 'about') Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
    if (v == 'logout') sb.auth.signOut();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: ms,
        initialData: cachedList(ck('home_msgs')),
        builder: (c, s) {
          final all = s.data ?? <Map<String, dynamic>>[];
          prefs.setString(ck('home_msgs'), jsonEncode(all.take(300).toList()));
          final last = <String, Map<String, dynamic>>{};
          final unread = <String, int>{};
          for (final m in all) {
            final peer = (m['sender'] == me ? m['receiver'] : m['sender']) as String;
            last.putIfAbsent(peer, () => m);
            if (m['receiver'] == me && m['read'] != true) unread[peer] = (unread[peer] ?? 0) + 1;
          }
          final total = unread.values.fold<int>(0, (a, b) => a + b);
          contactIds.addAll(last.keys);
          getPeople(contactIds);
          final pins = (prefs.getStringList(ck('pins')) ?? <String>[]).toSet();
          final ids = contactIds.where((i) => people.containsKey(i) && i != me && (q.isEmpty ||
                  people[i]!['display_name'].toString().toLowerCase().contains(q.toLowerCase()) ||
                  people[i]!['username'].toString().contains(q.toLowerCase()))).toList()
            ..sort((a, b) {
              final pa = pins.contains(a) ? 1 : 0, pb = pins.contains(b) ? 1 : 0;
              if (pa != pb) return pb - pa;
              return (last[b]?['created_at'] ?? '').toString().compareTo((last[a]?['created_at'] ?? '').toString());
            });
          final by = grouped();
          Widget body;
          if (tab == 0) {
            body = RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              if (ids.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Text(t('empty'), textAlign: TextAlign.center)),
              for (final id in ids)
                ListTile(
                  leading: avatar(people[id]!),
                  title: Row(children: [Expanded(child: Text(people[id]!['display_name'])), if (pins.contains(id)) const Icon(Icons.push_pin, size: 14)]),
                  subtitle: Text(last[id] == null ? '@${people[id]!['username']}' : preview(last[id]!), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: (unread[id] ?? 0) > 0 ? FontWeight.bold : FontWeight.normal)),
                  trailing: last[id] == null ? null : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(hm(last[id]!['created_at']), style: const TextStyle(fontSize: 11)),
                    if ((unread[id] ?? 0) > 0) Badge(label: Text('${unread[id]}')),
                  ]),
                  onLongPress: () async { final l2 = pins.toList(); if (!l2.remove(id)) l2.add(id); await prefs.setStringList(ck('pins'), l2); setState(() {}); },
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(peer: people[id]!))),
                ),
            ]));
          } else if (tab == 1) {
            body = Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.call, size: 64, color: Colors.grey), const SizedBox(height: 12), Text(t('callsSoon'))]));
          } else {
            final others = by.entries.where((e) => e.key != me && people[e.key] != null).toList();
            body = RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              storiesBar(),
              const Divider(),
              Padding(padding: const EdgeInsets.all(12), child: Text(t('recent'), style: const TextStyle(fontWeight: FontWeight.bold))),
              if (others.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(t('noUpdates'), textAlign: TextAlign.center)),
              for (final e in others)
                ListTile(leading: avatar(people[e.key]!), title: Text(people[e.key]!['display_name']), subtitle: Text(hm(e.value.last['created_at'])),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryView(list: e.value, name: people[e.key]!['display_name'], onChanged: load)))),
            ]));
          }
          final titles = [t('tabChats'), t('tabCalls'), t('tabUpdates')];
          return Scaffold(
            appBar: AppBar(
              title: searching && tab == 0
                  ? TextField(autofocus: true, decoration: InputDecoration(hintText: t('find'), border: InputBorder.none), onChanged: (v) => setState(() => q = v))
                  : Text(titles[tab]),
              actions: [
                if (tab == 0) IconButton(icon: Icon(searching ? Icons.close : Icons.search), onPressed: () => setState(() { searching = !searching; q = ''; })),
                if (tab == 0) IconButton(icon: const Icon(Icons.person_add), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())); load(); }),
                PopupMenuButton<String>(onSelected: menu, itemBuilder: (_) => [
                  PopupMenuItem(value: 'group', child: Text(t('newGroup'))),
                  PopupMenuItem(value: 'starred', child: Text(t('starredMsgs'))),
                  PopupMenuItem(value: 'settings', child: Text(t('settings'))),
                  PopupMenuItem(value: 'help', child: Text(t('help'))),
                  PopupMenuItem(value: 'about', child: Text(t('about'))),
                  PopupMenuItem(value: 'logout', child: Text(t('logout'))),
                ]),
              ],
            ),
            body: body,
            bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: [
              NavigationDestination(icon: Badge(isLabelVisible: total > 0, label: Text('$total'), child: const Icon(Icons.chat)), label: titles[0]),
              NavigationDestination(icon: const Icon(Icons.call), label: titles[1]),
              NavigationDestination(icon: const Icon(Icons.donut_large), label: titles[2]),
            ]),
          );
        },
      );
}

class StoryView extends StatefulWidget {
  final List<Map<String, dynamic>> list;
  final String name;
  final VoidCallback onChanged;
  const StoryView({super.key, required this.list, required this.name, required this.onChanged});
  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  int i = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white,
            title: Text('${widget.name}  ${i + 1}/${widget.list.length}  ${hm(widget.list[i]['created_at'])}'),
            actions: [
              if (widget.list[i]['owner'] == me)
                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                  await sb.from('stories').delete().eq('id', widget.list[i]['id']);
                  widget.onChanged();
                  if (context.mounted) Navigator.pop(context);
                })
            ]),
        body: GestureDetector(
            onTap: () { if (i < widget.list.length - 1) { setState(() => i++); } else { Navigator.pop(context); } },
            child: Center(child: Image.network(widget.list[i]['url']))),
      );
}

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> peer;
  const ChatPage({super.key, required this.peer});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final c = TextEditingController();
  final rec = AudioRecorder();
  bool recording = false;
  bool blocked = false;
  List<Map<String, dynamic>> pend = [];
  Timer? rt;
  Map<String, dynamic>? replyTo;
  final marked = <int>{};
  final typing = ValueNotifier<bool>(false);
  Timer? tt;
  DateTime lastType = DateTime(2000);
  late final RealtimeChannel ch;
  String get pid => widget.peer['id'];
  late final Stream<List<Map<String, dynamic>>> st = sb.from('messages').stream(primaryKey: ['id']).order('created_at', ascending: false);
  late final Stream<List<Map<String, dynamic>>> rs = sb.from('reactions').stream(primaryKey: ['message_id', 'user_id']);
  late final Stream<List<Map<String, dynamic>>> ps = sb.from('profiles').stream(primaryKey: ['id']).eq('id', pid);

  @override
  void initState() {
    super.initState();
    loadBlock();
    loadStars();
    pend = cachedList(ck('pend_$pid'));
    rt = Timer.periodic(const Duration(seconds: 8), (_) => flush());
    final ids = [me, pid]..sort();
    ch = sb.channel('typing_${ids.join('_')}')
      ..onBroadcast(event: 'typing', callback: (p) {
        final d = p['payload'] is Map ? p['payload'] : p;
        if (d['from'] == pid) {
          typing.value = true;
          tt?.cancel();
          tt = Timer(const Duration(seconds: 3), () => typing.value = false);
        }
      })
      ..subscribe();
  }

  @override
  void dispose() { rt?.cancel(); tt?.cancel(); sb.removeChannel(ch); rec.dispose(); super.dispose(); }

  void ping() {
    if (DateTime.now().difference(lastType) < const Duration(seconds: 2)) return;
    lastType = DateTime.now();
    try { ch.sendBroadcastMessage(event: 'typing', payload: {'from': me}); } catch (_) {}
  }

  Set<int> starred = {};
  Future<void> loadStars() async {
    try { final r = await sb.from('stars').select('message_id').eq('user_id', me); if (mounted) setState(() => starred = r.map<int>((e) => e['message_id'] as int).toSet()); } catch (_) {}
  }
  Future<void> toggleStar(Map m) async {
    final id = m['id'] as int;
    try {
      if (starred.contains(id)) { await sb.from('stars').delete().eq('user_id', me).eq('message_id', id); starred.remove(id); }
      else { await sb.from('stars').insert({'user_id': me, 'message_id': id}); starred.add(id); }
      if (mounted) setState(() {});
    } catch (_) {}
  }
  Future<void> editMsg(Map m) async {
    final ctl = TextEditingController(text: m['body']);
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(content: TextField(controller: ctl, maxLines: 4), actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('cancel'))),
      TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t('save')))]));
    if (ok == true && ctl.text.trim().isNotEmpty) {
      try { await sb.from('messages').update({'body': ctl.text.trim(), 'edited': true}).eq('id', m['id']); } catch (_) { if (mounted) toast(context, t('error')); }
    }
  }
  Future<void> forward(Map m) async {
    try {
      final c = await sb.from('contacts').select('contact').eq('owner', me);
      final ids = c.map((e) => e['contact']).toList();
      if (ids.isEmpty) return;
      final ps = List<Map<String, dynamic>>.from(await sb.from('profiles').select().inFilter('id', ids));
      if (!mounted) return;
      final to = await showModalBottomSheet<Map<String, dynamic>>(context: context, builder: (_) => ListView(children: [
        for (final p in ps) ListTile(leading: avatar(p), title: Text(p['display_name']), onTap: () => Navigator.pop(context, p))]));
      if (to == null) return;
      await sb.from('messages').insert({'sender': me, 'receiver': to['id'], 'type': m['type'], 'body': m['body']});
      if (mounted) toast(context, t('forwarded'));
    } catch (_) { if (mounted) toast(context, t('error')); }
  }
  Future<void> loadBlock() async {
    try { final r = await sb.from('blocks').select().eq('blocker', me).eq('blocked', pid); if (mounted) setState(() => blocked = r.isNotEmpty); } catch (_) {}
  }
  void savePend() => prefs.setString(ck('pend_$pid'), jsonEncode(pend));
  Future<void> flush() async {
    for (final p in List<Map<String, dynamic>>.from(pend)) {
      try {
        await sb.from('messages').insert({'sender': me, 'receiver': pid, 'type': 'text', 'body': p['body']});
        pend.remove(p); savePend(); if (mounted) setState(() {});
      } catch (_) { break; }
    }
  }
  Future<void> send(String type, String body) async {
    if (blocked) { if (mounted) toast(context, t('blockedMsg')); return; }
    final r = replyTo;
    setState(() => replyTo = null);
    try {
      await sb.from('messages').insert({'sender': me, 'receiver': pid, 'type': type, 'body': body, if (r != null) 'reply_to': r['id']});
    } catch (_) {
      if (type == 'text') { pend.add({'body': body, 'created_at': DateTime.now().toUtc().toIso8601String()}); savePend(); if (mounted) setState(() {}); }
      else if (mounted) { toast(context, t('error')); }
    }
  }

  Future<void> sendText() async { final s = c.text.trim(); if (s.isEmpty) return; c.clear(); await send('text', s); }

  Future<void> sendImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1280);
    if (x == null) return;
    try { await send('image', await upload(File(x.path), 'jpg')); } catch (_) { if (mounted) toast(context, t('error')); }
  }

  Future<void> toggleRec() async {
    try {
      if (!recording) {
        if (!await rec.hasPermission()) return;
        final d = await getTemporaryDirectory();
        await rec.start(const RecordConfig(), path: '${d.path}/v${DateTime.now().millisecondsSinceEpoch}.m4a');
        setState(() => recording = true);
      } else {
        final p = await rec.stop();
        setState(() => recording = false);
        if (p != null) await send('audio', await upload(File(p), 'm4a'));
      }
    } catch (_) { setState(() => recording = false); if (mounted) toast(context, t('error')); }
  }

  void markRead(List<Map<String, dynamic>> l) {
    if (!(prefs.getBool('rr') ?? true)) return;
    final ids = l.where((m) => m['receiver'] == me && m['read'] != true && !marked.contains(m['id'])).map((m) => m['id'] as int).toList();
    if (ids.isEmpty) return;
    marked.addAll(ids);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try { await sb.from('messages').update({'read': true}).inFilter('id', ids); } catch (_) {}
    });
  }

  Future<void> react(Map m, String e, List<Map<String, dynamic>> rx) async {
    try {
      final mine = rx.where((r) => r['user_id'] == me).toList();
      if (mine.isNotEmpty && mine.first['emoji'] == e) {
        await sb.from('reactions').delete().eq('message_id', m['id']).eq('user_id', me);
      } else {
        await sb.from('reactions').upsert({'message_id': m['id'], 'user_id': me, 'emoji': e});
      }
    } catch (_) {}
  }

  void actions(Map<String, dynamic> m, List<Map<String, dynamic>> rx) {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (final e in ['👍', '❤️', '😂', '😮', '😢', '🙏'])
              GestureDetector(onTap: () { Navigator.pop(context); react(m, e, rx); }, child: Text(e, style: const TextStyle(fontSize: 30))),
          ])),
          ListTile(leading: const Icon(Icons.reply), title: Text(t('reply')), onTap: () { Navigator.pop(context); setState(() => replyTo = m); }),
          if (m['deleted'] != true) ListTile(leading: const Icon(Icons.forward), title: Text(t('forward')), onTap: () { Navigator.pop(context); forward(m); }),
          if (m['deleted'] != true) ListTile(leading: Icon(starred.contains(m['id']) ? Icons.star : Icons.star_border), title: Text(t(starred.contains(m['id']) ? 'unstar' : 'star')), onTap: () { Navigator.pop(context); toggleStar(m); }),
          if (m['sender'] == me && m['type'] == 'text' && m['deleted'] != true) ListTile(leading: const Icon(Icons.edit), title: Text(t('edit')), onTap: () { Navigator.pop(context); editMsg(m); }),
          if (m['sender'] == me && m['deleted'] != true)
            ListTile(leading: const Icon(Icons.delete), title: Text(t('del')), onTap: () async {
              Navigator.pop(context);
              await sb.from('messages').update({'deleted': true, 'body': ''}).eq('id', m['id']);
            }),
        ])));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(peer: widget.peer))); loadBlock(); },
            child: Row(children: [
              avatar(widget.peer, r: 18),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.peer['display_name'], style: const TextStyle(fontSize: 17), overflow: TextOverflow.ellipsis),
                StreamBuilder<List<Map<String, dynamic>>>(stream: ps, builder: (_, s) {
                  final p = (s.data?.isNotEmpty ?? false) ? s.data!.first : widget.peer;
                  return ValueListenableBuilder<bool>(valueListenable: typing, builder: (_, ty, __) => Text(
                      ty ? t('typing') : isOnline(p) ? t('online') : (p['last_seen'] == null ? '' : '${t('lastSeen')} ${hm(p['last_seen'])}'),
                      style: const TextStyle(fontSize: 12)));
                }),
              ])),
            ]),
          ),
        ),
        body: CustomPaint(painter: ChatBg(Theme.of(context).brightness == Brightness.dark), child: Column(children: [
          Expanded(child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: st,
            initialData: cachedList(ck('chat_$pid')),
            builder: (_, s) {
              final l = (s.data ?? <Map<String, dynamic>>[]).where((m) => (m['sender'] == me && m['receiver'] == pid) || (m['sender'] == pid && m['receiver'] == me)).toList();
              markRead(l);
              prefs.setString(ck('chat_$pid'), jsonEncode(l));
              return StreamBuilder<List<Map<String, dynamic>>>(stream: rs, builder: (_, r) {
                final rx = r.data ?? <Map<String, dynamic>>[];
                return ListView.builder(reverse: true, padding: const EdgeInsets.all(8), itemCount: l.length + pend.length, itemBuilder: (_, i) {
                  if (i < pend.length) { return Bubble(m: {...pend[pend.length - 1 - i], 'sender': me, 'type': 'text', 'pending': true}, mine: true, reactions: const [], reply: null); }
                  final m = l[i - pend.length];
                  final mr = rx.where((e) => e['message_id'] == m['id']).toList();
                  final rep = m['reply_to'] == null ? null : l.cast<Map<String, dynamic>?>().firstWhere((e) => e!['id'] == m['reply_to'], orElse: () => null);
                  return GestureDetector(onLongPress: () => actions(m, mr), onHorizontalDragEnd: (_) => setState(() => replyTo = m),
                      child: Bubble(m: m, mine: m['sender'] == me, reactions: mr, reply: rep));
                });
              });
            },
          )),
          if (blocked) Container(width: double.infinity, color: Colors.red.withOpacity(0.1), padding: const EdgeInsets.all(10), child: Text(t('blockedMsg'), textAlign: TextAlign.center)),
          if (replyTo != null)
            Container(color: Colors.black12, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
              const Icon(Icons.reply, size: 18), const SizedBox(width: 8),
              Expanded(child: Text(preview(replyTo!), maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => replyTo = null)),
            ])),
          SafeArea(child: Padding(padding: const EdgeInsets.all(6), child: Row(children: [
            IconButton(icon: const Icon(Icons.image), onPressed: sendImage),
            Expanded(child: TextField(controller: c, minLines: 1, maxLines: 4, onChanged: (_) => ping(),
                decoration: InputDecoration(hintText: t('msg'), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)))))),
            IconButton(icon: Icon(recording ? Icons.stop_circle : Icons.mic, color: recording ? Colors.red : null), onPressed: toggleRec),
            IconButton(icon: const Icon(Icons.send), onPressed: sendText),
          ]))),
        ])),
      );
}

class Bubble extends StatelessWidget {
  final Map<String, dynamic> m;
  final bool mine;
  final List<Map<String, dynamic>> reactions;
  final Map<String, dynamic>? reply;
  const Bubble({super.key, required this.m, required this.mine, required this.reactions, this.reply});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget w;
    if (m['deleted'] == true) {
      w = Text(t('deleted'), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
    } else if (m['type'] == 'image') {
      w = ClipRRect(borderRadius: BorderRadius.circular(8), child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: Center(child: InteractiveViewer(child: Image.network(m['body'])))))),
          child: Image.network(m['body'], width: 220)));
    } else if (m['type'] == 'audio') {
      w = AudioBubble(url: m['body']);
    } else {
      w = Text(m['body']);
    }
    final read = m['read'] == true;
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(color: mine ? cs.primaryContainer : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          if (reply != null)
            Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
                child: Text(preview(reply!), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
          w,
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (m['edited'] == true) Text('${t('edited')} ', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
            Text(hm(m['created_at']), style: const TextStyle(fontSize: 10)),
            if (mine) Padding(padding: const EdgeInsetsDirectional.only(start: 4), child: Icon(m['pending'] == true ? Icons.access_time : (read ? Icons.done_all : Icons.done), size: 14, color: read ? Colors.blue : Colors.grey)),
          ]),
          if (reactions.isNotEmpty) Text(reactions.map((e) => e['emoji']).join(' ')),
        ]),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('help'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [Text(t('helpText'), style: const TextStyle(fontSize: 16, height: 1.6))]),
      );
}


late SharedPreferences prefs;
List<Map<String, dynamic>> cachedList(String k) =>
    ((jsonDecode(prefs.getString(k) ?? '[]')) as List).map((e) => Map<String, dynamic>.from(e)).toList();

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> peer;
  const ProfilePage({super.key, required this.peer});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool blocked = false;
  Map<String, dynamic> p = {};
  @override
  void initState() { super.initState(); p = widget.peer; init(); }
  Future<void> init() async {
    try {
      final r = await sb.from('blocks').select().eq('blocker', me).eq('blocked', p['id']);
      final f = await sb.from('profiles').select().eq('id', p['id']).single();
      if (mounted) setState(() { blocked = r.isNotEmpty; p = f; });
    } catch (_) {}
  }
  Future<void> toggleBlock() async {
    try {
      if (blocked) { await sb.from('blocks').delete().eq('blocker', me).eq('blocked', p['id']); }
      else { await sb.from('blocks').insert({'blocker': me, 'blocked': p['id']}); }
      setState(() => blocked = !blocked);
    } catch (_) { if (mounted) toast(context, t('error')); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('profile'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: GestureDetector(
              onTap: p['avatar_url'] == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: Center(child: InteractiveViewer(child: Image.network(p['avatar_url'])))))),
              child: avatar(p, r: 70))),
          const SizedBox(height: 16),
          Center(child: Text(p['display_name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          Center(child: Text('@${p['username']}')),
          Center(child: Text(isOnline(p) ? t('online') : (p['last_seen'] == null ? '' : '${t('lastSeen')} ${hm(p['last_seen'])}'), style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          Card(child: ListTile(title: Text(t('bio'), style: const TextStyle(fontSize: 12, color: Colors.grey)), subtitle: Text((p['bio'] ?? '').toString().isEmpty ? '-' : p['bio'], style: const TextStyle(fontSize: 16)))),
          const SizedBox(height: 8),
          ListTile(leading: Icon(blocked ? Icons.lock_open : Icons.block, color: Colors.red), title: Text(t(blocked ? 'unblock' : 'block'), style: const TextStyle(color: Colors.red)), onTap: toggleBlock),
          ListTile(leading: const Icon(Icons.person_remove, color: Colors.red), title: Text(t('removeContact'), style: const TextStyle(color: Colors.red)), onTap: () async {
            await sb.from('contacts').delete().eq('owner', me).eq('contact', p['id']);
            if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
          }),
        ]),
      );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: lang,
        builder: (_, __, ___) => Scaffold(
          appBar: AppBar(title: Text(t('settings'))),
          body: ListView(children: [
            ListTile(leading: const Icon(Icons.person), title: Text(t('editProfile')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()))),
            ListTile(leading: const Icon(Icons.language), title: Text(t('language')),
                trailing: DropdownButton<String>(value: lang.value, underline: const SizedBox(),
                    items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'fa', child: Text('فارسی'))],
                    onChanged: (v) => setLang(v!))),
            SwitchListTile(secondary: const Icon(Icons.dark_mode), title: Text(t('dark')), value: dark.value,
                onChanged: (v) async { dark.value = v; await prefs.setBool('dark', v); setState(() {}); }),
            const Divider(),
            SwitchListTile(secondary: const Icon(Icons.done_all), title: Text(t('readReceipts')), value: prefs.getBool('rr') ?? true,
                onChanged: (v) async { await prefs.setBool('rr', v); setState(() {}); }),
            SwitchListTile(secondary: const Icon(Icons.visibility), title: Text(t('showSeen')), value: prefs.getBool('seen') ?? true,
                onChanged: (v) async { await prefs.setBool('seen', v); setState(() {}); }),
            ListTile(leading: const Icon(Icons.block), title: Text(t('blockedList')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockedPage()))),
            ListTile(leading: const Icon(Icons.cleaning_services), title: Text(t('clearCache')), onTap: () async {
              for (final k in prefs.getKeys().where((k) => k.contains('chat_') || k.contains('home_') || k.contains('pend_')).toList()) { await prefs.remove(k); }
              if (context.mounted) toast(context, t('cleared'));
            }),
            const Divider(),
            ListTile(leading: const Icon(Icons.help), title: Text(t('help')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()))),
            ListTile(leading: const Icon(Icons.info), title: Text(t('about')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
            ListTile(leading: const Icon(Icons.logout), title: Text(t('logout')), onTap: () { Navigator.popUntil(context, (r) => r.isFirst); sb.auth.signOut(); }),
          ]),
        ),
      );
}

class BlockedPage extends StatefulWidget {
  const BlockedPage({super.key});
  @override
  State<BlockedPage> createState() => _BlockedPageState();
}

class _BlockedPageState extends State<BlockedPage> {
  List<Map<String, dynamic>>? l;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      final b = await sb.from('blocks').select('blocked').eq('blocker', me);
      final ids = b.map((e) => e['blocked']).toList();
      final r = ids.isEmpty ? [] : await sb.from('profiles').select().inFilter('id', ids);
      if (mounted) setState(() => l = List<Map<String, dynamic>>.from(r));
    } catch (_) { if (mounted) setState(() => l = []); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('blockedList'))),
        body: l == null ? const Center(child: CircularProgressIndicator()) : l!.isEmpty ? Center(child: Text(t('noBlocked'))) : ListView(children: [
          for (final p in l!) ListTile(leading: avatar(p), title: Text(p['display_name']), subtitle: Text('@${p['username']}'),
              trailing: TextButton(child: Text(t('unblock')), onPressed: () async { await sb.from('blocks').delete().eq('blocker', me).eq('blocked', p['id']); load(); }))
        ]),
      );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final n = TextEditingController(), b = TextEditingController();
  File? img;
  String? cur;
  @override
  void initState() {
    super.initState();
    sb.from('profiles').select().eq('id', me).single().then((p) { n.text = p['display_name']; b.text = p['bio'] ?? ''; if (mounted) setState(() => cur = p['avatar_url']); });
  }
  Future<void> pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (x != null) setState(() => img = File(x.path));
  }
  Future<void> save() async {
    try {
      final u = img == null ? cur : await upload(img!, 'jpg');
      await sb.from('profiles').update({'display_name': n.text.trim(), 'bio': b.text.trim(), 'avatar_url': u}).eq('id', me);
      if (mounted) { toast(context, t('saved')); Navigator.pop(context); }
    } catch (_) { if (mounted) toast(context, t('error')); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('editProfile'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: GestureDetector(onTap: pick, child: CircleAvatar(radius: 56,
              backgroundImage: img != null ? FileImage(img!) : (cur != null ? NetworkImage(cur!) as ImageProvider : null),
              child: (img == null && cur == null) ? const Icon(Icons.add_a_photo, size: 36) : null))),
          const SizedBox(height: 20),
          TextField(controller: n, decoration: InputDecoration(labelText: t('name'), border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: b, maxLength: 120, decoration: InputDecoration(labelText: t('bio'), border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          FilledButton(onPressed: save, child: Text(t('save'))),
        ]),
      );
}

String ck(String k) => '${sb.auth.currentUser?.id ?? 'x'}_$k';

class AudioBubble extends StatefulWidget {
  final String url;
  const AudioBubble({super.key, required this.url});
  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final pl = AudioPlayer();
  bool playing = false;
  double speed = 1;
  String get pk => 'ap_${widget.url.hashCode}';
  @override
  void initState() {
    super.initState();
    pl.onPlayerComplete.listen((_) { prefs.setInt(pk, 0); if (mounted) setState(() => playing = false); });
  }
  @override
  void dispose() { pl.dispose(); super.dispose(); }
  Future<void> toggle() async {
    if (playing) {
      final p = await pl.getCurrentPosition();
      await prefs.setInt(pk, p?.inMilliseconds ?? 0);
      await pl.pause();
    } else {
      await pl.setPlaybackRate(speed);
      await pl.play(UrlSource(widget.url), position: Duration(milliseconds: prefs.getInt(pk) ?? 0));
    }
    setState(() => playing = !playing);
  }
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: Icon(playing ? Icons.pause_circle : Icons.play_circle, size: 36), onPressed: toggle),
        const Icon(Icons.graphic_eq),
        TextButton(
            onPressed: () { setState(() => speed = speed == 1 ? 1.5 : (speed == 1.5 ? 2 : 1)); pl.setPlaybackRate(speed); },
            child: Text('${speed == 1 ? '1' : speed}x')),
      ]);
}

class ChatBg extends CustomPainter {
  final bool dark;
  ChatBg(this.dark);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = (dark ? Colors.white : Colors.teal).withOpacity(dark ? 0.05 : 0.08)..style = PaintingStyle.stroke..strokeWidth = 1.6;
    const g = 56.0;
    int i = 0;
    for (double y = 20; y < s.height; y += g) {
      for (double x = 20 + (i.isOdd ? g / 2 : 0); x < s.width; x += g) {
        final k = ((x ~/ g) + i) % 4;
        final o = Offset(x, y);
        if (k == 0) { c.drawCircle(o, 7, p); }
        else if (k == 1) { c.drawRect(Rect.fromCenter(center: o, width: 14, height: 11), p); }
        else if (k == 2) { c.drawLine(o.translate(-7, 0), o.translate(7, 0), p); c.drawLine(o.translate(0, -7), o.translate(0, 7), p); }
        else { c.drawPath(Path()..moveTo(o.dx - 7, o.dy + 6)..lineTo(o.dx, o.dy - 7)..lineTo(o.dx + 7, o.dy + 6)..close(), p); }
      }
      i++;
    }
  }
  @override
  bool shouldRepaint(ChatBg o) => o.dark != dark;
}

class UserPreviewPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserPreviewPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('profile'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: GestureDetector(
              onTap: user['avatar_url'] == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: Center(child: InteractiveViewer(child: Image.network(user['avatar_url'])))))),
              child: avatar(user, r: 70))),
          const SizedBox(height: 16),
          Center(child: Text(user['display_name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          Center(child: Text('@${user['username']}')),
          const SizedBox(height: 16),
          Card(child: ListTile(title: Text(t('bio'), style: const TextStyle(fontSize: 12, color: Colors.grey)), subtitle: Text((user['bio'] ?? '').toString().isEmpty ? '-' : user['bio']))),
          const SizedBox(height: 16),
          FilledButton.icon(icon: const Icon(Icons.chat), label: Text(t('addChat')), onPressed: () async {
            try {
              await sb.from('contacts').upsert({'owner': me, 'contact': user['id']});
              if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatPage(peer: user)));
            } catch (_) { if (context.mounted) toast(context, t('error')); }
          }),
        ]),
      );
}

class StarredPage extends StatefulWidget {
  const StarredPage({super.key});
  @override
  State<StarredPage> createState() => _StarredPageState();
}

class _StarredPageState extends State<StarredPage> {
  List<Map<String, dynamic>>? l;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      final s = await sb.from('stars').select('message_id').eq('user_id', me);
      final ids = s.map((e) => e['message_id']).toList();
      final r = ids.isEmpty ? [] : await sb.from('messages').select().inFilter('id', ids).order('created_at', ascending: false);
      if (mounted) setState(() => l = List<Map<String, dynamic>>.from(r));
    } catch (_) { if (mounted) setState(() => l = []); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('starredMsgs'))),
        body: l == null ? const Center(child: CircularProgressIndicator()) : l!.isEmpty ? Center(child: Text(t('noStarred'))) : ListView(children: [
          for (final m in l!)
            ListTile(
              leading: Icon(m['sender'] == me ? Icons.north_east : Icons.south_west),
              title: Text(preview(m), maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(hm(m['created_at'])),
              trailing: IconButton(icon: const Icon(Icons.star), onPressed: () async { await sb.from('stars').delete().eq('user_id', me).eq('message_id', m['id']); load(); }),
            )
        ]),
      );
}
