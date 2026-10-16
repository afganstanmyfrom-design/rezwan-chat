import 'dart:async';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  final p = await SharedPreferences.getInstance();
  lang.value = p.getString('lang') ?? 'en';
  dark.value = p.getBool('dark') ?? false;
  runApp(const App());
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
            ListTile(leading: avatar(r!), title: Text(r!['display_name']), subtitle: Text('@${r!['username']}'),
                trailing: FilledButton(onPressed: add, child: Text(t('add'))))
          else if (done) Text(t('notfound')),
        ])),
      );
}

class AudioBubble extends StatefulWidget {
  final String url;
  const AudioBubble({super.key, required this.url});
  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final pl = AudioPlayer();
  bool playing = false;
  @override
  void initState() {
    super.initState();
    pl.onPlayerComplete.listen((_) { if (mounted) setState(() => playing = false); });
  }

  @override
  void dispose() { pl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            icon: Icon(playing ? Icons.pause_circle : Icons.play_circle, size: 36),
            onPressed: () async {
              if (playing) { await pl.pause(); } else { await pl.play(UrlSource(widget.url)); }
              setState(() => playing = !playing);
            }),
        const Icon(Icons.graphic_eq),
        const SizedBox(width: 24),
      ]);
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
  late final Stream<List<Map<String, dynamic>>> ms = sb.from('messages').stream(primaryKey: ['id']).order('created_at', ascending: false);
  @override
  void initState() { super.initState(); beat(); timer = Timer.periodic(const Duration(seconds: 30), (_) => beat()); load(); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> beat() async { try { await sb.from('profiles').update({'last_seen': DateTime.now().toUtc().toIso8601String()}).eq('id', me); } catch (_) {} }
  Future<void> getPeople(Iterable<String> ids) async {
    final need = ids.where((i) => !people.containsKey(i) && !loading.contains(i)).toList();
    if (need.isEmpty) return;
    loading.addAll(need);
    try {
      final r = await sb.from('profiles').select().inFilter('id', need);
      for (final p in r) { people[p['id']] = Map<String, dynamic>.from(p); }
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('chats')), actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())); load(); }),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
        ]),
        body: RefreshIndicator(
          onRefresh: load,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: ms,
            builder: (c, s) {
              final last = <String, Map<String, dynamic>>{};
              final unread = <String, int>{};
              for (final m in s.data ?? <Map<String, dynamic>>[]) {
                final peer = (m['sender'] == me ? m['receiver'] : m['sender']) as String;
                last.putIfAbsent(peer, () => m);
                if (m['receiver'] == me && m['read'] != true) unread[peer] = (unread[peer] ?? 0) + 1;
              }
              contactIds.addAll(last.keys);
              getPeople(contactIds);
              final ids = contactIds.where((i) => people.containsKey(i) && i != me).toList()
                ..sort((a, b) => (last[b]?['created_at'] ?? '').toString().compareTo((last[a]?['created_at'] ?? '').toString()));
              return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                storiesBar(),
                if (ids.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Text(t('empty'), textAlign: TextAlign.center)),
                for (final id in ids)
                  ListTile(
                    leading: avatar(people[id]!),
                    title: Text(people[id]!['display_name']),
                    subtitle: Text(last[id] == null ? '@${people[id]!['username']}' : preview(last[id]!), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: last[id] == null ? null : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(hm(last[id]!['created_at']), style: const TextStyle(fontSize: 11)),
                      if ((unread[id] ?? 0) > 0) Badge(label: Text('${unread[id]}')),
                    ]),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(peer: people[id]!))),
                  ),
              ]);
            },
          ),
        ),
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
  void dispose() { tt?.cancel(); sb.removeChannel(ch); rec.dispose(); super.dispose(); }

  void ping() {
    if (DateTime.now().difference(lastType) < const Duration(seconds: 2)) return;
    lastType = DateTime.now();
    try { ch.sendBroadcastMessage(event: 'typing', payload: {'from': me}); } catch (_) {}
  }

  Future<void> send(String type, String body) async {
    final r = replyTo;
    setState(() => replyTo = null);
    await sb.from('messages').insert({'sender': me, 'receiver': pid, 'type': type, 'body': body, if (r != null) 'reply_to': r['id']});
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(peer: widget.peer))),
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
        body: Column(children: [
          Expanded(child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: st,
            builder: (_, s) {
              final l = (s.data ?? <Map<String, dynamic>>[]).where((m) => (m['sender'] == me && m['receiver'] == pid) || (m['sender'] == pid && m['receiver'] == me)).toList();
              markRead(l);
              return StreamBuilder<List<Map<String, dynamic>>>(stream: rs, builder: (_, r) {
                final rx = r.data ?? <Map<String, dynamic>>[];
                return ListView.builder(reverse: true, padding: const EdgeInsets.all(8), itemCount: l.length, itemBuilder: (_, i) {
                  final m = l[i];
                  final mr = rx.where((e) => e['message_id'] == m['id']).toList();
                  final rep = m['reply_to'] == null ? null : l.cast<Map<String, dynamic>?>().firstWhere((e) => e!['id'] == m['reply_to'], orElse: () => null);
                  return GestureDetector(onLongPress: () => actions(m, mr), onHorizontalDragEnd: (_) => setState(() => replyTo = m),
                      child: Bubble(m: m, mine: m['sender'] == me, reactions: mr, reply: rep));
                });
              });
            },
          )),
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
        ]),
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
            Text(hm(m['created_at']), style: const TextStyle(fontSize: 10)),
            if (mine) Padding(padding: const EdgeInsetsDirectional.only(start: 4), child: Icon(read ? Icons.done_all : Icons.done, size: 14, color: read ? Colors.blue : Colors.grey)),
          ]),
          if (reactions.isNotEmpty) Text(reactions.map((e) => e['emoji']).join(' ')),
        ]),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> peer;
  const ProfilePage({super.key, required this.peer});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('profile'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: GestureDetector(
              onTap: peer['avatar_url'] == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: Center(child: InteractiveViewer(child: Image.network(peer['avatar_url'])))))),
              child: avatar(peer, r: 70))),
          const SizedBox(height: 16),
          Center(child: Text(peer['display_name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          Center(child: Text('@${peer['username']}')),
          const SizedBox(height: 24),
          ListTile(leading: const Icon(Icons.person_remove, color: Colors.red), title: Text(t('removeContact')), onTap: () async {
            await sb.from('contacts').delete().eq('owner', me).eq('contact', peer['id']);
            if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
          }),
        ]),
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
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
                onChanged: (v) async { dark.value = v; (await SharedPreferences.getInstance()).setBool('dark', v); }),
            ListTile(leading: const Icon(Icons.help), title: Text(t('help')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()))),
            ListTile(leading: const Icon(Icons.info), title: Text(t('about')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
            ListTile(leading: const Icon(Icons.logout), title: Text(t('logout')), onTap: () { Navigator.popUntil(context, (r) => r.isFirst); sb.auth.signOut(); }),
          ]),
        ),
      );
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('help'))),
        body: ListView(padding: const EdgeInsets.all(24), children: [Text(t('helpText'), style: const TextStyle(fontSize: 16, height: 1.6))]),
      );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final n = TextEditingController();
  File? img;
  String? cur;
  @override
  void initState() {
    super.initState();
    sb.from('profiles').select().eq('id', me).single().then((p) { n.text = p['display_name']; if (mounted) setState(() => cur = p['avatar_url']); });
  }
  Future<void> pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (x != null) setState(() => img = File(x.path));
  }
  Future<void> save() async {
    try {
      final u = img == null ? cur : await upload(img!, 'jpg');
      await sb.from('profiles').update({'display_name': n.text.trim(), 'avatar_url': u}).eq('id', me);
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
          const SizedBox(height: 16),
          FilledButton(onPressed: save, child: Text(t('save'))),
        ]),
      );
}
