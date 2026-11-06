// Pemeriksaan otomatis kesiapan pengumpulan Project UTS.
//
// Jalankan dari folder root project (yang berisi pubspec.yaml):
//
//   dart run tool/check_submission.dart
//
// Skrip hanya MEMBACA project. Satu-satunya file yang ditulis adalah
// git_log.txt (bukti `git log --oneline`). Kode aplikasi tidak diubah.

import 'dart:convert';
import 'dart:io';

int _failures = 0;
int _warnings = 0;

void _section(String title) => stdout.writeln('\n== $title ==');

void _ok(String message) => stdout.writeln('  [OK]     $message');

void _warn(String message) {
  _warnings++;
  stdout.writeln('  [CEK]    $message');
}

void _fail(String message) {
  _failures++;
  stdout.writeln('  [GAGAL]  $message');
}

/// Menjalankan perintah git. Mengembalikan null jika git gagal / tidak ada.
String? _git(List<String> args) {
  try {
    final result = Process.runSync('git', args);
    if (result.exitCode != 0) return null;
    return (result.stdout as String).trim();
  } on ProcessException {
    return null;
  }
}

String? _read(String path) {
  final file = File(path);
  return file.existsSync() ? file.readAsStringSync() : null;
}

List<File> _dartFiles(String dir) {
  final directory = Directory(dir);
  if (!directory.existsSync()) return [];
  return directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}

void _expectAtLeast(String label, int actual, int minimum) {
  if (actual >= minimum) {
    _ok('$label: $actual (minimal $minimum)');
  } else {
    _fail('$label: baru $actual, minimal $minimum.');
  }
}

void main() {
  stdout.writeln('Pemeriksaan kesiapan pengumpulan UTS');

  if (!File('pubspec.yaml').existsSync()) {
    stdout.writeln(
        'Jalankan skrip ini dari folder root project Flutter (yang berisi pubspec.yaml).');
    exit(2);
  }

  final commitCount = _checkGit();
  final screenCount = _checkStructure();
  _checkSecurity();
  _checkIdentity();
  _checkScreenshots();
  _checkAndroid();

  _section('Data untuk form "Identitas dan Bukti Pengumpulan"');
  stdout.writeln('  Jumlah screen      : $screenCount');
  stdout.writeln('  Jumlah commit      : ${commitCount ?? '-'}');
  stdout.writeln(
      '  Hash commit final  : ${_git(['rev-parse', '--short', 'HEAD']) ?? '-'}');
  stdout.writeln(
      '  Nama branch utama  : ${_git(['branch', '--show-current']) ?? '-'}');

  stdout.writeln('\nHasil: $_failures GAGAL, $_warnings perlu dicek.');
  exit(_failures == 0 ? 0 : 1);
}

int? _checkGit() {
  _section('Git & GitHub');

  final count = int.tryParse(_git(['rev-list', '--count', 'HEAD']) ?? '');
  if (count == null) {
    _fail('Bukan repository Git, belum ada commit, atau git belum terpasang.');
    return null;
  }

  if (count >= 16) {
    _ok('Jumlah commit: $count (minimal 16)');
  } else {
    _fail('Jumlah commit baru $count, minimal 16.');
  }

  final log = _git(['log', '--oneline']) ?? '';
  const vague = {'update', 'fix', 'test', 'tes', 'commit', 'coba', 'wip', 'changes'};
  final weak = <String>[];
  for (final rawLine in log.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final space = line.indexOf(' ');
    final message = space == -1 ? '' : line.substring(space + 1).trim();
    if (message.length < 10 || vague.contains(message.toLowerCase())) {
      weak.add(line);
    }
  }
  if (weak.isEmpty) {
    _ok('Semua pesan commit cukup deskriptif');
  } else {
    _warn(
        '${weak.length} pesan commit terlalu singkat/umum, contoh: "${weak.first}"');
  }

  // Cek perubahan yang belum di-commit (git_log.txt diabaikan)
  final dirty = (_git(['status', '--porcelain']) ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.endsWith('git_log.txt'))
      .toList();
  if (dirty.isEmpty) {
    _ok('Tidak ada perubahan yang belum di-commit');
  } else {
    _warn('${dirty.length} file belum di-commit (lihat: git status)');
  }

  final remote = _git(['remote', 'get-url', 'origin']);
  if (remote == null) {
    _fail('Remote "origin" belum diatur (belum terhubung ke GitHub).');
  } else {
    _ok('Remote origin: $remote');
    final unpushed = _git(['rev-list', '--count', '@{u}..HEAD']);
    if (unpushed == null) {
      _warn('Branch ini belum punya upstream. Jalankan: git push -u origin <nama-branch>');
    } else if (unpushed != '0') {
      _warn('$unpushed commit belum di-push ke GitHub.');
    } else {
      _ok('Semua commit sudah di-push');
    }
  }

  if (log.isNotEmpty) {
    File('git_log.txt').writeAsStringSync('$log\n');
    _ok('git_log.txt dibuat (bukti git log --oneline)');
  }

  return count;
}

