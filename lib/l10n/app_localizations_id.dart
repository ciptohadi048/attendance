// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Factory Attendance';

  @override
  String get appTagline => 'Modern Industrial HRIS';

  @override
  String get welcome => 'Selamat Datang';

  @override
  String get loginSubtitle => 'Masuk untuk memulai absensi Anda';

  @override
  String get nikOrEmail => 'NIK atau Email';

  @override
  String get nikOrEmailHint => 'Masukkan NIK atau email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Masukkan password';

  @override
  String get rememberMe => 'Ingat saya';

  @override
  String get forgotPassword => 'Lupa password?';

  @override
  String get login => 'Masuk';

  @override
  String get contactHrd => 'Hubungi HRD jika Anda belum memiliki akun.';

  @override
  String get forgotPasswordTitle => 'Lupa Password';

  @override
  String get forgotPasswordDesc =>
      'Masukkan NIK dan nama Anda. Admin HRD akan mereset password Anda.';

  @override
  String get nik => 'NIK';

  @override
  String get fullName => 'Nama lengkap';

  @override
  String get name => 'Nama';

  @override
  String get cancel => 'Batal';

  @override
  String get sendToAdmin => 'Kirim ke Admin';

  @override
  String get nikAndNameRequired => 'NIK dan nama wajib diisi';

  @override
  String get requestSent => 'Permintaan terkirim. Admin akan memproses segera.';

  @override
  String requestFailed(String error) {
    return 'Gagal mengirim permintaan: $error';
  }

  @override
  String get loginFailed => 'Gagal masuk. Coba lagi.';

  @override
  String get todayAttendance => 'Absensi Hari Ini';

  @override
  String get clockIn => 'Clock In';

  @override
  String get clockOut => 'Clock Out';

  @override
  String get attendanceComplete => 'Absensi hari ini selesai';

  @override
  String get weeklyStats => 'Statistik Minggu Ini';

  @override
  String get menu => 'Menu';

  @override
  String get statusHadir => 'Hadir';

  @override
  String get statusTelat => 'Telat';

  @override
  String get statusIzin => 'Izin';

  @override
  String get statusAlpha => 'Alpha';

  @override
  String get history => 'Riwayat';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get profile => 'Profil';

  @override
  String get location => 'Lokasi';

  @override
  String get clockInSuccess => 'Clock In Berhasil';

  @override
  String get clockOutSuccess => 'Clock Out Berhasil';

  @override
  String get attendanceFailed => 'Absensi Gagal';

  @override
  String get backToDashboard => 'Kembali ke Dashboard';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get gpsValidation => 'Validasi GPS';

  @override
  String get checkingLocation => 'Memeriksa lokasi Anda...';

  @override
  String get inArea => 'Dalam Area';

  @override
  String get outsideArea => 'Di Luar Area';

  @override
  String distanceFromOffice(String distance) {
    return '$distance dari kantor';
  }

  @override
  String get proceedToSelfie => 'Lanjut ke Selfie';

  @override
  String get outsideAreaWarning =>
      'Anda berada di luar area kantor. Absensi tetap tercatat dengan status di luar area.';

  @override
  String get selfieCamera => 'Kamera Selfie';

  @override
  String get faceDetected => 'Wajah Terdeteksi';

  @override
  String get noFaceDetected => 'Wajah Tidak Terdeteksi';

  @override
  String get takeSelfie => 'Ambil Selfie';

  @override
  String get faceVerificationFailed => 'Verifikasi Wajah Gagal';

  @override
  String get attendanceHistory => 'Riwayat Absensi';

  @override
  String get attendanceDetail => 'Detail Absensi';

  @override
  String get noRecords => 'Belum ada data absensi';

  @override
  String get date => 'Tanggal';

  @override
  String get time => 'Waktu';

  @override
  String get status => 'Status';

  @override
  String get selfie => 'Selfie';

  @override
  String get locationInfo => 'Informasi Lokasi';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get changePassword => 'Ubah Password';

  @override
  String get currentPassword => 'Password Saat Ini';

  @override
  String get newPassword => 'Password Baru';

  @override
  String get confirmPassword => 'Konfirmasi Password';

  @override
  String get save => 'Simpan';

  @override
  String get logout => 'Keluar';

  @override
  String get logoutConfirm => 'Yakin ingin keluar?';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get department => 'Departemen';

  @override
  String get position => 'Jabatan';

  @override
  String get phone => 'Telepon';

  @override
  String get email => 'Email';

  @override
  String get adminDashboard => 'Dashboard Admin';

  @override
  String get employeeList => 'Daftar Karyawan';

  @override
  String get employeeDetail => 'Detail Karyawan';

  @override
  String get createUser => 'Buat Pengguna';

  @override
  String get attendanceLogs => 'Log Absensi';

  @override
  String get kpiCharts => 'Grafik KPI';

  @override
  String get passwordRequests => 'Permintaan Reset Password';

  @override
  String get adminMap => 'Peta Karyawan';

  @override
  String get totalEmployees => 'Total Karyawan';

  @override
  String get presentToday => 'Hadir Hari Ini';

  @override
  String get lateToday => 'Telat Hari Ini';

  @override
  String get absentToday => 'Alpha Hari Ini';

  @override
  String get approve => 'Setujui';

  @override
  String get reject => 'Tolak';

  @override
  String get pending => 'Menunggu';

  @override
  String get processed => 'Diproses';

  @override
  String get export => 'Ekspor';

  @override
  String get filter => 'Filter';

  @override
  String get search => 'Cari';

  @override
  String get all => 'Semua';

  @override
  String get employee => 'Karyawan';

  @override
  String get admin => 'Admin';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get language => 'Bahasa';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get english => 'English';

  @override
  String get errorGeneric => 'Terjadi kesalahan';

  @override
  String get errorNetwork => 'Koneksi gagal. Periksa internet Anda.';

  @override
  String get errorInvalidCredentials => 'NIK / email atau password salah.';

  @override
  String get loading => 'Memuat...';

  @override
  String get success => 'Berhasil';

  @override
  String get failed => 'Gagal';
}
