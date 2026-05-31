import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Factory Attendance'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In id, this message translates to:
  /// **'Modern Industrial HRIS'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get welcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk memulai absensi Anda'**
  String get loginSubtitle;

  /// No description provided for @nikOrEmail.
  ///
  /// In id, this message translates to:
  /// **'NIK atau Email'**
  String get nikOrEmail;

  /// No description provided for @nikOrEmailHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan NIK atau email'**
  String get nikOrEmailHint;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In id, this message translates to:
  /// **'Ingat saya'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @contactHrd.
  ///
  /// In id, this message translates to:
  /// **'Hubungi HRD jika Anda belum memiliki akun.'**
  String get contactHrd;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Lupa Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In id, this message translates to:
  /// **'Masukkan NIK dan nama Anda. Admin HRD akan mereset password Anda.'**
  String get forgotPasswordDesc;

  /// No description provided for @nik.
  ///
  /// In id, this message translates to:
  /// **'NIK'**
  String get nik;

  /// No description provided for @fullName.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get fullName;

  /// No description provided for @name.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get name;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @sendToAdmin.
  ///
  /// In id, this message translates to:
  /// **'Kirim ke Admin'**
  String get sendToAdmin;

  /// No description provided for @nikAndNameRequired.
  ///
  /// In id, this message translates to:
  /// **'NIK dan nama wajib diisi'**
  String get nikAndNameRequired;

  /// No description provided for @requestSent.
  ///
  /// In id, this message translates to:
  /// **'Permintaan terkirim. Admin akan memproses segera.'**
  String get requestSent;

  /// No description provided for @requestFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim permintaan: {error}'**
  String requestFailed(String error);

  /// No description provided for @loginFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk. Coba lagi.'**
  String get loginFailed;

  /// No description provided for @todayAttendance.
  ///
  /// In id, this message translates to:
  /// **'Absensi Hari Ini'**
  String get todayAttendance;

  /// No description provided for @clockIn.
  ///
  /// In id, this message translates to:
  /// **'Clock In'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In id, this message translates to:
  /// **'Clock Out'**
  String get clockOut;

  /// No description provided for @attendanceComplete.
  ///
  /// In id, this message translates to:
  /// **'Absensi hari ini selesai'**
  String get attendanceComplete;

  /// No description provided for @weeklyStats.
  ///
  /// In id, this message translates to:
  /// **'Statistik Minggu Ini'**
  String get weeklyStats;

  /// No description provided for @menu.
  ///
  /// In id, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @statusHadir.
  ///
  /// In id, this message translates to:
  /// **'Hadir'**
  String get statusHadir;

  /// No description provided for @statusTelat.
  ///
  /// In id, this message translates to:
  /// **'Telat'**
  String get statusTelat;

  /// No description provided for @statusIzin.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get statusIzin;

  /// No description provided for @statusAlpha.
  ///
  /// In id, this message translates to:
  /// **'Alpha'**
  String get statusAlpha;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get history;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @location.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get location;

  /// No description provided for @clockInSuccess.
  ///
  /// In id, this message translates to:
  /// **'Clock In Berhasil'**
  String get clockInSuccess;

  /// No description provided for @clockOutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Clock Out Berhasil'**
  String get clockOutSuccess;

  /// No description provided for @attendanceFailed.
  ///
  /// In id, this message translates to:
  /// **'Absensi Gagal'**
  String get attendanceFailed;

  /// No description provided for @backToDashboard.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Dashboard'**
  String get backToDashboard;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @gpsValidation.
  ///
  /// In id, this message translates to:
  /// **'Validasi GPS'**
  String get gpsValidation;

  /// No description provided for @checkingLocation.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa lokasi Anda...'**
  String get checkingLocation;

  /// No description provided for @inArea.
  ///
  /// In id, this message translates to:
  /// **'Dalam Area'**
  String get inArea;

  /// No description provided for @outsideArea.
  ///
  /// In id, this message translates to:
  /// **'Di Luar Area'**
  String get outsideArea;

  /// No description provided for @distanceFromOffice.
  ///
  /// In id, this message translates to:
  /// **'{distance} dari kantor'**
  String distanceFromOffice(String distance);

  /// No description provided for @proceedToSelfie.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke Selfie'**
  String get proceedToSelfie;

  /// No description provided for @outsideAreaWarning.
  ///
  /// In id, this message translates to:
  /// **'Anda berada di luar area kantor. Absensi tetap tercatat dengan status di luar area.'**
  String get outsideAreaWarning;

  /// No description provided for @selfieCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera Selfie'**
  String get selfieCamera;

  /// No description provided for @faceDetected.
  ///
  /// In id, this message translates to:
  /// **'Wajah Terdeteksi'**
  String get faceDetected;

  /// No description provided for @noFaceDetected.
  ///
  /// In id, this message translates to:
  /// **'Wajah Tidak Terdeteksi'**
  String get noFaceDetected;

  /// No description provided for @takeSelfie.
  ///
  /// In id, this message translates to:
  /// **'Ambil Selfie'**
  String get takeSelfie;

  /// No description provided for @faceVerificationFailed.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Wajah Gagal'**
  String get faceVerificationFailed;

  /// No description provided for @attendanceHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Absensi'**
  String get attendanceHistory;

  /// No description provided for @attendanceDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Absensi'**
  String get attendanceDetail;

  /// No description provided for @noRecords.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data absensi'**
  String get noRecords;

  /// No description provided for @date.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get date;

  /// No description provided for @time.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get time;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @selfie.
  ///
  /// In id, this message translates to:
  /// **'Selfie'**
  String get selfie;

  /// No description provided for @locationInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi Lokasi'**
  String get locationInfo;

  /// No description provided for @editProfile.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In id, this message translates to:
  /// **'Password Saat Ini'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In id, this message translates to:
  /// **'Password Baru'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password'**
  String get confirmPassword;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin keluar?'**
  String get logoutConfirm;

  /// No description provided for @yes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get no;

  /// No description provided for @department.
  ///
  /// In id, this message translates to:
  /// **'Departemen'**
  String get department;

  /// No description provided for @position.
  ///
  /// In id, this message translates to:
  /// **'Jabatan'**
  String get position;

  /// No description provided for @phone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @adminDashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard Admin'**
  String get adminDashboard;

  /// No description provided for @employeeList.
  ///
  /// In id, this message translates to:
  /// **'Daftar Karyawan'**
  String get employeeList;

  /// No description provided for @employeeDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Karyawan'**
  String get employeeDetail;

  /// No description provided for @createUser.
  ///
  /// In id, this message translates to:
  /// **'Buat Pengguna'**
  String get createUser;

  /// No description provided for @attendanceLogs.
  ///
  /// In id, this message translates to:
  /// **'Log Absensi'**
  String get attendanceLogs;

  /// No description provided for @kpiCharts.
  ///
  /// In id, this message translates to:
  /// **'Grafik KPI'**
  String get kpiCharts;

  /// No description provided for @passwordRequests.
  ///
  /// In id, this message translates to:
  /// **'Permintaan Reset Password'**
  String get passwordRequests;

  /// No description provided for @adminMap.
  ///
  /// In id, this message translates to:
  /// **'Peta Karyawan'**
  String get adminMap;

  /// No description provided for @totalEmployees.
  ///
  /// In id, this message translates to:
  /// **'Total Karyawan'**
  String get totalEmployees;

  /// No description provided for @presentToday.
  ///
  /// In id, this message translates to:
  /// **'Hadir Hari Ini'**
  String get presentToday;

  /// No description provided for @lateToday.
  ///
  /// In id, this message translates to:
  /// **'Telat Hari Ini'**
  String get lateToday;

  /// No description provided for @absentToday.
  ///
  /// In id, this message translates to:
  /// **'Alpha Hari Ini'**
  String get absentToday;

  /// No description provided for @approve.
  ///
  /// In id, this message translates to:
  /// **'Setujui'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get reject;

  /// No description provided for @pending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get pending;

  /// No description provided for @processed.
  ///
  /// In id, this message translates to:
  /// **'Diproses'**
  String get processed;

  /// No description provided for @export.
  ///
  /// In id, this message translates to:
  /// **'Ekspor'**
  String get export;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @search.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @employee.
  ///
  /// In id, this message translates to:
  /// **'Karyawan'**
  String get employee;

  /// No description provided for @admin.
  ///
  /// In id, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Koneksi gagal. Periksa internet Anda.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In id, this message translates to:
  /// **'NIK / email atau password salah.'**
  String get errorInvalidCredentials;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @success.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get failed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