int _checkStructure() {
  _section('Struktur & spesifikasi minimum');

  const folders = [
    'models',
    'services',
    'repositories',
    'providers',
    'screens',
    'widgets',
  ];
  for (final folder in folders) {
    if (Directory('lib/$folder').existsSync()) {
      _ok('lib/$folder/');
    } else {
      _fail('Folder lib/$folder/ tidak ada.');
    }
  }
  if (!File('lib/main.dart').existsSync()) _fail('lib/main.dart tidak ada.');

  final screens = _dartFiles('lib/screens')
      .where((file) => !file.path.toLowerCase().contains('splash'))
      .length;
  _expectAtLeast('Screen fungsional (tanpa splash)', screens, 6);
  _expectAtLeast('Reusable widget', _dartFiles('lib/widgets').length, 3);
  _expectAtLeast('Dart model', _dartFiles('lib/models').length, 2);

  // Screen/widget tidak boleh memanggil HTTP/database langsung,
  // dan provider tidak boleh melompati repository.
  final violations = <String>[];
  for (final file in [
    ..._dartFiles('lib/screens'),
    ..._dartFiles('lib/widgets'),
  ]) {
    final content = file.readAsStringSync();
    if (content.contains('package:http/') ||
        content.contains('supabase_flutter') ||
        content.contains('/services/')) {
      violations.add(file.path);
    }
  }
  for (final file in _dartFiles('lib/providers')) {
    if (file.readAsStringSync().contains('/services/')) {
      violations.add(file.path);
    }
  }
  if (violations.isEmpty) {
    _ok('Arsitektur terjaga: UI -> Provider -> Repository -> Service');
  } else {
    _fail('Akses langsung ke HTTP/database/service di: ${violations.join(', ')}');
  }

  return screens;
}

void _checkSecurity() {
  _section('Keamanan');

  final tracked = _git(['ls-files']);
  if (tracked == null) {
    _warn('Daftar file Git tidak terbaca; pemeriksaan keamanan dilewati.');
    return;
  }
  final files = tracked
      .split('\n')
      .map((path) => path.trim())
      .where((path) => path.isNotEmpty)
      .toList();

  final forbidden = files.where((path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jks') ||
        lower.endsWith('.keystore') ||
        lower.endsWith('key.properties') ||
        lower.endsWith('.env');
  }).toList();

  final jwtPattern =
      RegExp(r'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+');
  final secretPattern = RegExp(r'sb_secret_[A-Za-z0-9_-]+');
  const textExtensions = [
    '.dart', '.md', '.yaml', '.yml', '.json', '.properties',
    '.xml', '.gradle', '.kts', '.kt', '.sql', '.txt',
  ];

  var jwtCount = 0;
  final leaked = <String>{};
  for (final path in files) {
    final lower = path.toLowerCase();
    if (!textExtensions.any((ext) => lower.endsWith(ext))) continue;

    String content;
    try {
      content = File(path).readAsStringSync();
    } on FileSystemException {
      continue;
    } on FormatException {
      continue;
    }

    for (final match in jwtPattern.allMatches(content)) {
      jwtCount++;
      if (_jwtRole(match.group(0)!) == 'service_role') leaked.add(path);
    }
    if (secretPattern.hasMatch(content)) leaked.add(path);
  }

  if (leaked.isEmpty) {
    _ok('Tidak ada service_role/secret key di file yang di-commit ($jwtCount JWT diperiksa)');
  } else {
    _fail('service_role/secret key ditemukan di: ${leaked.join(', ')}. '
        'Hapus dari repository dan ROTASI key di dashboard Supabase.');
  }

  if (forbidden.isEmpty) {
    _ok('Tidak ada keystore / .env / key.properties di repository');
  } else {
    _fail('File sensitif ikut di-commit: ${forbidden.join(', ')}');
  }
}

