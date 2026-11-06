class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!_emailPattern.hasMatch(text)) return 'Format email tidak valid';
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != original) return 'Password tidak sama';
    return null;
  }

  static String? notEmpty(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  static String? minLength(String? value, String label, int min) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi';
    if (text.length < min) return '$label minimal $min karakter';
    return null;
  }

  static String? optionalUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final valid = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    return valid ? null : 'URL harus diawali http:// atau https://';
  }
}