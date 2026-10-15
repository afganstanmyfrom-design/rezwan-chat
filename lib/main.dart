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

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Map<String, dynamic>>> f = load();
  Future<List<Map<String, dynamic>>> load() async {
    final c = await sb.from('contacts').select('contact').eq('owner', me);
    final ids = c.map((e) => e['contact']).toList();
    if (ids.isEmpty) return [];
    return List<Map<String, dynamic>>.from(await sb.from('profiles').select().inFilter('id', ids));
  }

  void refresh() => setState(() => f = load());
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(t('chats')), actions: [
          IconButton(icon: const Icon(Icons.person_add),
              onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())); refresh(); }),
          IconButton(icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
        ]),
        body: RefreshIndicator(
          onRefresh: () async => refresh(),
          child: FutureBuilder(
            future: f,
            builder: (c, s) {
              if (!s.hasData) return const Center(child: CircularProgressIndicator());
              final l = s.data!;
              if (l.isEmpty) return ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Text(t('empty'), textAlign: TextAlign.center))]);
              return ListView(children: [
                for (final p in l)
                  ListTile(leading: avatar(p), title: Text(p['display_name']), subtitle: Text('@${p['username']}'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(peer: p))))
              ]);
            },
          ),
        ),
      );
}

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
  late final Stream<List<Map<String, dynamic>>> st =
      sb.from('messages').stream(primaryKey: ['id']).order('created_at', ascending: false);
  String get pid => widget.peer['id'];

  Future<void> send(String type, String body) =>
      sb.from('messages').insert({'sender': me, 'receiver': pid, 'type': type, 'body': body});

  Future<void> sendText() async {
    final s = c.text.trim();
    if (s.isEmpty) return;
    c.clear();
    await send('text', s);
  }

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
    } catch (_) {
      setState(() => recording = false);
      if (mounted) toast(context, t('error'));
    }
  }

  @override
  void dispose() { rec.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Row(children: [avatar(widget.peer, r: 16), const SizedBox(width: 10), Text(widget.peer['display_name'])])),
        body: Column(children: [
          Expanded(child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: st,
            builder: (_, s) {
              final l = (s.data ?? []).where((m) =>
                  (m['sender'] == me && m['receiver'] == pid) || (m['sender'] == pid && m['receiver'] == me)).toList();
              return ListView.builder(reverse: true, padding: const EdgeInsets.all(8), itemCount: l.length,
                  itemBuilder: (_, i) => Bubble(m: l[i], mine: l[i]['sender'] == me));
            },
          )),
          SafeArea(child: Padding(padding: const EdgeInsets.all(6), child: Row(children: [
            IconButton(icon: const Icon(Icons.image), onPressed: sendImage),
            Expanded(child: TextField(controller: c, minLines: 1, maxLines: 4,
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
  const Bubble({super.key, required this.m, required this.mine});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final type = m['type'];
    Widget w;
    if (type == 'image') {
      w = ClipRRect(borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: Center(child: InteractiveViewer(child: Image.network(m['body'])))))),
              child: Image.network(m['body'], width: 220)));
    } else if (type == 'audio') {
      w = AudioBubble(url: m['body']);
    } else {
      w = Text(m['body']);
    }
    final dt = DateTime.parse(m['created_at']).toLocal();
    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(color: mine ? cs.primaryContainer : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          w, Text(time, style: const TextStyle(fontSize: 10)),
        ]),
      ),
    );
  }
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: lang,
        builder: (_, __, ___) => Scaffold(
          appBar: AppBar(title: Text(t('settings'))),
          body: ListView(children: [
            ListTile(leading: const Icon(Icons.language), title: Text(t('language')),
                trailing: DropdownButton<String>(value: lang.value, underline: const SizedBox(),
                    items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'fa', child: Text('فارسی'))],
                    onChanged: (v) => setLang(v!))),
            SwitchListTile(secondary: const Icon(Icons.dark_mode), title: Text(t('dark')), value: dark.value,
                onChanged: (v) async { dark.value = v; (await SharedPreferences.getInstance()).setBool('dark', v); }),
            ListTile(leading: const Icon(Icons.info), title: Text(t('about')),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
            ListTile(leading: const Icon(Icons.logout), title: Text(t('logout')),
                onTap: () { Navigator.popUntil(context, (r) => r.isFirst); sb.auth.signOut(); }),
          ]),
        ),
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
          Text(t('desc')),
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