/// Membaca klaim "role" dari payload JWT (tanpa verifikasi tanda tangan).
String? _jwtRole(String token) {
  try {
    final payload = token.split('.')[1];
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    final data = jsonDecode(decoded);
    if (data is Map<String, dynamic>) {
      final role = data['role'];
      return role is String ? role : null;
    }
  } on FormatException {
    return null;
  }
  return null;
}

void _checkIdentity() {
  _section('Identitas');

  final readme = _read('README.md');
  if (readme == null) {
    _fail('README.md tidak ada.');
  } else {
    final placeholders = ['[ISI', '[URL_REPOSITORY]', '[NIM]', '[Nama]']
        .where((text) => readme.contains(text))
        .toList();
    if (placeholders.isEmpty) {
      _ok('README.md: identitas & URL sudah diisi');
    } else {
      _fail('README.md masih berisi placeholder: ${placeholders.join(', ')}');
    }

    const sections = [
      'Fitur',
      'Tech Stack',
      'REST API',
      'Backend',
      'Arsitektur',
      'Screenshot',
      'Cara Menjalankan',
    ];
    for (final section in sections) {
      if (!readme.contains(section)) {
        _warn('README.md belum memuat bagian "$section".');
      }
    }
  }

  final profile = _read('lib/screens/profile_screen.dart');
  if (profile == null) {
    _fail('lib/screens/profile_screen.dart tidak ada.');
  } else {
    final stillDefault = ['Nama Lengkap Kamu', "'NIM Kamu'", "'Kelas Kamu'"]
        .where((text) => profile.contains(text))
        .toList();
    if (stillDefault.isEmpty) {
      _ok('Profil: nama, NIM, dan kelas sudah diganti');
    } else {
      _fail('profile_screen.dart masih memakai placeholder: ${stillDefault.join(', ')}');
    }
  }
}

void _checkScreenshots() {
  _section('Screenshot');

  const expected = [
    'home',
    'list',
    'detail',
    'create',
    'edit',
    'favorites',
    'wide',
    'api',
    'database',
  ];
  final missing = <String>[];
  for (final name in expected) {
    final found = ['png', 'jpg', 'jpeg']
        .any((ext) => File('screenshots/$name.$ext').existsSync());
    if (!found) missing.add(name);
  }

  if (missing.isEmpty) {
    _ok('Semua ${expected.length} screenshot ada di folder screenshots/');
  } else {
    _fail('Screenshot belum lengkap di screenshots/: ${missing.join(', ')} (.png/.jpg)');
  }
}

void _checkAndroid() {
  _section('APK / Android');

  final manifest = _read('android/app/src/main/AndroidManifest.xml');
  if (manifest == null) {
    _warn('AndroidManifest.xml tidak ditemukan (folder android/ tidak ada?).');
    return;
  }

  if (manifest.contains('android.permission.INTERNET')) {
    _ok('Izin INTERNET ada di AndroidManifest.xml utama');
  } else {
    _fail('Izin INTERNET belum ada di AndroidManifest.xml utama. '
        'APK release tidak akan bisa mengakses API/Supabase (lihat panduan).');
  }
}
