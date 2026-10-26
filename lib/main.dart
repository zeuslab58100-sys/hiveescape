import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';


const String _languagePreferenceKey = 'hive_escape_language';

enum AppLanguage {
  italian,
  english,
  spanish,
  french,
  german,
  portuguese,
  dutch,
  polish,
  romanian,
  turkish,
  ukrainian,
  russian,
  japanese,
  korean,
  chinese,
  chineseTraditional,
  indonesian,
  arabic,
  hebrew,
  hindi,
}

extension AppLanguageInfo on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.italian:
        return 'it';
      case AppLanguage.english:
        return 'en';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.portuguese:
        return 'pt';
      case AppLanguage.dutch:
        return 'nl';
      case AppLanguage.polish:
        return 'pl';
      case AppLanguage.romanian:
        return 'ro';
      case AppLanguage.turkish:
        return 'tr';
      case AppLanguage.ukrainian:
        return 'uk';
      case AppLanguage.russian:
        return 'ru';
      case AppLanguage.japanese:
        return 'ja';
      case AppLanguage.korean:
        return 'ko';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.chineseTraditional:
        return 'zh_Hant';
      case AppLanguage.indonesian:
        return 'id';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.hebrew:
        return 'he';
      case AppLanguage.hindi:
        return 'hi';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.italian:
        return 'Italiano';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.dutch:
        return 'Nederlands';
      case AppLanguage.polish:
        return 'Polski';
      case AppLanguage.romanian:
        return 'Română';
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.ukrainian:
        return 'Українська';
      case AppLanguage.russian:
        return 'Русский';
      case AppLanguage.japanese:
        return '日本語';
      case AppLanguage.korean:
        return '한국어';
      case AppLanguage.chinese:
        return '简体中文';
      case AppLanguage.chineseTraditional:
        return '繁體中文';
      case AppLanguage.indonesian:
        return 'Bahasa Indonesia';
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.hebrew:
        return 'עברית';
      case AppLanguage.hindi:
        return 'हिन्दी';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.italian:
        return '🇮🇹';
      case AppLanguage.english:
        return '🇬🇧';
      case AppLanguage.spanish:
        return '🇪🇸';
      case AppLanguage.french:
        return '🇫🇷';
      case AppLanguage.german:
        return '🇩🇪';
      case AppLanguage.portuguese:
        return '🇵🇹';
      case AppLanguage.dutch:
        return '🇳🇱';
      case AppLanguage.polish:
        return '🇵🇱';
      case AppLanguage.romanian:
        return '🇷🇴';
      case AppLanguage.turkish:
        return '🇹🇷';
      case AppLanguage.ukrainian:
        return '🇺🇦';
      case AppLanguage.russian:
        return '🇷🇺';
      case AppLanguage.japanese:
        return '🇯🇵';
      case AppLanguage.korean:
        return '🇰🇷';
      case AppLanguage.chinese:
        return '🇨🇳';
      case AppLanguage.chineseTraditional:
        return '🇹🇼';
      case AppLanguage.indonesian:
        return '🇮🇩';
      case AppLanguage.arabic:
        return '🇸🇦';
      case AppLanguage.hebrew:
        return '🇮🇱';
      case AppLanguage.hindi:
        return '🇮🇳';
    }
  }

}

AppLanguage _languageFromCode(String? code) {
  switch ((code ?? '').toLowerCase()) {
    case 'it':
      return AppLanguage.italian;
    case 'en':
      return AppLanguage.english;
    case 'es':
      return AppLanguage.spanish;
    case 'fr':
      return AppLanguage.french;
    case 'de':
      return AppLanguage.german;
    case 'pt':
      return AppLanguage.portuguese;
    case 'nl':
      return AppLanguage.dutch;
    case 'pl':
      return AppLanguage.polish;
    case 'ro':
      return AppLanguage.romanian;
    case 'tr':
      return AppLanguage.turkish;
    case 'uk':
      return AppLanguage.ukrainian;
    case 'ru':
      return AppLanguage.russian;
    case 'ja':
      return AppLanguage.japanese;
    case 'ko':
      return AppLanguage.korean;
    case 'zh':
      return AppLanguage.chinese;
    case 'zh_hant':
    case 'zh_tw':
    case 'zh_hk':
      return AppLanguage.chineseTraditional;
    case 'id':
      return AppLanguage.indonesian;
    case 'ar':
      return AppLanguage.arabic;
    case 'he':
    case 'iw':
      return AppLanguage.hebrew;
    case 'hi':
      return AppLanguage.hindi;
    default:
      return AppLanguage.english;
  }
}

AppLanguage currentAppLanguage = AppLanguage.english;

bool get isCurrentLanguageRtl =>
    currentAppLanguage == AppLanguage.arabic ||
    currentAppLanguage == AppLanguage.hebrew;

final ValueNotifier<AppLanguage> appLanguageNotifier =
    ValueNotifier<AppLanguage>(currentAppLanguage);

final ValueNotifier<bool> adRequestsAllowedNotifier =
    ValueNotifier<bool>(false);

final ValueNotifier<bool> privacyOptionsRequiredNotifier =
    ValueNotifier<bool>(false);

bool _mobileAdsInitialized = false;
Future<void>? _mobileAdsInitializationFuture;

const String _ageGroupPreferenceKey = 'hive_escape_age_group_v1';

enum UserAgeGroup {
  child,
  teen,
  adult,
}

extension UserAgeGroupInfo on UserAgeGroup {
  String get key {
    switch (this) {
      case UserAgeGroup.child:
        return 'child';
      case UserAgeGroup.teen:
        return 'teen';
      case UserAgeGroup.adult:
        return 'adult';
    }
  }

  static UserAgeGroup? fromKey(String? key) {
    switch (key) {
      case 'child':
        return UserAgeGroup.child;
      case 'teen':
        return UserAgeGroup.teen;
      case 'adult':
        return UserAgeGroup.adult;
      default:
        return null;
    }
  }
}

String ageTr(String key) {
  final language = currentAppLanguage;

  const values = <String, Map<AppLanguage, String>>{
    'title': {
      AppLanguage.italian: 'ETÀ E PRIVACY',
      AppLanguage.english: 'AGE & PRIVACY',
      AppLanguage.spanish: 'EDAD Y PRIVACIDAD',
      AppLanguage.french: 'ÂGE ET CONFIDENTIALITÉ',
      AppLanguage.german: 'ALTER & DATENSCHUTZ',
      AppLanguage.portuguese: 'IDADE E PRIVACIDADE',
      AppLanguage.dutch: 'LEEFTIJD & PRIVACY',
      AppLanguage.polish: 'WIEK I PRYWATNOŚĆ',
      AppLanguage.romanian: 'VÂRSTĂ ȘI CONFIDENȚIALITATE',
      AppLanguage.turkish: 'YAŞ VE GİZLİLİK',
      AppLanguage.ukrainian: 'ВІК І КОНФІДЕНЦІЙНІСТЬ',
      AppLanguage.russian: 'ВОЗРАСТ И КОНФИДЕНЦИАЛЬНОСТЬ',
      AppLanguage.japanese: '年齢とプライバシー',
      AppLanguage.korean: '연령 및 개인정보',
      AppLanguage.chinese: '年龄与隐私',
      AppLanguage.chineseTraditional: '年齡與隱私',
      AppLanguage.indonesian: 'USIA & PRIVASI',
      AppLanguage.arabic: 'العمر والخصوصية',
      AppLanguage.hebrew: 'גיל ופרטיות',
      AppLanguage.hindi: 'आयु और गोपनीयता',
    },
    'question': {
      AppLanguage.italian: 'Seleziona la tua fascia di età',
      AppLanguage.english: 'Select your age range',
      AppLanguage.spanish: 'Selecciona tu rango de edad',
      AppLanguage.french: 'Sélectionne ta tranche d’âge',
      AppLanguage.german: 'Wähle deine Altersgruppe',
      AppLanguage.portuguese: 'Selecione sua faixa etária',
      AppLanguage.dutch: 'Kies je leeftijdsgroep',
      AppLanguage.polish: 'Wybierz swój przedział wiekowy',
      AppLanguage.romanian: 'Selectează categoria ta de vârstă',
      AppLanguage.turkish: 'Yaş aralığını seç',
      AppLanguage.ukrainian: 'Вибери свою вікову групу',
      AppLanguage.russian: 'Выбери свою возрастную группу',
      AppLanguage.japanese: '年齢を選んでください',
      AppLanguage.korean: '연령대를 선택하세요',
      AppLanguage.chinese: '请选择你的年龄范围',
      AppLanguage.chineseTraditional: '請選擇你的年齡範圍',
      AppLanguage.indonesian: 'Pilih rentang usiamu',
      AppLanguage.arabic: 'اختر فئتك العمرية',
      AppLanguage.hebrew: 'בחרו את טווח הגיל שלכם',
      AppLanguage.hindi: 'अपनी आयु सीमा चुनें',
    },
    'note': {
      AppLanguage.italian:
          'Serve solo per impostare correttamente privacy e pubblicità. Non salviamo la tua data di nascita.',
      AppLanguage.english:
          'This is only used to set privacy and ads correctly. We do not save your date of birth.',
      AppLanguage.spanish:
          'Solo sirve para configurar correctamente la privacidad y los anuncios. No guardamos tu fecha de nacimiento.',
      AppLanguage.french:
          'Cela sert uniquement à régler correctement la confidentialité et les publicités. Nous ne conservons pas ta date de naissance.',
      AppLanguage.german:
          'Dies wird nur für die richtigen Datenschutz- und Werbeeinstellungen verwendet. Dein Geburtsdatum wird nicht gespeichert.',
      AppLanguage.portuguese:
          'Isso serve apenas para configurar corretamente privacidade e anúncios. Não salvamos sua data de nascimento.',
      AppLanguage.dutch:
          'Dit wordt alleen gebruikt om privacy en advertenties goed in te stellen. We bewaren je geboortedatum niet.',
      AppLanguage.polish:
          'Służy to tylko do prawidłowych ustawień prywatności i reklam. Nie zapisujemy daty urodzenia.',
      AppLanguage.romanian:
          'Este folosit doar pentru setarea corectă a confidențialității și reclamelor. Nu salvăm data nașterii.',
      AppLanguage.turkish:
          'Bu bilgi yalnızca gizlilik ve reklamları doğru ayarlamak için kullanılır. Doğum tarihini kaydetmiyoruz.',
      AppLanguage.ukrainian:
          'Це потрібно лише для правильних налаштувань приватності та реклами. Ми не зберігаємо дату народження.',
      AppLanguage.russian:
          'Это нужно только для правильной настройки конфиденциальности и рекламы. Мы не сохраняем дату рождения.',
      AppLanguage.japanese:
          'プライバシーと広告を正しく設定するためだけに使います。生年月日は保存しません。',
      AppLanguage.korean:
          '개인정보 보호와 광고 설정에만 사용됩니다. 생년월일은 저장하지 않습니다.',
      AppLanguage.chinese:
          '仅用于正确设置隐私和广告。我们不会保存你的出生日期。',
      AppLanguage.chineseTraditional:
          '僅用於正確設定隱私和廣告。我們不會儲存你的出生日期。',
      AppLanguage.indonesian:
          'Ini hanya digunakan untuk mengatur privasi dan iklan dengan benar. Kami tidak menyimpan tanggal lahirmu.',
      AppLanguage.arabic:
          'يُستخدم هذا فقط لضبط الخصوصية والإعلانات بشكل صحيح. لا نحفظ تاريخ ميلادك.',
      AppLanguage.hebrew:
          'המידע משמש רק להגדרה נכונה של פרטיות ופרסומות. איננו שומרים את תאריך הלידה.',
      AppLanguage.hindi:
          'इसका उपयोग केवल गोपनीयता और विज्ञापनों को सही तरह सेट करने के लिए होता है। हम आपकी जन्मतिथि सेव नहीं करते।',
    },
    'child': {
      AppLanguage.italian: '12 anni o meno',
      AppLanguage.english: '12 or younger',
      AppLanguage.spanish: '12 años o menos',
      AppLanguage.french: '12 ans ou moins',
      AppLanguage.german: '12 Jahre oder jünger',
      AppLanguage.portuguese: '12 anos ou menos',
      AppLanguage.dutch: '12 jaar of jonger',
      AppLanguage.polish: '12 lat lub mniej',
      AppLanguage.romanian: '12 ani sau mai puțin',
      AppLanguage.turkish: '12 yaş veya altı',
      AppLanguage.ukrainian: '12 років або менше',
      AppLanguage.russian: '12 лет или младше',
      AppLanguage.japanese: '12歳以下',
      AppLanguage.korean: '12세 이하',
      AppLanguage.chinese: '12岁或以下',
      AppLanguage.chineseTraditional: '12歲或以下',
      AppLanguage.indonesian: '12 tahun atau kurang',
      AppLanguage.arabic: '12 سنة أو أقل',
      AppLanguage.hebrew: '12 ומטה',
      AppLanguage.hindi: '12 वर्ष या कम',
    },
    'teen': {
      AppLanguage.italian: '13–17 anni',
      AppLanguage.english: '13–17 years',
      AppLanguage.spanish: '13–17 años',
      AppLanguage.french: '13–17 ans',
      AppLanguage.german: '13–17 Jahre',
      AppLanguage.portuguese: '13–17 anos',
      AppLanguage.dutch: '13–17 jaar',
      AppLanguage.polish: '13–17 lat',
      AppLanguage.romanian: '13–17 ani',
      AppLanguage.turkish: '13–17 yaş',
      AppLanguage.ukrainian: '13–17 років',
      AppLanguage.russian: '13–17 лет',
      AppLanguage.japanese: '13〜17歳',
      AppLanguage.korean: '13–17세',
      AppLanguage.chinese: '13–17岁',
      AppLanguage.chineseTraditional: '13–17歲',
      AppLanguage.indonesian: '13–17 tahun',
      AppLanguage.arabic: '13–17 سنة',
      AppLanguage.hebrew: '13–17',
      AppLanguage.hindi: '13–17 वर्ष',
    },
    'adult': {
      AppLanguage.italian: '18 anni o più',
      AppLanguage.english: '18 or older',
      AppLanguage.spanish: '18 años o más',
      AppLanguage.french: '18 ans ou plus',
      AppLanguage.german: '18 Jahre oder älter',
      AppLanguage.portuguese: '18 anos ou mais',
      AppLanguage.dutch: '18 jaar of ouder',
      AppLanguage.polish: '18 lat lub więcej',
      AppLanguage.romanian: '18 ani sau mai mult',
      AppLanguage.turkish: '18 yaş veya üstü',
      AppLanguage.ukrainian: '18 років або більше',
      AppLanguage.russian: '18 лет или старше',
      AppLanguage.japanese: '18歳以上',
      AppLanguage.korean: '18세 이상',
      AppLanguage.chinese: '18岁或以上',
      AppLanguage.chineseTraditional: '18歲或以上',
      AppLanguage.indonesian: '18 tahun atau lebih',
      AppLanguage.arabic: '18 سنة أو أكثر',
      AppLanguage.hebrew: '18 ומעלה',
      AppLanguage.hindi: '18 वर्ष या अधिक',
    },
  };

  return values[key]?[language] ??
      values[key]?[AppLanguage.english] ??
      key;
}

String privacyTr(String key) {
  final language = currentAppLanguage;

  const values = <String, Map<AppLanguage, String>>{
    'privacyChoices': {
      AppLanguage.italian: 'Scelte sulla privacy',
      AppLanguage.english: 'Privacy choices',
      AppLanguage.spanish: 'Opciones de privacidad',
      AppLanguage.french: 'Choix de confidentialité',
      AppLanguage.german: 'Datenschutzeinstellungen',
      AppLanguage.portuguese: 'Opções de privacidade',
      AppLanguage.dutch: 'Privacykeuzes',
      AppLanguage.polish: 'Ustawienia prywatności',
      AppLanguage.romanian: 'Opțiuni de confidențialitate',
      AppLanguage.turkish: 'Gizlilik seçenekleri',
      AppLanguage.ukrainian: 'Налаштування приватності',
      AppLanguage.russian: 'Настройки конфиденциальности',
      AppLanguage.japanese: 'プライバシー設定',
      AppLanguage.korean: '개인정보 보호 선택',
      AppLanguage.chinese: '隐私选项',
      AppLanguage.chineseTraditional: '隱私選項',
      AppLanguage.indonesian: 'Pilihan privasi',
      AppLanguage.arabic: 'خيارات الخصوصية',
      AppLanguage.hebrew: 'אפשרויות פרטיות',
      AppLanguage.hindi: 'गोपनीयता विकल्प',
    },
    'privacyChoicesSubtitle': {
      AppLanguage.italian: 'Rivedi o modifica il consenso pubblicitario',
      AppLanguage.english: 'Review or change advertising consent',
      AppLanguage.spanish: 'Revisa o cambia el consentimiento publicitario',
      AppLanguage.french: 'Consulte ou modifie le consentement publicitaire',
      AppLanguage.german: 'Werbeeinwilligung prüfen oder ändern',
      AppLanguage.portuguese: 'Reveja ou altere o consentimento de anúncios',
      AppLanguage.dutch: 'Bekijk of wijzig toestemming voor advertenties',
      AppLanguage.polish: 'Sprawdź lub zmień zgodę na reklamy',
      AppLanguage.romanian: 'Revizuiește sau modifică acordul pentru reclame',
      AppLanguage.turkish: 'Reklam onayını incele veya değiştir',
      AppLanguage.ukrainian: 'Переглянь або зміни згоду на рекламу',
      AppLanguage.russian: 'Просмотрите или измените согласие на рекламу',
      AppLanguage.japanese: '広告への同意を確認・変更します',
      AppLanguage.korean: '광고 동의를 확인하거나 변경합니다',
      AppLanguage.chinese: '查看或更改广告同意设置',
      AppLanguage.chineseTraditional: '查看或變更廣告同意設定',
      AppLanguage.indonesian: 'Tinjau atau ubah persetujuan iklan',
      AppLanguage.arabic: 'راجع أو غيّر موافقتك على الإعلانات',
      AppLanguage.hebrew: 'בדקו או שנו את ההסכמה לפרסום',
      AppLanguage.hindi: 'विज्ञापन सहमति की समीक्षा करें या बदलें',
    },
  };

  return values[key]?[language] ??
      values[key]?[AppLanguage.english] ??
      key;
}

Future<void> applyAgeAdConfiguration(UserAgeGroup ageGroup) async {
  final treatment = switch (ageGroup) {
    UserAgeGroup.child => AgeRestrictedTreatment.child,
    UserAgeGroup.teen => AgeRestrictedTreatment.teen,
    UserAgeGroup.adult => AgeRestrictedTreatment.unspecified,
  };

  final maxRating = switch (ageGroup) {
    UserAgeGroup.child => MaxAdContentRating.g,
    UserAgeGroup.teen => MaxAdContentRating.pg,
    UserAgeGroup.adult => MaxAdContentRating.pg,
  };

  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      ageRestrictedTreatment: treatment,
      // Bambini: massimo G.
      // Teen e adulti: massimo PG, per non restringere inutilmente
      // l'inventario pubblicitario mantenendo un profilo adatto a Hive Escape.
      maxAdContentRating: maxRating,
    ),
  );
}

Future<void> _ensureMobileAdsInitialized() async {
  if (_mobileAdsInitialized) {
    return;
  }

  _mobileAdsInitializationFuture ??= () async {
    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;
  }();

  try {
    await _mobileAdsInitializationFuture;
  } catch (_) {
    _mobileAdsInitializationFuture = null;
    rethrow;
  }
}

Future<void> _updatePrivacyOptionsRequirement() async {
  try {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();

    privacyOptionsRequiredNotifier.value =
        status == PrivacyOptionsRequirementStatus.required;
  } catch (error) {
    debugPrint('UMP privacy options status error: $error');
    privacyOptionsRequiredNotifier.value = false;
  }
}

Future<void> _syncAdRequestPermission() async {
  bool canRequestAds = false;

  try {
    canRequestAds = await ConsentInformation.instance.canRequestAds();
  } catch (error) {
    debugPrint('UMP canRequestAds error: $error');
  }

  if (canRequestAds) {
    try {
      await _ensureMobileAdsInitialized();
    } catch (error) {
      debugPrint('Mobile Ads initialization error: $error');
      canRequestAds = false;
    }
  }

  adRequestsAllowedNotifier.value = canRequestAds;
}

Future<void> refreshConsentAndAdsForAge(UserAgeGroup ageGroup) async {
  // Blocchiamo nuove richieste finché UMP non ha aggiornato lo stato.
  adRequestsAllowedNotifier.value = false;

  final completer = Completer<void>();
  final underAgeOfConsent = ageGroup != UserAgeGroup.adult;

  final params = ConsentRequestParameters(
    // Per bambini e teen UMP non deve chiedere il consenso come a un adulto.
    tagForUnderAgeOfConsent: underAgeOfConsent,
  );

  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () {
      ConsentForm.loadAndShowConsentFormIfRequired(
        (FormError? formError) async {
          if (formError != null) {
            debugPrint(
              'UMP consent form error ${formError.errorCode}: '
              '${formError.message}',
            );
          }

          await _updatePrivacyOptionsRequirement();
          await _syncAdRequestPermission();

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    },
    (FormError error) async {
      debugPrint(
        'UMP consent update error ${error.errorCode}: ${error.message}',
      );

      // Se esiste già una scelta valida di una sessione precedente,
      // canRequestAds può comunque essere true.
      await _updatePrivacyOptionsRequirement();
      await _syncAdRequestPermission();

      if (!completer.isCompleted) {
        completer.complete();
      }
    },
  );

  await completer.future;
}

Future<void> showPrivacyOptionsAndRefreshAds() async {
  final completer = Completer<void>();

  ConsentForm.showPrivacyOptionsForm(
    (FormError? formError) async {
      if (formError != null) {
        debugPrint(
          'UMP privacy options form error ${formError.errorCode}: '
          '${formError.message}',
        );
      }

      await _updatePrivacyOptionsRequirement();
      await _syncAdRequestPermission();

      if (!completer.isCompleted) {
        completer.complete();
      }
    },
  );

  await completer.future;
}

const Map<String, Map<AppLanguage, String>> _translations = {
  'appName': {
    AppLanguage.italian: 'FUGA DALL’ALVEARE',
    AppLanguage.english: 'HIVE ESCAPE',
    AppLanguage.spanish: 'ESCAPE DE LA COLMENA',
    AppLanguage.french: 'ÉVASION DE LA RUCHE',
    AppLanguage.german: 'FLUCHT AUS DEM BIENENSTOCK',
    AppLanguage.portuguese: 'FUGA DA COLMEIA',
    AppLanguage.dutch: 'ONTSNAP UIT DE BIJENKORF',
    AppLanguage.polish: 'UCIECZKA Z ULA',
    AppLanguage.romanian: 'EVADAREA DIN STUP',
    AppLanguage.turkish: 'KOVANDAN KAÇIŞ',
    AppLanguage.russian: 'ПОБЕГ ИЗ УЛЬЯ',
    AppLanguage.japanese: 'ハチの巣から脱出',
    AppLanguage.korean: '벌집 탈출',
    AppLanguage.chinese: '蜂巢逃脱',
    AppLanguage.arabic: 'الهروب من الخلية',
    AppLanguage.hindi: 'छत्ते से भागो',
    AppLanguage.ukrainian: 'ВТЕЧА З ВУЛИКА',
    AppLanguage.chineseTraditional: '蜂巢逃脫',
    AppLanguage.indonesian: 'KABUR DARI SARANG LEBAH',
    AppLanguage.hebrew: 'בריחה מהכוורת',
  },
  'easy': {
    AppLanguage.italian: 'FACILE',
    AppLanguage.english: 'EASY',
    AppLanguage.spanish: 'FÁCIL',
    AppLanguage.french: 'FACILE',
    AppLanguage.german: 'LEICHT',
    AppLanguage.portuguese: 'FÁCIL',
    AppLanguage.dutch: 'MAKKELIJK',
    AppLanguage.polish: 'ŁATWY',
    AppLanguage.romanian: 'UȘOR',
    AppLanguage.turkish: 'KOLAY',
    AppLanguage.russian: 'ЛЕГКО',
    AppLanguage.japanese: 'かんたん',
    AppLanguage.korean: '쉬움',
    AppLanguage.chinese: '简单',
    AppLanguage.arabic: 'سهل',
    AppLanguage.hindi: 'आसान',
    AppLanguage.ukrainian: 'ЛЕГКО',
    AppLanguage.chineseTraditional: '簡單',
    AppLanguage.indonesian: 'MUDAH',
    AppLanguage.hebrew: 'קל',
  },
  'medium': {
    AppLanguage.italian: 'MEDIO',
    AppLanguage.english: 'MEDIUM',
    AppLanguage.spanish: 'MEDIO',
    AppLanguage.french: 'MOYEN',
    AppLanguage.german: 'MITTEL',
    AppLanguage.portuguese: 'MÉDIO',
    AppLanguage.dutch: 'NORMAAL',
    AppLanguage.polish: 'ŚREDNI',
    AppLanguage.romanian: 'MEDIU',
    AppLanguage.turkish: 'ORTA',
    AppLanguage.russian: 'СРЕДНЕ',
    AppLanguage.japanese: 'ふつう',
    AppLanguage.korean: '보통',
    AppLanguage.chinese: '中等',
    AppLanguage.arabic: 'متوسط',
    AppLanguage.hindi: 'मध्यम',
    AppLanguage.ukrainian: 'СЕРЕДНЬО',
    AppLanguage.chineseTraditional: '中等',
    AppLanguage.indonesian: 'SEDANG',
    AppLanguage.hebrew: 'בינוני',
  },
  'hard': {
    AppLanguage.italian: 'DIFFICILE',
    AppLanguage.english: 'HARD',
    AppLanguage.spanish: 'DIFÍCIL',
    AppLanguage.french: 'DIFFICILE',
    AppLanguage.german: 'SCHWER',
    AppLanguage.portuguese: 'DIFÍCIL',
    AppLanguage.dutch: 'MOEILIJK',
    AppLanguage.polish: 'TRUDNY',
    AppLanguage.romanian: 'DIFICIL',
    AppLanguage.turkish: 'ZOR',
    AppLanguage.russian: 'СЛОЖНО',
    AppLanguage.japanese: 'むずかしい',
    AppLanguage.korean: '어려움',
    AppLanguage.chinese: '困难',
    AppLanguage.arabic: 'صعب',
    AppLanguage.hindi: 'कठिन',
    AppLanguage.ukrainian: 'СКЛАДНО',
    AppLanguage.chineseTraditional: '困難',
    AppLanguage.indonesian: 'SULIT',
    AppLanguage.hebrew: 'קשה',
  },
  'howToPlay': {
    AppLanguage.italian: 'COME SI GIOCA',
    AppLanguage.english: 'HOW TO PLAY',
    AppLanguage.spanish: 'CÓMO JUGAR',
    AppLanguage.french: 'COMMENT JOUER',
    AppLanguage.german: 'SO SPIELT MAN',
    AppLanguage.portuguese: 'COMO JOGAR',
    AppLanguage.dutch: 'HOE SPEEL JE',
    AppLanguage.polish: 'JAK GRAĆ',
    AppLanguage.romanian: 'CUM SE JOACĂ',
    AppLanguage.turkish: 'NASIL OYNANIR',
    AppLanguage.russian: 'КАК ИГРАТЬ',
    AppLanguage.japanese: 'あそびかた',
    AppLanguage.korean: '플레이 방법',
    AppLanguage.chinese: '玩法说明',
    AppLanguage.arabic: 'كيفية اللعب',
    AppLanguage.hindi: 'कैसे खेलें',
    AppLanguage.ukrainian: 'ЯК ГРАТИ',
    AppLanguage.chineseTraditional: '玩法說明',
    AppLanguage.indonesian: 'CARA BERMAIN',
    AppLanguage.hebrew: 'איך משחקים',
  },
  'lookArrow': {
    AppLanguage.italian: 'Guarda la freccia',
    AppLanguage.english: 'Follow the arrow',
    AppLanguage.spanish: 'Sigue la flecha',
    AppLanguage.french: 'Suis la flèche',
    AppLanguage.german: 'Folge dem Pfeil',
    AppLanguage.portuguese: 'Siga a seta',
    AppLanguage.dutch: 'Volg de pijl',
    AppLanguage.polish: 'Podążaj za strzałką',
    AppLanguage.romanian: 'Urmărește săgeata',
    AppLanguage.turkish: 'Oku takip et',
    AppLanguage.russian: 'Следуй по стрелке',
    AppLanguage.japanese: 'やじるしを見よう',
    AppLanguage.korean: '화살표를 보세요',
    AppLanguage.chinese: '看箭头',
    AppLanguage.arabic: 'اتبع السهم',
    AppLanguage.hindi: 'तीर को देखो',
    AppLanguage.ukrainian: 'Дивись на стрілку',
    AppLanguage.chineseTraditional: '看箭頭',
    AppLanguage.indonesian: 'Ikuti panah',
    AppLanguage.hebrew: 'עקבו אחרי החץ',
  },
  'lookArrowText': {
    AppLanguage.italian: 'Ogni ape vola nella direzione indicata dalla freccia sulla sua casella.',
    AppLanguage.english: 'Each bee flies in the direction shown by the arrow on its tile.',
    AppLanguage.spanish: 'Cada abeja vuela en la dirección indicada por la flecha de su casilla.',
    AppLanguage.french: 'Chaque abeille s’envole dans la direction indiquée par la flèche sur sa case.',
    AppLanguage.german: 'Jede Biene fliegt in die Richtung, die der Pfeil auf ihrem Feld zeigt.',
    AppLanguage.portuguese: 'Cada abelha voa na direção indicada pela seta em sua casa.',
    AppLanguage.dutch: 'Elke bij vliegt in de richting van de pijl op haar vakje.',
    AppLanguage.polish: 'Każda pszczoła leci w kierunku wskazanym przez strzałkę na swoim polu.',
    AppLanguage.romanian: 'Fiecare albină zboară în direcția indicată de săgeata de pe căsuța ei.',
    AppLanguage.turkish: 'Her arı, kendi karesindeki okun gösterdiği yöne uçar.',
    AppLanguage.russian: 'Каждая пчела летит в направлении, которое показывает стрелка на её клетке.',
    AppLanguage.japanese: 'それぞれのハチは、マスにあるやじるしの方向へ飛びます。',
    AppLanguage.korean: '각 벌은 자기 칸의 화살표가 가리키는 방향으로 날아갑니다.',
    AppLanguage.chinese: '每只蜜蜂都会沿着自己格子上箭头指示的方向飞走。',
    AppLanguage.arabic: 'كل نحلة تطير في الاتجاه الذي يشير إليه السهم الموجود في مربعها.',
    AppLanguage.hindi: 'हर मधुमक्खी अपनी खाने पर बने तीर की दिशा में उड़ती है।',
    AppLanguage.ukrainian: 'Кожна бджола летить у напрямку, який показує стрілка на її клітинці.',
    AppLanguage.chineseTraditional: '每隻蜜蜂都會沿著自己格子上箭頭指示的方向飛走。',
    AppLanguage.indonesian: 'Setiap lebah terbang ke arah yang ditunjukkan panah pada kotaknya.',
    AppLanguage.hebrew: 'כל דבורה עפה בכיוון שמראה החץ במשבצת שלה.',
  },
  'checkPath': {
    AppLanguage.italian: 'Controlla la strada',
    AppLanguage.english: 'Check the path',
    AppLanguage.spanish: 'Mira el camino',
    AppLanguage.french: 'Vérifie le passage',
    AppLanguage.german: 'Prüfe den Weg',
    AppLanguage.portuguese: 'Verifique o caminho',
    AppLanguage.dutch: 'Controleer het pad',
    AppLanguage.polish: 'Sprawdź drogę',
    AppLanguage.romanian: 'Verifică drumul',
    AppLanguage.turkish: 'Yolu kontrol et',
    AppLanguage.russian: 'Проверь путь',
    AppLanguage.japanese: 'みちを確認しよう',
    AppLanguage.korean: '길을 확인하세요',
    AppLanguage.chinese: '检查路线',
    AppLanguage.arabic: 'تحقق من الطريق',
    AppLanguage.hindi: 'रास्ता देखो',
    AppLanguage.ukrainian: 'Перевір шлях',
    AppLanguage.chineseTraditional: '檢查路線',
    AppLanguage.indonesian: 'Periksa jalur',
    AppLanguage.hebrew: 'בדקו את הדרך',
  },
  'checkPathText': {
    AppLanguage.italian: 'L’ape può uscire soltanto se non ci sono altre api davanti lungo la sua direzione.',
    AppLanguage.english: 'A bee can leave only if there are no other bees blocking its path.',
    AppLanguage.spanish: 'Una abeja puede salir solo si no hay otras abejas bloqueando su camino.',
    AppLanguage.french: 'Une abeille peut sortir seulement si aucune autre abeille ne bloque son chemin.',
    AppLanguage.german: 'Eine Biene kann nur hinausfliegen, wenn keine andere Biene ihren Weg blockiert.',
    AppLanguage.portuguese: 'Uma abelha só pode sair se não houver outras abelhas bloqueando seu caminho.',
    AppLanguage.dutch: 'Een bij kan alleen wegvliegen als er geen andere bijen in de weg staan.',
    AppLanguage.polish: 'Pszczoła może wyjść tylko wtedy, gdy żadna inna pszczoła nie blokuje jej drogi.',
    AppLanguage.romanian: 'O albină poate ieși doar dacă nu are alte albine care îi blochează drumul.',
    AppLanguage.turkish: 'Bir arı ancak yolunu kapatan başka arı yoksa çıkabilir.',
    AppLanguage.russian: 'Пчела может вылететь только если её путь не перекрывают другие пчёлы.',
    AppLanguage.japanese: 'ほかのハチに道をふさがれていないときだけ、ハチは外に出られます。',
    AppLanguage.korean: '다른 벌이 길을 막고 있지 않을 때만 벌이 나갈 수 있습니다.',
    AppLanguage.chinese: '只有前进方向上没有其他蜜蜂挡路时，这只蜜蜂才能飞出去。',
    AppLanguage.arabic: 'يمكن للنحلة الخروج فقط إذا لم تكن هناك نحل أخرى تسد طريقها.',
    AppLanguage.hindi: 'मधुमक्खी तभी बाहर जा सकती है जब उसके रास्ते में दूसरी मधुमक्खियाँ न हों।',
    AppLanguage.ukrainian: 'Бджола може вилетіти лише тоді, коли інші бджоли не перекривають їй шлях.',
    AppLanguage.chineseTraditional: '只有前進方向上沒有其他蜜蜂擋路時，這隻蜜蜂才能飛出去。',
    AppLanguage.indonesian: 'Lebah hanya bisa keluar jika tidak ada lebah lain yang menghalangi jalurnya.',
    AppLanguage.hebrew: 'דבורה יכולה לצאת רק אם אין דבורים אחרות שחוסמות את דרכה.',
  },
  'freeHive': {
    AppLanguage.italian: 'Libera l’alveare',
    AppLanguage.english: 'Clear the hive',
    AppLanguage.spanish: 'Libera la colmena',
    AppLanguage.french: 'Libère la ruche',
    AppLanguage.german: 'Befreie den Bienenstock',
    AppLanguage.portuguese: 'Liberte a colmeia',
    AppLanguage.dutch: 'Bevrijd de bijenkorf',
    AppLanguage.polish: 'Uwolnij ul',
    AppLanguage.romanian: 'Eliberează stupul',
    AppLanguage.turkish: 'Kovanı boşalt',
    AppLanguage.russian: 'Освободи улей',
    AppLanguage.japanese: 'ハチの巣を助けよう',
    AppLanguage.korean: '벌집을 비우세요',
    AppLanguage.chinese: '清空蜂巢',
    AppLanguage.arabic: 'حرر الخلية',
    AppLanguage.hindi: 'छत्ता खाली करो',
    AppLanguage.ukrainian: 'Звільни вулик',
    AppLanguage.chineseTraditional: '清空蜂巢',
    AppLanguage.indonesian: 'Kosongkan sarang',
    AppLanguage.hebrew: 'פנו את הכוורת',
  },
  'freeHiveText': {
    AppLanguage.italian: 'Trova l’ordine giusto e fai uscire tutte le api. Meno errori e suggerimenti usi, più stelle ottieni!',
    AppLanguage.english: 'Find the right order and free every bee. Fewer mistakes and hints earn you more stars!',
    AppLanguage.spanish: 'Encuentra el orden correcto y libera a todas las abejas. ¡Cuantos menos errores y pistas uses, más estrellas ganarás!',
    AppLanguage.french: 'Trouve le bon ordre et libère toutes les abeilles. Moins tu fais d’erreurs et utilises d’indices, plus tu gagnes d’étoiles !',
    AppLanguage.german: 'Finde die richtige Reihenfolge und befreie alle Bienen. Je weniger Fehler und Hinweise du nutzt, desto mehr Sterne bekommst du!',
    AppLanguage.portuguese: 'Encontre a ordem certa e liberte todas as abelhas. Quanto menos erros e dicas usar, mais estrelas ganhará!',
    AppLanguage.dutch: 'Vind de juiste volgorde en bevrijd alle bijen. Hoe minder fouten en hints je gebruikt, hoe meer sterren je verdient!',
    AppLanguage.polish: 'Znajdź właściwą kolejność i wypuść wszystkie pszczoły. Im mniej błędów i podpowiedzi użyjesz, tym więcej gwiazdek zdobędziesz!',
    AppLanguage.romanian: 'Găsește ordinea corectă și eliberează toate albinele. Cu cât folosești mai puține greșeli și indicii, cu atât câștigi mai multe stele!',
    AppLanguage.turkish: 'Doğru sırayı bul ve tüm arıları çıkar. Ne kadar az hata ve ipucu kullanırsan o kadar çok yıldız kazanırsın!',
    AppLanguage.russian: 'Найди правильный порядок и выпусти всех пчёл. Чем меньше ошибок и подсказок, тем больше звёзд ты получишь!',
    AppLanguage.japanese: '正しい順番を見つけて、すべてのハチを外に出そう。ミスやヒントが少ないほど、たくさんの星がもらえるよ！',
    AppLanguage.korean: '올바른 순서를 찾아 모든 벌을 내보내세요. 실수와 힌트를 적게 사용할수록 더 많은 별을 받습니다!',
    AppLanguage.chinese: '找出正确顺序，放飞所有蜜蜂。错误和提示用得越少，获得的星星就越多！',
    AppLanguage.arabic: 'اعثر على الترتيب الصحيح وأخرج جميع النحل. كلما قلّت الأخطاء والتلميحات التي تستخدمها، حصلت على نجوم أكثر!',
    AppLanguage.hindi: 'सही क्रम खोजो और सभी मधुमक्खियों को बाहर निकालो। जितनी कम गलतियाँ और संकेत लोगे, उतने ज़्यादा सितारे मिलेंगे!',
    AppLanguage.ukrainian: 'Знайди правильний порядок і випусти всіх бджіл. Чим менше помилок і підказок, тим більше зірок!',
    AppLanguage.chineseTraditional: '找出正確順序，放飛所有蜜蜂。錯誤和提示用得越少，獲得的星星就越多！',
    AppLanguage.indonesian: 'Temukan urutan yang benar dan bebaskan semua lebah. Semakin sedikit kesalahan dan petunjuk, semakin banyak bintang yang kamu dapat!',
    AppLanguage.hebrew: 'מצאו את הסדר הנכון ושחררו את כל הדבורים. פחות טעויות ורמזים = יותר כוכבים!',
  },
  'startPlaying': {
    AppLanguage.italian: 'INIZIA A GIOCARE',
    AppLanguage.english: 'START PLAYING',
    AppLanguage.spanish: 'EMPEZAR A JUGAR',
    AppLanguage.french: 'COMMENCER À JOUER',
    AppLanguage.german: 'JETZT SPIELEN',
    AppLanguage.portuguese: 'COMEÇAR A JOGAR',
    AppLanguage.dutch: 'BEGIN MET SPELEN',
    AppLanguage.polish: 'ZACZNIJ GRAĆ',
    AppLanguage.romanian: 'ÎNCEPE JOCUL',
    AppLanguage.turkish: 'OYUNA BAŞLA',
    AppLanguage.russian: 'НАЧАТЬ ИГРАТЬ',
    AppLanguage.japanese: 'ゲームをはじめる',
    AppLanguage.korean: '게임 시작',
    AppLanguage.chinese: '开始游戏',
    AppLanguage.arabic: 'ابدأ اللعب',
    AppLanguage.hindi: 'खेल शुरू करें',
    AppLanguage.ukrainian: 'ПОЧАТИ ГРАТИ',
    AppLanguage.chineseTraditional: '開始遊戲',
    AppLanguage.indonesian: 'MULAI BERMAIN',
    AppLanguage.hebrew: 'התחילו לשחק',
  },
  'next': {
    AppLanguage.italian: 'AVANTI',
    AppLanguage.english: 'NEXT',
    AppLanguage.spanish: 'SIGUIENTE',
    AppLanguage.french: 'SUIVANT',
    AppLanguage.german: 'WEITER',
    AppLanguage.portuguese: 'AVANÇAR',
    AppLanguage.dutch: 'VOLGENDE',
    AppLanguage.polish: 'DALEJ',
    AppLanguage.romanian: 'URMĂTORUL',
    AppLanguage.turkish: 'İLERİ',
    AppLanguage.russian: 'ДАЛЕЕ',
    AppLanguage.japanese: 'つぎへ',
    AppLanguage.korean: '다음',
    AppLanguage.chinese: '下一步',
    AppLanguage.arabic: 'التالي',
    AppLanguage.hindi: 'आगे',
    AppLanguage.ukrainian: 'ДАЛІ',
    AppLanguage.chineseTraditional: '下一步',
    AppLanguage.indonesian: 'LANJUT',
    AppLanguage.hebrew: 'הבא',
  },
  'settings': {
    AppLanguage.italian: 'IMPOSTAZIONI',
    AppLanguage.english: 'SETTINGS',
    AppLanguage.spanish: 'AJUSTES',
    AppLanguage.french: 'PARAMÈTRES',
    AppLanguage.german: 'EINSTELLUNGEN',
    AppLanguage.portuguese: 'CONFIGURAÇÕES',
    AppLanguage.dutch: 'INSTELLINGEN',
    AppLanguage.polish: 'USTAWIENIA',
    AppLanguage.romanian: 'SETĂRI',
    AppLanguage.turkish: 'AYARLAR',
    AppLanguage.russian: 'НАСТРОЙКИ',
    AppLanguage.japanese: 'せってい',
    AppLanguage.korean: '설정',
    AppLanguage.chinese: '设置',
    AppLanguage.arabic: 'الإعدادات',
    AppLanguage.hindi: 'सेटिंग्स',
    AppLanguage.ukrainian: 'НАЛАШТУВАННЯ',
    AppLanguage.chineseTraditional: '設定',
    AppLanguage.indonesian: 'PENGATURAN',
    AppLanguage.hebrew: 'הגדרות',
  },
  'sounds': {
    AppLanguage.italian: 'Suoni',
    AppLanguage.english: 'Sounds',
    AppLanguage.spanish: 'Sonidos',
    AppLanguage.french: 'Sons',
    AppLanguage.german: 'Töne',
    AppLanguage.portuguese: 'Sons',
    AppLanguage.dutch: 'Geluiden',
    AppLanguage.polish: 'Dźwięki',
    AppLanguage.romanian: 'Sunete',
    AppLanguage.turkish: 'Sesler',
    AppLanguage.russian: 'Звуки',
    AppLanguage.japanese: 'サウンド',
    AppLanguage.korean: '소리',
    AppLanguage.chinese: '声音',
    AppLanguage.arabic: 'الأصوات',
    AppLanguage.hindi: 'ध्वनियाँ',
    AppLanguage.ukrainian: 'Звуки',
    AppLanguage.chineseTraditional: '聲音',
    AppLanguage.indonesian: 'Suara',
    AppLanguage.hebrew: 'צלילים',
  },
  'vibration': {
    AppLanguage.italian: 'Vibrazione',
    AppLanguage.english: 'Vibration',
    AppLanguage.spanish: 'Vibración',
    AppLanguage.french: 'Vibration',
    AppLanguage.german: 'Vibration',
    AppLanguage.portuguese: 'Vibração',
    AppLanguage.dutch: 'Trillen',
    AppLanguage.polish: 'Wibracja',
    AppLanguage.romanian: 'Vibrație',
    AppLanguage.turkish: 'Titreşim',
    AppLanguage.russian: 'Вибрация',
    AppLanguage.japanese: 'バイブレーション',
    AppLanguage.korean: '진동',
    AppLanguage.chinese: '振动',
    AppLanguage.arabic: 'الاهتزاز',
    AppLanguage.hindi: 'वाइब्रेशन',
    AppLanguage.ukrainian: 'Вібрація',
    AppLanguage.chineseTraditional: '震動',
    AppLanguage.indonesian: 'Getaran',
    AppLanguage.hebrew: 'רטט',
  },
  'language': {
    AppLanguage.italian: 'Lingua',
    AppLanguage.english: 'Language',
    AppLanguage.spanish: 'Idioma',
    AppLanguage.french: 'Langue',
    AppLanguage.german: 'Sprache',
    AppLanguage.portuguese: 'Idioma',
    AppLanguage.dutch: 'Taal',
    AppLanguage.polish: 'Język',
    AppLanguage.romanian: 'Limbă',
    AppLanguage.turkish: 'Dil',
    AppLanguage.russian: 'Язык',
    AppLanguage.japanese: '言語',
    AppLanguage.korean: '언어',
    AppLanguage.chinese: '语言',
    AppLanguage.arabic: 'اللغة',
    AppLanguage.hindi: 'भाषा',
    AppLanguage.ukrainian: 'Мова',
    AppLanguage.chineseTraditional: '語言',
    AppLanguage.indonesian: 'Bahasa',
    AppLanguage.hebrew: 'שפה',
  },
  'howToPlayTooltip': {
    AppLanguage.italian: 'Come si gioca',
    AppLanguage.english: 'How to play',
    AppLanguage.spanish: 'Cómo jugar',
    AppLanguage.french: 'Comment jouer',
    AppLanguage.german: 'So spielt man',
    AppLanguage.portuguese: 'Como jogar',
    AppLanguage.dutch: 'Hoe speel je',
    AppLanguage.polish: 'Jak grać',
    AppLanguage.romanian: 'Cum se joacă',
    AppLanguage.turkish: 'Nasıl oynanır',
    AppLanguage.russian: 'Как играть',
    AppLanguage.japanese: 'あそびかた',
    AppLanguage.korean: '플레이 방법',
    AppLanguage.chinese: '玩法说明',
    AppLanguage.arabic: 'كيفية اللعب',
    AppLanguage.hindi: 'कैसे खेलें',
    AppLanguage.ukrainian: 'Як грати',
    AppLanguage.chineseTraditional: '玩法說明',
    AppLanguage.indonesian: 'Cara bermain',
    AppLanguage.hebrew: 'איך משחקים',
  },
  'settingsTooltip': {
    AppLanguage.italian: 'Impostazioni',
    AppLanguage.english: 'Settings',
    AppLanguage.spanish: 'Ajustes',
    AppLanguage.french: 'Paramètres',
    AppLanguage.german: 'Einstellungen',
    AppLanguage.portuguese: 'Configurações',
    AppLanguage.dutch: 'Instellingen',
    AppLanguage.polish: 'Ustawienia',
    AppLanguage.romanian: 'Setări',
    AppLanguage.turkish: 'Ayarlar',
    AppLanguage.russian: 'Настройки',
    AppLanguage.japanese: 'せってい',
    AppLanguage.korean: '설정',
    AppLanguage.chinese: '设置',
    AppLanguage.arabic: 'الإعدادات',
    AppLanguage.hindi: 'सेटिंग्स',
    AppLanguage.ukrainian: 'Налаштування',
    AppLanguage.chineseTraditional: '設定',
    AppLanguage.indonesian: 'Pengaturan',
    AppLanguage.hebrew: 'הגדרות',
  },
  'homeSubtitle': {
    AppLanguage.italian: 'Libera tutte le api nell’ordine giusto.',
    AppLanguage.english: 'Free all the bees in the right order.',
    AppLanguage.spanish: 'Libera a todas las abejas en el orden correcto.',
    AppLanguage.french: 'Libère toutes les abeilles dans le bon ordre.',
    AppLanguage.german: 'Befreie alle Bienen in der richtigen Reihenfolge.',
    AppLanguage.portuguese: 'Liberte todas as abelhas na ordem correta.',
    AppLanguage.dutch: 'Bevrijd alle bijen in de juiste volgorde.',
    AppLanguage.polish: 'Uwolnij wszystkie pszczoły we właściwej kolejności.',
    AppLanguage.romanian: 'Eliberează toate albinele în ordinea corectă.',
    AppLanguage.turkish: 'Tüm arıları doğru sırayla çıkar.',
    AppLanguage.russian: 'Освободи всех пчёл в правильном порядке.',
    AppLanguage.japanese: '正しい順番ですべてのハチを外に出そう。',
    AppLanguage.korean: '올바른 순서로 모든 벌을 내보내세요.',
    AppLanguage.chinese: '按正确顺序放飞所有蜜蜂。',
    AppLanguage.arabic: 'حرر جميع النحل بالترتيب الصحيح.',
    AppLanguage.hindi: 'सभी मधुमक्खियों को सही क्रम में बाहर निकालो।',
    AppLanguage.ukrainian: 'Випусти всіх бджіл у правильному порядку.',
    AppLanguage.chineseTraditional: '按正確順序放飛所有蜜蜂。',
    AppLanguage.indonesian: 'Bebaskan semua lebah dalam urutan yang benar.',
    AppLanguage.hebrew: 'שחררו את כל הדבורים בסדר הנכון.',
  },
  'progress': {
    AppLanguage.italian: 'PROGRESSO',
    AppLanguage.english: 'PROGRESS',
    AppLanguage.spanish: 'PROGRESO',
    AppLanguage.french: 'PROGRESSION',
    AppLanguage.german: 'FORTSCHRITT',
    AppLanguage.portuguese: 'PROGRESSO',
    AppLanguage.dutch: 'VOORTGANG',
    AppLanguage.polish: 'POSTĘP',
    AppLanguage.romanian: 'PROGRES',
    AppLanguage.turkish: 'İLERLEME',
    AppLanguage.russian: 'ПРОГРЕСС',
    AppLanguage.japanese: 'しんちょく',
    AppLanguage.korean: '진행도',
    AppLanguage.chinese: '进度',
    AppLanguage.arabic: 'التقدم',
    AppLanguage.hindi: 'प्रगति',
    AppLanguage.ukrainian: 'ПРОГРЕС',
    AppLanguage.chineseTraditional: '進度',
    AppLanguage.indonesian: 'PROGRES',
    AppLanguage.hebrew: 'התקדמות',
  },
  'level': {
    AppLanguage.italian: 'Livello',
    AppLanguage.english: 'Level',
    AppLanguage.spanish: 'Nivel',
    AppLanguage.french: 'Niveau',
    AppLanguage.german: 'Level',
    AppLanguage.portuguese: 'Nível',
    AppLanguage.dutch: 'Niveau',
    AppLanguage.polish: 'Poziom',
    AppLanguage.romanian: 'Nivel',
    AppLanguage.turkish: 'Seviye',
    AppLanguage.russian: 'Уровень',
    AppLanguage.japanese: 'レベル',
    AppLanguage.korean: '레벨',
    AppLanguage.chinese: '关卡',
    AppLanguage.arabic: 'المستوى',
    AppLanguage.hindi: 'स्तर',
    AppLanguage.ukrainian: 'Рівень',
    AppLanguage.chineseTraditional: '關卡',
    AppLanguage.indonesian: 'Level',
    AppLanguage.hebrew: 'שלב',
  },
  'levelUpper': {
    AppLanguage.italian: 'LIVELLO',
    AppLanguage.english: 'LEVEL',
    AppLanguage.spanish: 'NIVEL',
    AppLanguage.french: 'NIVEAU',
    AppLanguage.german: 'LEVEL',
    AppLanguage.portuguese: 'NÍVEL',
    AppLanguage.dutch: 'NIVEAU',
    AppLanguage.polish: 'POZIOM',
    AppLanguage.romanian: 'NIVEL',
    AppLanguage.turkish: 'SEVİYE',
    AppLanguage.russian: 'УРОВЕНЬ',
    AppLanguage.japanese: 'レベル',
    AppLanguage.korean: '레벨',
    AppLanguage.chinese: '关卡',
    AppLanguage.arabic: 'المستوى',
    AppLanguage.hindi: 'स्तर',
    AppLanguage.ukrainian: 'РІВЕНЬ',
    AppLanguage.chineseTraditional: '關卡',
    AppLanguage.indonesian: 'LEVEL',
    AppLanguage.hebrew: 'שלב',
  },
  'completedLevels': {
    AppLanguage.italian: 'Livelli completati',
    AppLanguage.english: 'Completed levels',
    AppLanguage.spanish: 'Niveles completados',
    AppLanguage.french: 'Niveaux terminés',
    AppLanguage.german: 'Abgeschlossene Level',
    AppLanguage.portuguese: 'Níveis concluídos',
    AppLanguage.dutch: 'Voltooide levels',
    AppLanguage.polish: 'Ukończone poziomy',
    AppLanguage.romanian: 'Niveluri finalizate',
    AppLanguage.turkish: 'Tamamlanan seviyeler',
    AppLanguage.russian: 'Пройденные уровни',
    AppLanguage.japanese: 'クリアしたレベル',
    AppLanguage.korean: '완료한 레벨',
    AppLanguage.chinese: '已完成关卡',
    AppLanguage.arabic: 'المستويات المكتملة',
    AppLanguage.hindi: 'पूरे किए गए स्तर',
    AppLanguage.ukrainian: 'Пройдені рівні',
    AppLanguage.chineseTraditional: '已完成關卡',
    AppLanguage.indonesian: 'Level selesai',
    AppLanguage.hebrew: 'שלבים שהושלמו',
  },
  'play': {
    AppLanguage.italian: 'GIOCA',
    AppLanguage.english: 'PLAY',
    AppLanguage.spanish: 'JUGAR',
    AppLanguage.french: 'JOUER',
    AppLanguage.german: 'SPIELEN',
    AppLanguage.portuguese: 'JOGAR',
    AppLanguage.dutch: 'SPELEN',
    AppLanguage.polish: 'GRAJ',
    AppLanguage.romanian: 'JOACĂ',
    AppLanguage.turkish: 'OYNA',
    AppLanguage.russian: 'ИГРАТЬ',
    AppLanguage.japanese: 'プレイ',
    AppLanguage.korean: '플레이',
    AppLanguage.chinese: '开始',
    AppLanguage.arabic: 'العب',
    AppLanguage.hindi: 'खेलें',
    AppLanguage.ukrainian: 'ГРАТИ',
    AppLanguage.chineseTraditional: '開始',
    AppLanguage.indonesian: 'MAIN',
    AppLanguage.hebrew: 'שחקו',
  },
  'tapFree': {
    AppLanguage.italian: 'Tocca un’ape con la strada libera.',
    AppLanguage.english: 'Tap a bee with a clear path.',
    AppLanguage.spanish: 'Toca una abeja que tenga el camino libre.',
    AppLanguage.french: 'Touchez une abeille qui a le passage libre.',
    AppLanguage.german: 'Tippe auf eine Biene mit freiem Weg.',
    AppLanguage.portuguese: 'Toque em uma abelha com o caminho livre.',
    AppLanguage.dutch: 'Tik op een bij met een vrije weg.',
    AppLanguage.polish: 'Dotknij pszczoły, która ma wolną drogę.',
    AppLanguage.romanian: 'Atinge o albină care are drumul liber.',
    AppLanguage.turkish: 'Yolu açık olan bir arıya dokun.',
    AppLanguage.russian: 'Нажми на пчелу со свободным путём.',
    AppLanguage.japanese: '道があいているハチをタップしよう。',
    AppLanguage.korean: '길이 열린 벌을 탭하세요.',
    AppLanguage.chinese: '点击一只前方路线畅通的蜜蜂。',
    AppLanguage.arabic: 'اضغط على نحلة طريقها مفتوح.',
    AppLanguage.hindi: 'उस मधुमक्खी को छुओ जिसका रास्ता साफ़ है।',
    AppLanguage.ukrainian: 'Натисни на бджолу з вільним шляхом.',
    AppLanguage.chineseTraditional: '點擊一隻前方路線暢通的蜜蜂。',
    AppLanguage.indonesian: 'Ketuk lebah yang jalurnya bebas.',
    AppLanguage.hebrew: 'לחצו על דבורה שהדרך שלה פנויה.',
  },
  'perfect': {
    AppLanguage.italian: 'Perfetto! 🐝💨',
    AppLanguage.english: 'Perfect! 🐝💨',
    AppLanguage.spanish: '¡Perfecto! 🐝💨',
    AppLanguage.french: 'Parfait ! 🐝💨',
    AppLanguage.german: 'Perfekt! 🐝💨',
    AppLanguage.portuguese: 'Perfeito! 🐝💨',
    AppLanguage.dutch: 'Perfect! 🐝💨',
    AppLanguage.polish: 'Perfekcyjnie! 🐝💨',
    AppLanguage.romanian: 'Perfect! 🐝💨',
    AppLanguage.turkish: 'Harika! 🐝💨',
    AppLanguage.russian: 'Отлично! 🐝💨',
    AppLanguage.japanese: 'かんぺき！🐝💨',
    AppLanguage.korean: '완벽해요! 🐝💨',
    AppLanguage.chinese: '太棒了！🐝💨',
    AppLanguage.arabic: 'ممتاز! 🐝💨',
    AppLanguage.hindi: 'बहुत बढ़िया! 🐝💨',
    AppLanguage.ukrainian: 'Чудово! 🐝💨',
    AppLanguage.chineseTraditional: '太棒了！🐝💨',
    AppLanguage.indonesian: 'Sempurna! 🐝💨',
    AppLanguage.hebrew: 'מושלם! 🐝💨',
  },
  'beesHoney': {
    AppLanguage.italian: 'Le api tornano al miele! 🍯',
    AppLanguage.english: 'The bees are flying to the honey! 🍯',
    AppLanguage.spanish: '¡Las abejas vuelan hacia la miel! 🍯',
    AppLanguage.french: 'Les abeilles volent vers le miel ! 🍯',
    AppLanguage.german: 'Die Bienen fliegen zum Honig! 🍯',
    AppLanguage.portuguese: 'As abelhas estão voando para o mel! 🍯',
    AppLanguage.dutch: 'De bijen vliegen naar de honing! 🍯',
    AppLanguage.polish: 'Pszczoły lecą do miodu! 🍯',
    AppLanguage.romanian: 'Albinele zboară spre miere! 🍯',
    AppLanguage.turkish: 'Arılar bala uçuyor! 🍯',
    AppLanguage.russian: 'Пчёлы летят к мёду! 🍯',
    AppLanguage.japanese: 'ハチたちがはちみつへ飛んでいくよ！🍯',
    AppLanguage.korean: '벌들이 꿀로 날아가고 있어요! 🍯',
    AppLanguage.chinese: '蜜蜂正飞向蜂蜜！🍯',
    AppLanguage.arabic: 'النحل يطير نحو العسل! 🍯',
    AppLanguage.hindi: 'मधुमक्खियाँ शहद की ओर उड़ रही हैं! 🍯',
    AppLanguage.ukrainian: 'Бджоли летять до меду! 🍯',
    AppLanguage.chineseTraditional: '蜜蜂正飛向蜂蜜！🍯',
    AppLanguage.indonesian: 'Lebah terbang menuju madu! 🍯',
    AppLanguage.hebrew: 'הדבורים עפות אל הדבש! 🍯',
  },
  'hiveFreed': {
    AppLanguage.italian: 'Alveare liberato!',
    AppLanguage.english: 'Hive cleared!',
    AppLanguage.spanish: '¡Colmena liberada!',
    AppLanguage.french: 'Ruche libérée !',
    AppLanguage.german: 'Bienenstock befreit!',
    AppLanguage.portuguese: 'Colmeia liberada!',
    AppLanguage.dutch: 'Bijenkorf bevrijd!',
    AppLanguage.polish: 'Ul uwolniony!',
    AppLanguage.romanian: 'Stup eliberat!',
    AppLanguage.turkish: 'Kovan boşaltıldı!',
    AppLanguage.russian: 'Улей освобождён!',
    AppLanguage.japanese: 'ハチの巣クリア！',
    AppLanguage.korean: '벌집을 비웠어요!',
    AppLanguage.chinese: '蜂巢清空啦！',
    AppLanguage.arabic: 'تم تحرير الخلية!',
    AppLanguage.hindi: 'छत्ता खाली हो गया!',
    AppLanguage.ukrainian: 'Вулик звільнено!',
    AppLanguage.chineseTraditional: '蜂巢清空啦！',
    AppLanguage.indonesian: 'Sarang berhasil dikosongkan!',
    AppLanguage.hebrew: 'הכוורת פונתה!',
  },
  'noAttempts': {
    AppLanguage.italian: 'Nessun tentativo rimasto.',
    AppLanguage.english: 'No tries left.',
    AppLanguage.spanish: 'No quedan intentos.',
    AppLanguage.french: 'Plus d’essais restants.',
    AppLanguage.german: 'Keine Versuche mehr übrig.',
    AppLanguage.portuguese: 'Não restam tentativas.',
    AppLanguage.dutch: 'Geen pogingen meer over.',
    AppLanguage.polish: 'Brak prób.',
    AppLanguage.romanian: 'Nu mai sunt încercări.',
    AppLanguage.turkish: 'Hiç deneme kalmadı.',
    AppLanguage.russian: 'Попытки закончились.',
    AppLanguage.japanese: 'もうチャレンジできないよ。',
    AppLanguage.korean: '남은 시도가 없어요.',
    AppLanguage.chinese: '没有剩余尝试次数了。',
    AppLanguage.arabic: 'لا توجد محاولات متبقية.',
    AppLanguage.hindi: 'अब कोई प्रयास नहीं बचा।',
    AppLanguage.ukrainian: 'Спроб більше немає.',
    AppLanguage.chineseTraditional: '沒有剩餘嘗試次數了。',
    AppLanguage.indonesian: 'Tidak ada percobaan tersisa.',
    AppLanguage.hebrew: 'לא נשארו ניסיונות.',
  },
  'blocked': {
    AppLanguage.italian: 'Bloccata! Cerca un’altra uscita.',
    AppLanguage.english: 'Blocked! Try another bee.',
    AppLanguage.spanish: '¡Bloqueada! Prueba con otra abeja.',
    AppLanguage.french: 'Bloquée ! Essaie une autre abeille.',
    AppLanguage.german: 'Blockiert! Probiere eine andere Biene.',
    AppLanguage.portuguese: 'Bloqueada! Tente outra abelha.',
    AppLanguage.dutch: 'Geblokkeerd! Probeer een andere bij.',
    AppLanguage.polish: 'Zablokowana! Spróbuj innej pszczoły.',
    AppLanguage.romanian: 'Blocată! Încearcă o altă albină.',
    AppLanguage.turkish: 'Engelli! Başka bir arı dene.',
    AppLanguage.russian: 'Заблокировано! Попробуй другую пчелу.',
    AppLanguage.japanese: 'ふさがっているよ！べつのハチを試してみよう。',
    AppLanguage.korean: '막혀 있어요! 다른 벌을 눌러 보세요.',
    AppLanguage.chinese: '被挡住了！试试别的蜜蜂。',
    AppLanguage.arabic: 'المسار مغلق! جرّب نحلة أخرى.',
    AppLanguage.hindi: 'रास्ता बंद है! दूसरी मधुमक्खी आज़माओ।',
    AppLanguage.ukrainian: 'Шлях заблоковано! Спробуй іншу бджолу.',
    AppLanguage.chineseTraditional: '被擋住了！試試別的蜜蜂。',
    AppLanguage.indonesian: 'Terhalang! Coba lebah lain.',
    AppLanguage.hebrew: 'הדרך חסומה! נסו דבורה אחרת.',
  },
  'hintUsedOne': {
    AppLanguage.italian: '💡 Suggerimento usato: 1',
    AppLanguage.english: '💡 Hint used: 1',
    AppLanguage.spanish: '💡 Pista usada: 1',
    AppLanguage.french: '💡 Indice utilisé : 1',
    AppLanguage.german: '💡 Hinweis benutzt: 1',
    AppLanguage.portuguese: '💡 Dica usada: 1',
    AppLanguage.dutch: '💡 Hint gebruikt: 1',
    AppLanguage.polish: '💡 Użyta podpowiedź: 1',
    AppLanguage.romanian: '💡 Indiciu folosit: 1',
    AppLanguage.turkish: '💡 İpucu kullanıldı: 1',
    AppLanguage.russian: '💡 Подсказка использована: 1',
    AppLanguage.japanese: '💡 ヒントを1回使ったよ',
    AppLanguage.korean: '💡 힌트 사용: 1',
    AppLanguage.chinese: '💡 已使用提示：1',
    AppLanguage.arabic: '💡 تم استخدام تلميح: 1',
    AppLanguage.hindi: '💡 संकेत उपयोग: 1',
    AppLanguage.ukrainian: '💡 Використано підказку: 1',
    AppLanguage.chineseTraditional: '💡 已使用提示：1',
    AppLanguage.indonesian: '💡 Petunjuk digunakan: 1',
    AppLanguage.hebrew: '💡 רמזים בשימוש: 1',
  },
  'hintsUsed': {
    AppLanguage.italian: '💡 Suggerimenti usati: {count}',
    AppLanguage.english: '💡 Hints used: {count}',
    AppLanguage.spanish: '💡 Pistas usadas: {count}',
    AppLanguage.french: '💡 Indices utilisés : {count}',
    AppLanguage.german: '💡 Hinweise benutzt: {count}',
    AppLanguage.portuguese: '💡 Dicas usadas: {count}',
    AppLanguage.dutch: '💡 Hints gebruikt: {count}',
    AppLanguage.polish: '💡 Użyte podpowiedzi: {count}',
    AppLanguage.romanian: '💡 Indicii folosite: {count}',
    AppLanguage.turkish: '💡 Kullanılan ipuçları: {count}',
    AppLanguage.russian: '💡 Использовано подсказок: {count}',
    AppLanguage.japanese: '💡 ヒント使用回数: {count}',
    AppLanguage.korean: '💡 사용한 힌트: {count}',
    AppLanguage.chinese: '💡 已使用提示：{count}',
    AppLanguage.arabic: '💡 التلميحات المستخدمة: {count}',
    AppLanguage.hindi: '💡 उपयोग किए गए संकेत: {count}',
    AppLanguage.ukrainian: '💡 Використано підказок: {count}',
    AppLanguage.chineseTraditional: '💡 已使用提示：{count}',
    AppLanguage.indonesian: '💡 Petunjuk digunakan: {count}',
    AppLanguage.hebrew: '💡 רמזים בשימוש: {count}',
  },
  'restartLevel': {
    AppLanguage.italian: 'Ricomincia livello',
    AppLanguage.english: 'Restart level',
    AppLanguage.spanish: 'Reiniciar nivel',
    AppLanguage.french: 'Recommencer le niveau',
    AppLanguage.german: 'Level neu starten',
    AppLanguage.portuguese: 'Reiniciar nível',
    AppLanguage.dutch: 'Level opnieuw starten',
    AppLanguage.polish: 'Zacznij poziom od nowa',
    AppLanguage.romanian: 'Repornește nivelul',
    AppLanguage.turkish: 'Seviyeyi yeniden başlat',
    AppLanguage.russian: 'Начать уровень заново',
    AppLanguage.japanese: 'レベルをやりなおす',
    AppLanguage.korean: '레벨 다시 시작',
    AppLanguage.chinese: '重新开始关卡',
    AppLanguage.arabic: 'أعد تشغيل المستوى',
    AppLanguage.hindi: 'स्तर फिर से शुरू करें',
    AppLanguage.ukrainian: 'Почати рівень заново',
    AppLanguage.chineseTraditional: '重新開始關卡',
    AppLanguage.indonesian: 'Mulai ulang level',
    AppLanguage.hebrew: 'התחילו את השלב מחדש',
  },
  'remaining': {
    AppLanguage.italian: 'RIMASTE',
    AppLanguage.english: 'LEFT',
    AppLanguage.spanish: 'QUEDAN',
    AppLanguage.french: 'RESTANTES',
    AppLanguage.german: 'ÜBRIG',
    AppLanguage.portuguese: 'RESTANTES',
    AppLanguage.dutch: 'OVER',
    AppLanguage.polish: 'POZOSTAŁO',
    AppLanguage.romanian: 'RĂMASE',
    AppLanguage.turkish: 'KALAN',
    AppLanguage.russian: 'ОСТАЛОСЬ',
    AppLanguage.japanese: 'のこり',
    AppLanguage.korean: '남음',
    AppLanguage.chinese: '剩余',
    AppLanguage.arabic: 'المتبقي',
    AppLanguage.hindi: 'बची',
    AppLanguage.ukrainian: 'ЗАЛИШИЛОСЬ',
    AppLanguage.chineseTraditional: '剩餘',
    AppLanguage.indonesian: 'TERSISA',
    AppLanguage.hebrew: 'נשארו',
  },
  'errors': {
    AppLanguage.italian: 'ERRORI',
    AppLanguage.english: 'ERRORS',
    AppLanguage.spanish: 'ERRORES',
    AppLanguage.french: 'ERREURS',
    AppLanguage.german: 'FEHLER',
    AppLanguage.portuguese: 'ERROS',
    AppLanguage.dutch: 'FOUTEN',
    AppLanguage.polish: 'BŁĘDY',
    AppLanguage.romanian: 'GREȘELI',
    AppLanguage.turkish: 'HATALAR',
    AppLanguage.russian: 'ОШИБКИ',
    AppLanguage.japanese: 'ミス',
    AppLanguage.korean: '실수',
    AppLanguage.chinese: '错误',
    AppLanguage.arabic: 'الأخطاء',
    AppLanguage.hindi: 'गलतियाँ',
    AppLanguage.ukrainian: 'ПОМИЛКИ',
    AppLanguage.chineseTraditional: '錯誤',
    AppLanguage.indonesian: 'KESALAHAN',
    AppLanguage.hebrew: 'טעויות',
  },
  'hiveFreedTitle': {
    AppLanguage.italian: 'ALVEARE LIBERATO! 🎉',
    AppLanguage.english: 'HIVE CLEARED! 🎉',
    AppLanguage.spanish: '¡COLMENA LIBERADA! 🎉',
    AppLanguage.french: 'RUCHE LIBÉRÉE ! 🎉',
    AppLanguage.german: 'BIENENSTOCK BEFREIT! 🎉',
    AppLanguage.portuguese: 'COLMEIA LIBERADA! 🎉',
    AppLanguage.dutch: 'BIJENKORF BEVRIJD! 🎉',
    AppLanguage.polish: 'UL UWOLNIONY! 🎉',
    AppLanguage.romanian: 'STUP ELIBERAT! 🎉',
    AppLanguage.turkish: 'KOVAN BOŞALTILDI! 🎉',
    AppLanguage.russian: 'УЛЕЙ ОСВОБОЖДЁН! 🎉',
    AppLanguage.japanese: 'ハチの巣クリア！🎉',
    AppLanguage.korean: '벌집을 비웠어요! 🎉',
    AppLanguage.chinese: '蜂巢清空啦！🎉',
    AppLanguage.arabic: 'تم تحرير الخلية! 🎉',
    AppLanguage.hindi: 'छत्ता खाली हो गया! 🎉',
    AppLanguage.ukrainian: 'ВУЛИК ЗВІЛЬНЕНО! 🎉',
    AppLanguage.chineseTraditional: '蜂巢清空啦！🎉',
    AppLanguage.indonesian: 'SARANG KOSONG! 🎉',
    AppLanguage.hebrew: 'הכוורת פונתה! 🎉',
  },
  'perfectLevel': {
    AppLanguage.italian: 'Livello perfetto: nessun errore e nessun suggerimento.',
    AppLanguage.english: 'Perfect level: no mistakes and no hints.',
    AppLanguage.spanish: 'Nivel perfecto: sin errores y sin pistas.',
    AppLanguage.french: 'Niveau parfait : aucune erreur et aucun indice.',
    AppLanguage.german: 'Perfektes Level: keine Fehler und keine Hinweise.',
    AppLanguage.portuguese: 'Nível perfeito: sem erros e sem dicas.',
    AppLanguage.dutch: 'Perfect level: geen fouten en geen hints.',
    AppLanguage.polish: 'Perfekcyjny poziom: bez błędów i bez podpowiedzi.',
    AppLanguage.romanian: 'Nivel perfect: fără greșeli și fără indicii.',
    AppLanguage.turkish: 'Mükemmel seviye: hata yok, ipucu yok.',
    AppLanguage.russian: 'Идеальный уровень: без ошибок и без подсказок.',
    AppLanguage.japanese: 'パーフェクト！ミスもヒントもなし。',
    AppLanguage.korean: '완벽한 레벨: 실수도 힌트도 없어요.',
    AppLanguage.chinese: '完美过关：没有错误，也没有使用提示。',
    AppLanguage.arabic: 'مستوى مثالي: بلا أخطاء وبلا تلميحات.',
    AppLanguage.hindi: 'परफेक्ट स्तर: न गलती, न संकेत।',
    AppLanguage.ukrainian: 'Ідеальний рівень: без помилок і без підказок.',
    AppLanguage.chineseTraditional: '完美過關：沒有錯誤，也沒有使用提示。',
    AppLanguage.indonesian: 'Level sempurna: tanpa kesalahan dan tanpa petunjuk.',
    AppLanguage.hebrew: 'שלב מושלם: בלי טעויות ובלי רמזים.',
  },
  'errorsHints': {
    AppLanguage.italian: 'Errori: {errors} · Suggerimenti: {hints}',
    AppLanguage.english: 'Errors: {errors} · Hints: {hints}',
    AppLanguage.spanish: 'Errores: {errors} · Pistas: {hints}',
    AppLanguage.french: 'Erreurs : {errors} · Indices : {hints}',
    AppLanguage.german: 'Fehler: {errors} · Hinweise: {hints}',
    AppLanguage.portuguese: 'Erros: {errors} · Dicas: {hints}',
    AppLanguage.dutch: 'Fouten: {errors} · Hints: {hints}',
    AppLanguage.polish: 'Błędy: {errors} · Podpowiedzi: {hints}',
    AppLanguage.romanian: 'Greșeli: {errors} · Indicii: {hints}',
    AppLanguage.turkish: 'Hatalar: {errors} · İpuçları: {hints}',
    AppLanguage.russian: 'Ошибки: {errors} · Подсказки: {hints}',
    AppLanguage.japanese: 'ミス: {errors} ・ ヒント: {hints}',
    AppLanguage.korean: '실수: {errors} · 힌트: {hints}',
    AppLanguage.chinese: '错误：{errors} · 提示：{hints}',
    AppLanguage.arabic: 'الأخطاء: {errors} · التلميحات: {hints}',
    AppLanguage.hindi: 'गलतियाँ: {errors} · संकेत: {hints}',
    AppLanguage.ukrainian: 'Помилки: {errors} · Підказки: {hints}',
    AppLanguage.chineseTraditional: '錯誤：{errors} · 提示：{hints}',
    AppLanguage.indonesian: 'Kesalahan: {errors} · Petunjuk: {hints}',
    AppLanguage.hebrew: 'טעויות: {errors} · רמזים: {hints}',
  },
  'nextLevel': {
    AppLanguage.italian: 'PROSSIMO LIVELLO',
    AppLanguage.english: 'NEXT LEVEL',
    AppLanguage.spanish: 'SIGUIENTE NIVEL',
    AppLanguage.french: 'NIVEAU SUIVANT',
    AppLanguage.german: 'NÄCHSTES LEVEL',
    AppLanguage.portuguese: 'PRÓXIMO NÍVEL',
    AppLanguage.dutch: 'VOLGEND LEVEL',
    AppLanguage.polish: 'NASTĘPNY POZIOM',
    AppLanguage.romanian: 'NIVELUL URMĂTOR',
    AppLanguage.turkish: 'SONRAKİ SEVİYE',
    AppLanguage.russian: 'СЛЕДУЮЩИЙ УРОВЕНЬ',
    AppLanguage.japanese: 'つぎのレベル',
    AppLanguage.korean: '다음 레벨',
    AppLanguage.chinese: '下一关',
    AppLanguage.arabic: 'المستوى التالي',
    AppLanguage.hindi: 'अगला स्तर',
    AppLanguage.ukrainian: 'НАСТУПНИЙ РІВЕНЬ',
    AppLanguage.chineseTraditional: '下一關',
    AppLanguage.indonesian: 'LEVEL BERIKUTNYA',
    AppLanguage.hebrew: 'השלב הבא',
  },
  'almost': {
    AppLanguage.italian: 'QUASI! 🐝',
    AppLanguage.english: 'ALMOST! 🐝',
    AppLanguage.spanish: '¡CASI! 🐝',
    AppLanguage.french: 'PRESQUE ! 🐝',
    AppLanguage.german: 'FAST! 🐝',
    AppLanguage.portuguese: 'QUASE! 🐝',
    AppLanguage.dutch: 'BIJNA! 🐝',
    AppLanguage.polish: 'PRAWIE! 🐝',
    AppLanguage.romanian: 'APROAPE! 🐝',
    AppLanguage.turkish: 'AZ KALDI! 🐝',
    AppLanguage.russian: 'ПОЧТИ! 🐝',
    AppLanguage.japanese: 'おしい！🐝',
    AppLanguage.korean: '거의 다 왔어요! 🐝',
    AppLanguage.chinese: '差一点！🐝',
    AppLanguage.arabic: 'أوشكت! 🐝',
    AppLanguage.hindi: 'लगभग! 🐝',
    AppLanguage.ukrainian: 'МАЙЖЕ! 🐝',
    AppLanguage.chineseTraditional: '差一點！🐝',
    AppLanguage.indonesian: 'HAMPIR! 🐝',
    AppLanguage.hebrew: 'כמעט! 🐝',
  },
  'threeTriesUsed': {
    AppLanguage.italian: 'Hai esaurito i 3 tentativi.',
    AppLanguage.english: 'You used all 3 tries.',
    AppLanguage.spanish: 'Has agotado los 3 intentos.',
    AppLanguage.french: 'Tu as utilisé tes 3 essais.',
    AppLanguage.german: 'Du hast alle 3 Versuche verbraucht.',
    AppLanguage.portuguese: 'Você usou as 3 tentativas.',
    AppLanguage.dutch: 'Je hebt alle 3 pogingen gebruikt.',
    AppLanguage.polish: 'Wykorzystałeś 3 próby.',
    AppLanguage.romanian: 'Ai folosit toate cele 3 încercări.',
    AppLanguage.turkish: '3 denemenin hepsini kullandın.',
    AppLanguage.russian: 'Ты использовал все 3 попытки.',
    AppLanguage.japanese: '3回のチャレンジを使い切ったよ。',
    AppLanguage.korean: '3번의 시도를 모두 사용했어요.',
    AppLanguage.chinese: '你已经用完 3 次尝试机会。',
    AppLanguage.arabic: 'لقد استنفدت المحاولات الثلاث.',
    AppLanguage.hindi: 'आपने 3ों प्रयास इस्तेमाल कर लिए हैं।',
    AppLanguage.ukrainian: 'Ти використав усі 3 спроби.',
    AppLanguage.chineseTraditional: '你已經用完 3 次嘗試機會。',
    AppLanguage.indonesian: 'Kamu sudah memakai semua 3 percobaan.',
    AppLanguage.hebrew: 'ניצלתם את כל 3 הניסיונות.',
  },
  'retry': {
    AppLanguage.italian: 'RIPROVA',
    AppLanguage.english: 'TRY AGAIN',
    AppLanguage.spanish: 'INTENTAR DE NUEVO',
    AppLanguage.french: 'RÉESSAYER',
    AppLanguage.german: 'NOCH EINMAL',
    AppLanguage.portuguese: 'TENTAR NOVAMENTE',
    AppLanguage.dutch: 'OPNIEUW PROBEREN',
    AppLanguage.polish: 'SPRÓBUJ PONOWNIE',
    AppLanguage.romanian: 'ÎNCEARCĂ DIN NOU',
    AppLanguage.turkish: 'TEKRAR DENE',
    AppLanguage.russian: 'ПОПРОБОВАТЬ СНОВА',
    AppLanguage.japanese: 'もういちど',
    AppLanguage.korean: '다시 시도',
    AppLanguage.chinese: '再试一次',
    AppLanguage.arabic: 'أعد المحاولة',
    AppLanguage.hindi: 'फिर कोशिश करें',
    AppLanguage.ukrainian: 'СПРОБУВАТИ ЗНОВУ',
    AppLanguage.chineseTraditional: '再試一次',
    AppLanguage.indonesian: 'COBA LAGI',
    AppLanguage.hebrew: 'נסו שוב',
  },
  'hint': {
    AppLanguage.italian: 'SUGGERIMENTO',
    AppLanguage.english: 'HINT',
    AppLanguage.spanish: 'PISTA',
    AppLanguage.french: 'INDICE',
    AppLanguage.german: 'HINWEIS',
    AppLanguage.portuguese: 'DICA',
    AppLanguage.dutch: 'HINT',
    AppLanguage.polish: 'PODPOWIEDŹ',
    AppLanguage.romanian: 'INDICIU',
    AppLanguage.turkish: 'İPUCU',
    AppLanguage.russian: 'ПОДСКАЗКА',
    AppLanguage.japanese: 'ヒント',
    AppLanguage.korean: '힌트',
    AppLanguage.chinese: '提示',
    AppLanguage.arabic: 'تلميح',
    AppLanguage.hindi: 'संकेत',
    AppLanguage.ukrainian: 'ПІДКАЗКА',
    AppLanguage.chineseTraditional: '提示',
    AppLanguage.indonesian: 'PETUNJUK',
    AppLanguage.hebrew: 'רמז',
  },
  'loadingAd': {
    AppLanguage.italian: 'Caricamento annuncio...',
    AppLanguage.english: 'Loading ad...',
    AppLanguage.spanish: 'Cargando anuncio...',
    AppLanguage.french: 'Chargement de la publicité...',
    AppLanguage.german: 'Werbung wird geladen...',
    AppLanguage.portuguese: 'Carregando anúncio...',
    AppLanguage.dutch: 'Advertentie laden...',
    AppLanguage.polish: 'Ładowanie reklamy...',
    AppLanguage.romanian: 'Se încarcă reclama...',
    AppLanguage.turkish: 'Reklam yükleniyor...',
    AppLanguage.russian: 'Загрузка рекламы...',
    AppLanguage.japanese: '広告を読み込み中...',
    AppLanguage.korean: '광고 불러오는 중...',
    AppLanguage.chinese: '广告加载中...',
    AppLanguage.arabic: 'جارٍ تحميل الإعلان...',
    AppLanguage.hindi: 'विज्ञापन लोड हो रहा है...',
    AppLanguage.ukrainian: 'Завантаження реклами...',
    AppLanguage.chineseTraditional: '廣告載入中...',
    AppLanguage.indonesian: 'Memuat iklan...',
    AppLanguage.hebrew: 'הפרסומת נטענת...',
  },
};

String tr(
  String key, {
  Map<String, Object> values = const <String, Object>{},
}) {
  var text = _translations[key]?[currentAppLanguage] ??
      _translations[key]?[AppLanguage.italian] ??
      key;

  for (final entry in values.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value.toString());
  }

  return text;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive Escape è progettato per il gioco in verticale.
  // Blocchiamo l'intera app in portrait per evitare overflow e layout
  // non utilizzabili quando il dispositivo viene ruotato in orizzontale.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final preferences = await SharedPreferences.getInstance();
  final savedLanguage = preferences.getString(_languagePreferenceKey);

  if (savedLanguage != null) {
    currentAppLanguage = _languageFromCode(savedLanguage);
  } else {
    final phoneLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final phoneLanguage = phoneLocale.languageCode.toLowerCase();

    if (phoneLanguage == 'zh' &&
        (phoneLocale.scriptCode == 'Hant' ||
            phoneLocale.countryCode == 'TW' ||
            phoneLocale.countryCode == 'HK' ||
            phoneLocale.countryCode == 'MO')) {
      currentAppLanguage = AppLanguage.chineseTraditional;
    } else {
      currentAppLanguage = _languageFromCode(phoneLanguage);
    }
  }

  appLanguageNotifier.value = currentAppLanguage;

  // Finché non conosciamo la fascia d'età, usiamo la configurazione
  // più prudente e NON richiediamo annunci.
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      ageRestrictedTreatment: AgeRestrictedTreatment.child,
      maxAdContentRating: MaxAdContentRating.g,
    ),
  );

  runApp(const HiveEscapeApp());
}

class HiveEscapeApp extends StatelessWidget {
  const HiveEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguageNotifier,
      builder: (context, language, child) {
        currentAppLanguage = language;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: tr('appName'),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFB300),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFFF6C9),
          ),
          builder: (context, child) {
            return Directionality(
              textDirection:
                  isCurrentLanguageRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const HomePage(),
        );
      },
    );
  }
}


enum GameDifficulty {
  easy,
  medium,
  hard,
}

extension GameDifficultyInfo on GameDifficulty {
  String get key {
    switch (this) {
      case GameDifficulty.easy:
        return 'easy';
      case GameDifficulty.medium:
        return 'medium';
      case GameDifficulty.hard:
        return 'hard';
    }
  }

  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return tr('easy');
      case GameDifficulty.medium:
        return tr('medium');
      case GameDifficulty.hard:
        return tr('hard');
    }
  }

  String get icon {
    switch (this) {
      case GameDifficulty.easy:
        return '🟢';
      case GameDifficulty.medium:
        return '🟡';
      case GameDifficulty.hard:
        return '🔴';
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _legacyProgressKey = 'hive_escape_current_level';
  static const String _difficultyMigrationKey =
      'hive_escape_difficulty_migrated_v1';
  static const String _selectedDifficultyKey =
      'hive_escape_selected_difficulty';

  GameDifficulty selectedDifficulty = GameDifficulty.easy;
  int currentLevel = 1;
  int? selectedCompletedLevel;
  Map<int, int> completedLevelStars = <int, int>{};
  Map<int, int?> completedLevelHints = <int, int?>{};

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  UserAgeGroup? selectedAgeGroup;

  static const String _soundEnabledKey = 'hive_escape_sound_enabled';
  static const String _vibrationEnabledKey = 'hive_escape_vibration_enabled';
  static const String _tutorialCompletedKey =
      'hive_escape_tutorial_completed_v1';

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
    _loadHomeSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInitialPrivacyFlow();
    });
  }

  Future<void> _runInitialPrivacyFlow() async {
    await _ensureAgeGroupSelected();

    if (!mounted || selectedAgeGroup == null) {
      return;
    }

    await refreshConsentAndAdsForAge(selectedAgeGroup!);

    if (!mounted) {
      return;
    }

    await _showTutorialIfNeeded();
  }

  Future<void> _ensureAgeGroupSelected() async {
    final preferences = await SharedPreferences.getInstance();
    final savedAgeGroup = UserAgeGroupInfo.fromKey(
      preferences.getString(_ageGroupPreferenceKey),
    );

    if (savedAgeGroup != null) {
      selectedAgeGroup = savedAgeGroup;
      await applyAgeAdConfiguration(savedAgeGroup);
      return;
    }

    if (!mounted) {
      return;
    }

    final selected = await _openAgePicker(
      canDismiss: false,
    );

    if (selected == null) {
      return;
    }

    await preferences.setString(
      _ageGroupPreferenceKey,
      selected.key,
    );

    selectedAgeGroup = selected;
    await applyAgeAdConfiguration(selected);

    if (mounted) {
      setState(() {});
    }
  }

  Future<UserAgeGroup?> _openAgePicker({
    required bool canDismiss,
  }) async {
    return showDialog<UserAgeGroup>(
      context: context,
      barrierDismissible: canDismiss,
      builder: (dialogContext) {
        Widget ageButton({
          required UserAgeGroup ageGroup,
          required String emoji,
          required String label,
        }) {
          final selected = selectedAgeGroup == ageGroup;

          return SizedBox(
            width: double.infinity,
            height: 58,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(ageGroup);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    selected ? const Color(0xFFFFE48B) : Colors.white,
                foregroundColor: const Color(0xFF6E3E00),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFFFFB300)
                      : const Color(0xFFFFD36B),
                  width: selected ? 2 : 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return PopScope(
          canPop: canDismiss,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6C9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFD36B),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 42,
                    color: Color(0xFFE07A00),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ageTr('title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6E3E00),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ageTr('question'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6E3E00),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ageTr('note'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Color(0xFF8A5A00),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ageButton(
                    ageGroup: UserAgeGroup.child,
                    emoji: '🐝',
                    label: ageTr('child'),
                  ),
                  const SizedBox(height: 9),
                  ageButton(
                    ageGroup: UserAgeGroup.teen,
                    emoji: '🌼',
                    label: ageTr('teen'),
                  ),
                  const SizedBox(height: 9),
                  ageButton(
                    ageGroup: UserAgeGroup.adult,
                    emoji: '🍯',
                    label: ageTr('adult'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeAgeGroup() async {
    final selected = await _openAgePicker(
      canDismiss: true,
    );

    if (selected == null) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _ageGroupPreferenceKey,
      selected.key,
    );

    selectedAgeGroup = selected;
    await applyAgeAdConfiguration(selected);
    await refreshConsentAndAdsForAge(selected);

    if (mounted) {
      setState(() {});
    }
  }

  String get _selectedAgeLabel {
    switch (selectedAgeGroup) {
      case UserAgeGroup.child:
        return ageTr('child');
      case UserAgeGroup.teen:
        return ageTr('teen');
      case UserAgeGroup.adult:
        return ageTr('adult');
      case null:
        return ageTr('question');
    }
  }

  Future<void> _showTutorialIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    final completed = preferences.getBool(_tutorialCompletedKey) ?? false;

    if (completed || !mounted) {
      return;
    }

    await _openFirstLaunchTutorial();
  }

  Future<void> _openFirstLaunchTutorial() async {
    final pageController = PageController();
    var currentPage = 0;

    final pages = <({String emoji, String title, String text})>[
      (
        emoji: '🐝',
        title: tr('lookArrow'),
        text: tr('lookArrowText'),
      ),
      (
        emoji: '🚧',
        title: tr('checkPath'),
        text: tr('checkPathText'),
      ),
      (
        emoji: '🍯',
        title: tr('freeHive'),
        text: tr('freeHiveText'),
      ),
    ];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 520,
                ),
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6C9),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFD36B),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      tr('howToPlay'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFFE07A00),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pages.length,
                        onPageChanged: (index) {
                          setDialogState(() {
                            currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final page = pages[index];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC93C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFA800),
                                    width: 2.5,
                                  ),
                                ),
                                child: Text(
                                  page.emoji,
                                  style: const TextStyle(fontSize: 58),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF6E3E00),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                page.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.45,
                                  color: Color(0xFF8A5A00),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == currentPage ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentPage
                                ? const Color(0xFFFFB300)
                                : const Color(0xFFFFC94A),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () async {
                          if (currentPage < pages.length - 1) {
                            await pageController.nextPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                            );
                            return;
                          }

                          final preferences =
                              await SharedPreferences.getInstance();
                          await preferences.setBool(
                            _tutorialCompletedKey,
                            true,
                          );

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: const Color(0xFF5A2F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          currentPage == pages.length - 1
                              ? tr('startPlaying')
                              : tr('next'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    pageController.dispose();
  }

  Future<void> _loadHomeSettings() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      soundEnabled = preferences.getBool(_soundEnabledKey) ?? true;
      vibrationEnabled = preferences.getBool(_vibrationEnabledKey) ?? true;
    });
  }

  Future<void> _setHomeSoundEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_soundEnabledKey, value);

    if (!mounted) {
      return;
    }

    setState(() {
      soundEnabled = value;
    });
  }

  Future<void> _setHomeVibrationEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_vibrationEnabledKey, value);

    if (!mounted) {
      return;
    }

    setState(() {
      vibrationEnabled = value;
    });
  }

  Future<void> _setHomeLanguage(AppLanguage language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languagePreferenceKey, language.code);

    currentAppLanguage = language;
    appLanguageNotifier.value = language;

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _openLanguagePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF6C9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC94A),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        color: Color(0xFFE07A00),
                        size: 28,
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          tr('language').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Color(0xFF6E3E00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFFD36B),
                          ),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: AppLanguage.values.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final language = AppLanguage.values[index];

                              return ListTile(
                                leading: Text(
                                  language.flag,
                                  style: const TextStyle(fontSize: 27),
                                ),
                                title: Text(
                                  language.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                trailing: currentAppLanguage == language
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFFFB300),
                                      )
                                    : const Icon(
                                        Icons.circle_outlined,
                                        color: Color(0xFFFFD36B),
                                      ),
                                onTap: () async {
                                  if (language != currentAppLanguage) {
                                    await _setHomeLanguage(language);
                                  }

                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openHomeSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFF6C9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC94A),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr('settings'),
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Color(0xFF6E3E00),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFFD36B),
                          ),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: soundEnabled,
                              secondary: Icon(
                                soundEnabled
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                color: const Color(0xFFE07A00),
                              ),
                              title: Text(
                                tr('sounds'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onChanged: (value) async {
                                setModalState(() {
                                  soundEnabled = value;
                                });
                                await _setHomeSoundEnabled(value);
                              },
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              value: vibrationEnabled,
                              secondary: const Icon(
                                Icons.vibration_rounded,
                                color: Color(0xFFE07A00),
                              ),
                              title: Text(
                                tr('vibration'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onChanged: (value) async {
                                setModalState(() {
                                  vibrationEnabled = value;
                                });
                                await _setHomeVibrationEnabled(value);
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.shield_outlined,
                                color: Color(0xFFE07A00),
                              ),
                              title: Text(
                                ageTr('title'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                _selectedAgeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFE07A00),
                              ),
                              onTap: () async {
                                Navigator.of(sheetContext).pop();
                                await _changeAgeGroup();
                              },
                            ),
                            if (privacyOptionsRequiredNotifier.value) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(
                                  Icons.privacy_tip_outlined,
                                  color: Color(0xFFE07A00),
                                ),
                                title: Text(
                                  privacyTr('privacyChoices'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: Text(
                                  privacyTr('privacyChoicesSubtitle'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFE07A00),
                                ),
                                onTap: () async {
                                  Navigator.of(sheetContext).pop();
                                  await showPrivacyOptionsAndRefreshAds();

                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _progressKey(GameDifficulty difficulty) =>
      'hive_escape_${difficulty.key}_current_level';

  String _starsKey(GameDifficulty difficulty, int level) =>
      'hive_escape_${difficulty.key}_level_${level}_stars';

  String _hintsKey(GameDifficulty difficulty, int level) =>
      'hive_escape_${difficulty.key}_level_${level}_hints';

  String _legacyStarsKey(int level) => 'hive_escape_level_${level}_stars';

  String _legacyHintsKey(int level) => 'hive_escape_level_${level}_hints';

  String _starsText(int stars) {
    final safeStars = stars.clamp(0, 3);
    return '${'★' * safeStars}${'☆' * (3 - safeStars)}';
  }

  Future<void> _migrateExistingProgressToEasy(
    SharedPreferences preferences,
  ) async {
    final alreadyMigrated =
        preferences.getBool(_difficultyMigrationKey) ?? false;

    if (alreadyMigrated) {
      return;
    }

    final legacyLevel = preferences.getInt(_legacyProgressKey) ?? 1;
    final safeLegacyLevel = legacyLevel < 1 ? 1 : legacyLevel;

    await preferences.setInt(
      _progressKey(GameDifficulty.easy),
      safeLegacyLevel,
    );

    for (var level = 1; level <= safeLegacyLevel; level++) {
      final legacyStars = preferences.getInt(_legacyStarsKey(level));
      final legacyHints = preferences.getInt(_legacyHintsKey(level));

      if (legacyStars != null && legacyStars > 0) {
        await preferences.setInt(
          _starsKey(GameDifficulty.easy, level),
          legacyStars.clamp(1, 3),
        );
        await preferences.setInt(
          _hintsKey(GameDifficulty.easy, level),
          legacyHints ?? 0,
        );
      }
    }

    await preferences.setInt(
      _progressKey(GameDifficulty.medium),
      preferences.getInt(_progressKey(GameDifficulty.medium)) ?? 1,
    );
    await preferences.setInt(
      _progressKey(GameDifficulty.hard),
      preferences.getInt(_progressKey(GameDifficulty.hard)) ?? 1,
    );

    await preferences.setBool(_difficultyMigrationKey, true);
  }

  Future<void> _loadSavedProgress() async {
    final preferences = await SharedPreferences.getInstance();

    await _migrateExistingProgressToEasy(preferences);

    final savedDifficultyKey =
        preferences.getString(_selectedDifficultyKey) ?? 'easy';

    final loadedDifficulty = GameDifficulty.values.firstWhere(
      (difficulty) => difficulty.key == savedDifficultyKey,
      orElse: () => GameDifficulty.easy,
    );

    final difficulty =
        selectedDifficulty == GameDifficulty.easy &&
                savedDifficultyKey != 'easy' &&
                currentLevel == 1 &&
                completedLevelStars.isEmpty
            ? loadedDifficulty
            : selectedDifficulty;

    final savedLevel = preferences.getInt(_progressKey(difficulty)) ?? 1;
    final safeLevel = savedLevel < 1 ? 1 : savedLevel;

    final loadedStars = <int, int>{};
    final loadedHints = <int, int?>{};

    for (var level = 1; level <= safeLevel; level++) {
      final stars = preferences.getInt(_starsKey(difficulty, level)) ?? 0;

      if (stars > 0) {
        loadedStars[level] = stars.clamp(1, 3);
        loadedHints[level] =
            preferences.getInt(_hintsKey(difficulty, level)) ?? 0;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedDifficulty = difficulty;
      currentLevel = safeLevel;
      completedLevelStars = loadedStars;
      completedLevelHints = loadedHints;
      selectedCompletedLevel = null;
    });
  }

  Future<void> _changeDifficulty(GameDifficulty difficulty) async {
    if (difficulty == selectedDifficulty) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedDifficultyKey, difficulty.key);

    if (!mounted) {
      return;
    }

    setState(() {
      selectedDifficulty = difficulty;
      currentLevel = 1;
      completedLevelStars = <int, int>{};
      completedLevelHints = <int, int?>{};
      selectedCompletedLevel = null;
    });

    await _loadSavedProgress();
  }

  Future<void> _saveProgress(
    GameDifficulty difficulty,
    int level,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final key = _progressKey(difficulty);
    final savedLevel = preferences.getInt(key) ?? 1;

    if (level > savedLevel) {
      await preferences.setInt(key, level);
    }
  }

  Future<void> _openGame({int? level}) async {
    final difficultyToPlay = selectedDifficulty;
    final levelToPlay = level ?? currentLevel;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePage(
          initialLevel: levelToPlay,
          difficulty: difficultyToPlay,
          onLevelChanged: (newLevel) async {
            if (difficultyToPlay == selectedDifficulty &&
                newLevel > currentLevel) {
              setState(() {
                currentLevel = newLevel;
              });
            }

            await _saveProgress(difficultyToPlay, newLevel);
          },
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      selectedCompletedLevel = null;
    });

    await _loadSavedProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: tr('howToPlayTooltip'),
                                onPressed: _openFirstLaunchTutorial,
                                icon: const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFFB35A00),
                                ),
                              ),
                              IconButton(
                                tooltip: tr('language'),
                                onPressed: _openLanguagePicker,
                                icon: const Icon(
                                  Icons.language_rounded,
                                  color: Color(0xFFB35A00),
                                ),
                              ),
                              IconButton(
                                tooltip: tr('settingsTooltip'),
                                onPressed: _openHomeSettings,
                                icon: const Icon(
                                  Icons.settings_rounded,
                                  color: Color(0xFFB35A00),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC93C),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: const Color(0xFFFFA800),
                              width: 3,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '🐝',
                            style: TextStyle(fontSize: 72),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          tr('appName'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Color(0xFF6E3E00),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tr('homeSubtitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.35,
                            color: Color(0xFF8A5A00),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFFFD36B),
                            ),
                          ),
                          child: Row(
                            children: GameDifficulty.values.map((difficulty) {
                              final selected = difficulty == selectedDifficulty;

                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: SizedBox(
                                    height: 44,
                                    child: selected
                                        ? FilledButton(
                                            onPressed: () =>
                                                _changeDifficulty(difficulty),
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFFB300),
                                              foregroundColor:
                                                  const Color(0xFF5A2F00),
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              '${difficulty.icon} ${difficulty.label}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          )
                                        : TextButton(
                                            onPressed: () =>
                                                _changeDifficulty(difficulty),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF8A5A00),
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              '${difficulty.icon} ${difficulty.label}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFFFD36B),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2BF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '🏆',
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tr('progress')} · ${selectedDifficulty.label}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF9A864F),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${tr('level')} $currentLevel',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF6E3E00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (completedLevelStars.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.fromLTRB(16, 10, 12, 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFFFD36B),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedCompletedLevel,
                                hint: Text(
                                  tr('completedLevels'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF5F5235),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF8C742E),
                                ),
                                items:
                                    completedLevelStars.entries.map((entry) {
                                  return DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Row(
                                      children: [
                                        Text(
                                          '${tr('level')} ${entry.key}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF6E3E00),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _starsText(entry.value),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            letterSpacing: 1.5,
                                            color: Color(0xFFFFB300),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '💡 ${completedLevelHints[entry.key]?.toString() ?? '0'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF8A5A00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (level) {
                                  if (level == null) {
                                    return;
                                  }

                                  setState(() {
                                    selectedCompletedLevel = level;
                                  });

                                  _openGame(level: level);
                                },
                              ),
                            ),
                          ),
                        if (completedLevelStars.isNotEmpty)
                          const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: FilledButton(
                            onPressed: () => _openGame(),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB300),
                              foregroundColor: const Color(0xFF5A2F00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              tr('play'),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
          child: const _AdMobBanner(),
        ),
      ),
    );
  }
}

enum BeeDirection {
  up,
  right,
  down,
  left,
}

class BeePiece {
  const BeePiece({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
  });

  final int id;
  final int row;
  final int col;
  final BeeDirection direction;
}

class LevelData {
  const LevelData({
    required this.number,
    required this.gridSize,
    required this.bees,
  });

  final int number;
  final int gridSize;
  final List<BeePiece> bees;
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.initialLevel,
    required this.difficulty,
    required this.onLevelChanged,
  });

  final int initialLevel;
  final GameDifficulty difficulty;
  final ValueChanged<int> onLevelChanged;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late int levelNumber;
  late LevelData level;

  final Set<int> removedBeeIds = <int>{};

  int errors = 0;
  int hintsUsed = 0;
  int? highlightedBeeId;
  int? flyingBeeId;
  bool completionCelebration = false;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool levelCompleted = false;
  bool levelFailed = false;

  InterstitialAd? _milestoneInterstitialAd;
  bool _milestoneInterstitialLoading = false;
  int? _milestoneInterstitialForLevel;

  static const int _interstitialEveryLevels = 5;
  static const String _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _androidProductionInterstitialId =
      'ca-app-pub-2076419085002638/1889509698';

  String get _androidInterstitialId => kReleaseMode
      ? _androidProductionInterstitialId
      : _androidTestInterstitialId;

  static const String _soundEnabledKey = 'hive_escape_sound_enabled';
  static const String _vibrationEnabledKey = 'hive_escape_vibration_enabled';
  String statusText = tr('tapFree');

  Timer? hintTimer;

  final AudioPlayer _feedbackPlayer = AudioPlayer();
  late final Uint8List _errorSoundBytes;

  @override
  void initState() {
    super.initState();
    _errorSoundBytes = _buildErrorToneWav();
    unawaited(_configureFeedbackAudio());
    levelNumber = widget.initialLevel;
    adRequestsAllowedNotifier.addListener(
      _handleInterstitialAdPermissionChanged,
    );
    _loadLevel();
    _loadGameSettings();
    _prepareMilestoneInterstitialIfNeeded();
  }

  Future<void> _configureFeedbackAudio() async {
    try {
      await _feedbackPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await _feedbackPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (error) {
      debugPrint('Errore configurazione audio: $error');
    }
  }

  Future<void> _loadGameSettings() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      soundEnabled = preferences.getBool(_soundEnabledKey) ?? true;
      vibrationEnabled = preferences.getBool(_vibrationEnabledKey) ?? true;
    });
  }

  @override
  void dispose() {
    hintTimer?.cancel();
    adRequestsAllowedNotifier.removeListener(
      _handleInterstitialAdPermissionChanged,
    );
    _milestoneInterstitialAd?.dispose();
    _milestoneInterstitialAd = null;
    unawaited(_feedbackPlayer.dispose());
    super.dispose();
  }

  bool get _isCurrentLevelInterstitialMilestone =>
      levelNumber > 0 &&
      levelNumber % _interstitialEveryLevels == 0;

  int? get _interstitialMilestoneToPrepare {
    if (levelNumber <= 0) {
      return null;
    }

    if (_isCurrentLevelInterstitialMilestone) {
      return levelNumber;
    }

    final nextLevel = levelNumber + 1;

    if (nextLevel % _interstitialEveryLevels == 0) {
      return nextLevel;
    }

    return null;
  }

  bool _isInterstitialPreparationStillUseful(int milestoneLevel) =>
      levelNumber == milestoneLevel ||
      levelNumber == milestoneLevel - 1;

  String _milestoneInterstitialShownKey(int level) =>
      'hive_escape_${widget.difficulty.key}_interstitial_v2_level_$level';

  void _handleInterstitialAdPermissionChanged() {
    if (!adRequestsAllowedNotifier.value) {
      _milestoneInterstitialAd?.dispose();
      _milestoneInterstitialAd = null;
      _milestoneInterstitialForLevel = null;
      _milestoneInterstitialLoading = false;
      return;
    }

    _prepareMilestoneInterstitialIfNeeded();
  }

  Future<void> _prepareMilestoneInterstitialIfNeeded() async {
    if (!Platform.isAndroid ||
        !mounted ||
        !adRequestsAllowedNotifier.value) {
      return;
    }

    final milestoneLevel = _interstitialMilestoneToPrepare;

    if (milestoneLevel == null) {
      return;
    }

    if (_milestoneInterstitialAd != null &&
        _milestoneInterstitialForLevel == milestoneLevel) {
      return;
    }

    if (_milestoneInterstitialLoading) {
      return;
    }

    if (_milestoneInterstitialAd != null) {
      _milestoneInterstitialAd?.dispose();
      _milestoneInterstitialAd = null;
      _milestoneInterstitialForLevel = null;
    }

    final preferences = await SharedPreferences.getInstance();

    if (!mounted ||
        !adRequestsAllowedNotifier.value ||
        !_isInterstitialPreparationStillUseful(milestoneLevel) ||
        preferences.getBool(
              _milestoneInterstitialShownKey(milestoneLevel),
            ) ==
            true) {
      return;
    }

    _milestoneInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _androidInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _milestoneInterstitialLoading = false;

          if (!mounted ||
              !adRequestsAllowedNotifier.value ||
              !_isInterstitialPreparationStillUseful(milestoneLevel)) {
            ad.dispose();
            return;
          }

          _milestoneInterstitialAd = ad;
          _milestoneInterstitialForLevel = milestoneLevel;

          debugPrint(
            'Interstitial pronto per il livello $milestoneLevel '
            '(${kReleaseMode ? 'release' : 'test'}).',
          );
        },
        onAdFailedToLoad: (error) {
          _milestoneInterstitialLoading = false;
          _milestoneInterstitialAd = null;
          _milestoneInterstitialForLevel = null;

          debugPrint(
            'Interstitial load error ${error.code}: ${error.message}',
          );
        },
      ),
    );
  }

  Future<void> _showMilestoneInterstitialIfNeeded() async {
    if (!Platform.isAndroid ||
        !adRequestsAllowedNotifier.value ||
        !_isCurrentLevelInterstitialMilestone) {
      return;
    }

    final currentMilestoneLevel = levelNumber;
    final preferences = await SharedPreferences.getInstance();
    final shownKey =
        _milestoneInterstitialShownKey(currentMilestoneLevel);

    if (preferences.getBool(shownKey) == true) {
      return;
    }

    final ad = _milestoneInterstitialAd;

    if (ad == null ||
        _milestoneInterstitialForLevel != currentMilestoneLevel) {
      // Non blocchiamo mai il giocatore se l'annuncio non è pronto.
      return;
    }

    _milestoneInterstitialAd = null;
    _milestoneInterstitialForLevel = null;

    final completer = Completer<void>();

    ad.fullScreenContentCallback =
        FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (shownAd) {
        // Una sola visualizzazione per milestone e difficoltà.
        unawaited(preferences.setBool(shownKey, true));
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();

        debugPrint(
          'Interstitial show error ${error.code}: ${error.message}',
        );

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    ad.show();
    await completer.future;
  }

  void _loadLevel() {
    hintTimer?.cancel();
    level = LevelGenerator.generate(levelNumber, widget.difficulty);
    removedBeeIds.clear();
    errors = 0;
    hintsUsed = 0;
    highlightedBeeId = null;
    flyingBeeId = null;
    completionCelebration = false;
    levelCompleted = false;
    levelFailed = false;
    statusText = tr('tapFree');
  }

  List<BeePiece> get activeBees => level.bees
      .where((bee) => !removedBeeIds.contains(bee.id))
      .toList(growable: false);

  String _starsKey(int level) =>
      'hive_escape_${widget.difficulty.key}_level_${level}_stars';

  String _hintsKey(int level) =>
      'hive_escape_${widget.difficulty.key}_level_${level}_hints';

  int get _earnedStars {
    final penalty = max(errors, hintsUsed);

    if (penalty <= 0) {
      return 3;
    }

    if (penalty == 1) {
      return 2;
    }

    return 1;
  }

  Future<void> _saveBestStarsForCurrentLevel() async {
    final earnedStars = _earnedStars;
    final preferences = await SharedPreferences.getInstance();
    final starsKey = _starsKey(levelNumber);
    final hintsKey = _hintsKey(levelNumber);

    final previousBestStars = preferences.getInt(starsKey) ?? 0;
    final previousBestHints = preferences.getInt(hintsKey);

    final betterStars = earnedStars > previousBestStars;
    final sameStarsButFewerHints =
        earnedStars == previousBestStars &&
        (previousBestHints == null || hintsUsed < previousBestHints);

    if (betterStars || sameStarsButFewerHints) {
      await preferences.setInt(starsKey, earnedStars);
      await preferences.setInt(hintsKey, hintsUsed);
    }
  }

  bool _canExit(BeePiece bee) {
    final occupied = <String>{};

    for (final other in activeBees) {
      if (other.id != bee.id) {
        occupied.add('${other.row}:${other.col}');
      }
    }

    var row = bee.row;
    var col = bee.col;

    while (true) {
      switch (bee.direction) {
        case BeeDirection.up:
          row--;
          break;
        case BeeDirection.right:
          col++;
          break;
        case BeeDirection.down:
          row++;
          break;
        case BeeDirection.left:
          col--;
          break;
      }

      if (row < 0 ||
          row >= level.gridSize ||
          col < 0 ||
          col >= level.gridSize) {
        return true;
      }

      if (occupied.contains('$row:$col')) {
        return false;
      }
    }
  }

  Uint8List _buildErrorToneWav() {
    const sampleRate = 44100;
    const durationMs = 340;
    const channels = 1;
    const bitsPerSample = 16;
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final dataLength = sampleCount * channels * (bitsPerSample ~/ 8);
    final bytes = ByteData(44 + dataLength);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataLength, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(
      28,
      sampleRate * channels * (bitsPerSample ~/ 8),
      Endian.little,
    );
    bytes.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);

    for (var i = 0; i < sampleCount; i++) {
      final time = i / sampleRate;
      final elapsedMs = (i * 1000.0) / sampleRate;

      // Due beep brevi e ben udibili sugli speaker degli smartphone.
      final inFirstPulse = elapsedMs < 135.0;
      final inSecondPulse = elapsedMs >= 175.0 && elapsedMs < 325.0;

      double envelope = 0.0;
      double frequency = 0.0;

      if (inFirstPulse) {
        final pulseProgress = elapsedMs / 135.0;
        envelope = pulseProgress < 0.08
            ? pulseProgress / 0.08
            : (1.0 - pulseProgress).clamp(0.0, 1.0);
        frequency = 1180.0;
      } else if (inSecondPulse) {
        final pulseProgress = (elapsedMs - 175.0) / 150.0;
        envelope = pulseProgress < 0.08
            ? pulseProgress / 0.08
            : (1.0 - pulseProgress).clamp(0.0, 1.0);
        frequency = 880.0;
      }

      if (frequency == 0.0) {
        bytes.setInt16(44 + (i * 2), 0, Endian.little);
        continue;
      }

      final fundamental = sin(2 * pi * frequency * time);
      final harmonic = sin(2 * pi * frequency * 2 * time) * 0.24;
      final wave = (fundamental + harmonic) / 1.24;
      final sample = (wave * envelope * 0.96 * 32767)
          .clamp(-32767.0, 32767.0)
          .round();
      bytes.setInt16(44 + (i * 2), sample, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  Future<void> _playWrongMoveFeedback() async {
    if (soundEnabled) {
      try {
        await _feedbackPlayer.stop();
        await _feedbackPlayer.play(
          BytesSource(_errorSoundBytes),
          volume: 1.0,
        );
      } catch (error) {
        debugPrint('Errore riproduzione suono: $error');
      }
    }

    if (vibrationEnabled) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          await Vibration.vibrate(duration: 220);
        }
      } catch (error) {
        debugPrint('Errore vibrazione: $error');
      }
    }
  }

  void _tapBee(BeePiece bee) {
    if (levelCompleted ||
        levelFailed ||
        completionCelebration ||
        flyingBeeId != null) {
      return;
    }

    if (_canExit(bee)) {
      if (vibrationEnabled) {
        HapticFeedback.lightImpact();
      }

      if (soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }

      setState(() {
        flyingBeeId = bee.id;
        highlightedBeeId = null;
        statusText = tr('perfect');
      });

      Future<void>.delayed(const Duration(milliseconds: 1050), () async {
        if (!mounted) {
          return;
        }

        setState(() {
          removedBeeIds.add(bee.id);
          flyingBeeId = null;
        });

        if (removedBeeIds.length == level.bees.length) {
          if (!mounted) {
            return;
          }

          setState(() {
            completionCelebration = true;
            statusText = tr('beesHoney');
          });

          await Future<void>.delayed(const Duration(milliseconds: 3500));

          if (!mounted) {
            return;
          }

          await _saveBestStarsForCurrentLevel();

          if (!mounted) {
            return;
          }

          if (soundEnabled) {
            SystemSound.play(SystemSoundType.click);
          }

          setState(() {
            completionCelebration = false;
            levelCompleted = true;
            statusText = tr('hiveFreed');
          });
        }
      });
    } else {
      unawaited(_playWrongMoveFeedback());

      setState(() {
        errors++;
        highlightedBeeId = bee.id;

        if (errors >= 3) {
          levelFailed = true;
          statusText = tr('noAttempts');
        } else {
          statusText = tr('blocked');
        }
      });

      hintTimer?.cancel();
      hintTimer = Timer(const Duration(milliseconds: 650), () {
        if (!mounted || levelCompleted || levelFailed) return;
        setState(() {
          highlightedBeeId = null;
        });
      });
    }
  }

  void _showHint() {
    if (levelCompleted || levelFailed || completionCelebration) {
      return;
    }

    BeePiece? candidate;

    for (final bee in activeBees) {
      if (_canExit(bee)) {
        candidate = bee;
        break;
      }
    }

    if (candidate == null) {
      return;
    }

    setState(() {
      hintsUsed++;
      highlightedBeeId = candidate!.id;
      statusText = hintsUsed == 1
          ? tr('hintUsedOne')
          : tr('hintsUsed', values: {'count': hintsUsed});
    });

    hintTimer?.cancel();
    hintTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || levelCompleted || levelFailed) return;
      setState(() {
        highlightedBeeId = null;
        statusText = tr('tapFree');
      });
    });
  }

  void _restartLevel() {
    setState(_loadLevel);
  }

  Future<void> _nextLevel() async {
    // Il giocatore ha già visto miele, festeggiamenti e stelle.
    // Ogni 5 livelli (5, 10, 15, 20...) mostriamo eventualmente
    // l'interstitial prima di entrare nel livello successivo.
    await _showMilestoneInterstitialIfNeeded();

    if (!mounted) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    var nextLevel = 1;

    while ((preferences.getInt(_starsKey(nextLevel)) ?? 0) > 0) {
      nextLevel++;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      levelNumber = nextLevel;
      widget.onLevelChanged(levelNumber);
      _loadLevel();
    });

    _prepareMilestoneInterstitialIfNeeded();
  }

  IconData _directionIcon(BeeDirection direction) {
    switch (direction) {
      case BeeDirection.up:
        return Icons.north_rounded;
      case BeeDirection.right:
        return Icons.east_rounded;
      case BeeDirection.down:
        return Icons.south_rounded;
      case BeeDirection.left:
        return Icons.west_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final boardWidth = min(size.width - 80, 440.0);
    final showResultLayout = levelCompleted || levelFailed;

    Widget buildInfoRow() {
      return Row(
        children: [
          Expanded(
            child: _InfoCard(
              icon: '🐝',
              label: tr('remaining'),
              value:
                  '${level.bees.length - removedBeeIds.length}/${level.bees.length}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoCard(
              icon: '❤️',
              label: tr('errors'),
              value: '$errors/3',
            ),
          ),
        ],
      );
    }

    Widget buildStatusCard() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6D5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFE9D58B),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          statusText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF62501D),
          ),
        ),
      );
    }

    Widget buildBoard(double currentBoardWidth) {
      const boardPadding = 12.0;
      final gap = level.gridSize >= 6 ? 5.0 : 7.0;
      final usableBoardWidth = currentBoardWidth - (boardPadding * 2);
      final cellSize =
          (usableBoardWidth - (gap * (level.gridSize - 1))) / level.gridSize;

      return Container(
        width: currentBoardWidth,
        height: currentBoardWidth,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5D76E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFD5A900),
            width: 3,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var row = 0; row < level.gridSize; row++)
              for (var col = 0; col < level.gridSize; col++)
                Positioned(
                  left: col * (cellSize + gap),
                  top: row * (cellSize + gap),
                  width: cellSize,
                  height: cellSize,
                  child: _buildGridCell(row, col),
                ),
            if (flyingBeeId != null)
              _buildCenterFlightOverlay(currentBoardWidth),
            if (completionCelebration)
              _buildHoneyCelebrationOverlay(currentBoardWidth),
          ],
        ),
      );
    }

    Widget buildResultPanel() {
      if (levelCompleted) {
        return _ResultPanel(
          title: tr('hiveFreedTitle'),
          subtitle: errors == 0 && hintsUsed == 0
              ? tr('perfectLevel')
              : tr(
                  'errorsHints',
                  values: {
                    'errors': errors,
                    'hints': hintsUsed,
                  },
                ),
          stars: _earnedStars,
          buttonText: tr('nextLevel'),
          onPressed: _nextLevel,
        );
      }

      return _ResultPanel(
        title: tr('almost'),
        subtitle: tr('threeTriesUsed'),
        buttonText: tr('retry'),
        onPressed: _restartLevel,
      );
    }

    Widget buildPlayingControls() {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showHint,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: const Color(0xFFB35A00),
                side: const BorderSide(
                  color: Color(0xFFFFB84D),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.lightbulb_rounded),
              label: Text(
                tr('hint'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _AdMobBanner(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '${widget.difficulty.label} · ${tr('levelUpper')} $levelNumber',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: tr('restartLevel'),
            onPressed: _restartLevel,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: showResultLayout
              ? Column(
                  children: [
                    buildInfoRow(),
                    const SizedBox(height: 16),
                    buildStatusCard(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compactBoardWidth = min(
                            boardWidth,
                            min(constraints.maxWidth, constraints.maxHeight),
                          );

                          return Center(
                            child: buildBoard(compactBoardWidth),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildResultPanel(),
                    const SizedBox(height: 4),
                  ],
                )
              : Column(
                  children: [
                    buildInfoRow(),
                    const SizedBox(height: 16),
                    buildStatusCard(),
                    const Spacer(),
                    Center(
                      child: buildBoard(boardWidth),
                    ),
                    const Spacer(),
                    buildPlayingControls(),
                  ],
                ),
        ),
      ),
    );
  }

  Offset _flightOffset(
    BeeDirection direction,
    double distance,
  ) {
    switch (direction) {
      case BeeDirection.up:
        return Offset(0, -distance);
      case BeeDirection.right:
        return Offset(distance, 0);
      case BeeDirection.down:
        return Offset(0, distance);
      case BeeDirection.left:
        return Offset(-distance, 0);
    }
  }

  Widget _buildCenterFlightOverlay(double boardWidth) {
    BeePiece? bee;

    for (final item in level.bees) {
      if (item.id == flyingBeeId) {
        bee = item;
        break;
      }
    }

    if (bee == null) {
      return const SizedBox.shrink();
    }

    final currentBee = bee;
    final flightOffset = _flightOffset(
      currentBee.direction,
      boardWidth * 1.35,
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<String>('center_flight_${currentBee.id}'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 980),
          curve: Curves.linear,
          builder: (context, progress, child) {
            // 0.00 - 0.30: l'ape compare al centro e si ingrandisce.
            // 0.30 - 1.00: parte nella direzione corretta e vola fuori.
            final launchProgress =
                ((progress - 0.30) / 0.70).clamp(0.0, 1.0);

            final scale = progress < 0.30
                ? 0.75 + (progress / 0.30) * 1.15
                : 1.90 - (launchProgress * 0.45);

            final opacity = progress < 0.84
                ? 1.0
                : (1 - ((progress - 0.84) / 0.16))
                    .clamp(0.0, 1.0);

            // Oscillazione rapida per simulare il battito delle ali.
            final flap = sin(progress * pi * 22);
            final bob = sin(progress * pi * 10) * 3.5;

            final directionRotation =
                currentBee.direction == BeeDirection.left ||
                        currentBee.direction == BeeDirection.down
                    ? -1.0
                    : 1.0;

            final arrowOpacity =
                progress < 0.34 ? (1 - (progress / 0.34)) : 0.0;

            return Transform.translate(
              offset: Offset(
                flightOffset.dx * launchProgress,
                (flightOffset.dy * launchProgress) + bob,
              ),
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: flap * 0.045 * directionRotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Ali aggiuntive animate dietro l'emoji per rendere
                        // visibile il battito anche su schermi piccoli.
                        Transform.translate(
                          offset: const Offset(-19, -7),
                          child: Transform.rotate(
                            angle: -0.55 - (flap * 0.22),
                            child: Transform.scale(
                              scaleY: 0.70 + ((flap + 1) * 0.16),
                              child: Container(
                                width: 21,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color(0xFFD9D4C7),
                                    width: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(19, -7),
                          child: Transform.rotate(
                            angle: 0.55 + (flap * 0.22),
                            child: Transform.scale(
                              scaleY: 0.70 + ((flap + 1) * 0.16),
                              child: Container(
                                width: 21,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color(0xFFD9D4C7),
                                    width: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          '🐝',
                          style: TextStyle(fontSize: 43),
                        ),
                        Positioned(
                          bottom: -27,
                          child: Opacity(
                            opacity: arrowOpacity,
                            child: Container(
                              width: 27,
                              height: 27,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3E351E),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _directionIcon(currentBee.direction),
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildGlassHoneyJar(double width, double height) {
    final bodyTop = height * 0.20;
    final bodyHeight = height * 0.72;
    final bodyWidth = width * 0.88;
    final bodyLeft = (width - bodyWidth) / 2;
    final glassRadius = width * 0.25;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Soft shadow below the glass jar.
        Positioned(
          left: width * 0.14,
          right: width * 0.14,
          bottom: height * 0.01,
          height: height * 0.10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),

        // Main transparent glass body.
        Positioned(
          left: bodyLeft,
          top: bodyTop,
          width: bodyWidth,
          height: bodyHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(glassRadius * 0.70),
                topRight: Radius.circular(glassRadius * 0.70),
                bottomLeft: Radius.circular(glassRadius),
                bottomRight: Radius.circular(glassRadius),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA000).withValues(alpha: 0.20),
                  blurRadius: 11,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(glassRadius * 0.62),
                topRight: Radius.circular(glassRadius * 0.62),
                bottomLeft: Radius.circular(glassRadius * 0.90),
                bottomRight: Radius.circular(glassRadius * 0.90),
              ),
              child: Stack(
                children: [
                  // Honey visible through the glass.
                  Positioned(
                    left: 3,
                    right: 3,
                    bottom: 3,
                    height: bodyHeight * 0.66,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFD74A),
                            Color(0xFFFFB300),
                            Color(0xFFF28C00),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(width * 0.12),
                          topRight: Radius.circular(width * 0.12),
                          bottomLeft: Radius.circular(glassRadius * 0.82),
                          bottomRight: Radius.circular(glassRadius * 0.82),
                        ),
                      ),
                    ),
                  ),

                  // Honey surface shine.
                  Positioned(
                    left: width * 0.10,
                    right: width * 0.10,
                    top: bodyHeight * 0.31,
                    height: height * 0.075,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE88A)
                            .withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  // Glass reflections.
                  Positioned(
                    left: bodyWidth * 0.15,
                    top: bodyHeight * 0.12,
                    width: bodyWidth * 0.10,
                    height: bodyHeight * 0.48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.56),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    right: bodyWidth * 0.13,
                    top: bodyHeight * 0.18,
                    width: bodyWidth * 0.06,
                    height: bodyHeight * 0.24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Glass neck.
        Positioned(
          top: height * 0.12,
          width: width * 0.60,
          height: height * 0.18,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(width * 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: 2,
              ),
            ),
          ),
        ),

        // Golden lid.
        Positioned(
          top: height * 0.055,
          width: width * 0.72,
          height: height * 0.15,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFC75A),
                  Color(0xFFE99112),
                ],
              ),
              borderRadius: BorderRadius.circular(width * 0.15),
              border: Border.all(
                color: const Color(0xFFC97808),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),

        // Small highlight on the lid.
        Positioned(
          top: height * 0.073,
          width: width * 0.48,
          height: height * 0.035,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE39A).withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoneyCelebrationOverlay(double boardWidth) {
    const boardPadding = 12.0;
    final gap = level.gridSize >= 6 ? 5.0 : 7.0;
    final usableBoardWidth = boardWidth - (boardPadding * 2);
    final cellSize =
        (usableBoardWidth - (gap * (level.gridSize - 1))) / level.gridSize;

    final targetRow = level.gridSize - 1;
    final targetCol = (level.gridSize - 1) ~/ 2;

    final jarCenterX =
        (targetCol * (cellSize + gap)) + (cellSize / 2);
    final jarCenterY =
        (targetRow * (cellSize + gap)) + (cellSize / 2);

    final jarWidth = cellSize * 1.48;
    final jarHeight = cellSize * 1.72;
    final jarSize = jarWidth;
    final totalBees = level.bees.length;

    Offset startPointForBee(int index) {
      final lane = index % 8;
      final spread = ((index * 37) % 100) / 100.0;
      final edgeInset = boardWidth * (0.08 + (spread * 0.84));

      switch (lane) {
        case 0:
          return Offset(edgeInset, -34);
        case 1:
          return Offset(boardWidth + 34, edgeInset);
        case 2:
          return Offset(edgeInset, boardWidth + 34);
        case 3:
          return Offset(-34, edgeInset);
        case 4:
          return Offset(-28, -28 + (spread * 45));
        case 5:
          return Offset(boardWidth + 28, -28 + (spread * 45));
        case 6:
          return Offset(boardWidth + 28, boardWidth - (spread * 45));
        default:
          return Offset(-28, boardWidth - (spread * 45));
      }
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<String>('honey_celebration_$levelNumber'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 3400),
          curve: Curves.linear,
          builder: (context, progress, child) {
            final jarAppear =
                (progress / 0.16).clamp(0.0, 1.0);
            final jarPulse =
                1.0 + (sin(progress * pi * 8) * 0.035 * jarAppear);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: jarCenterX - (jarWidth / 2),
                  top: jarCenterY - (jarHeight / 2),
                  width: jarWidth,
                  height: jarHeight,
                  child: Opacity(
                    opacity: jarAppear,
                    child: Transform.scale(
                      scale: jarPulse,
                      child: _buildGlassHoneyJar(
                        jarWidth,
                        jarHeight,
                      ),
                    ),
                  ),
                ),

                for (var index = 0; index < totalBees; index++)
                  Builder(
                    builder: (context) {
                      final start = startPointForBee(index);

                      // Bees enter gradually across most of the animation.
                      final stagger =
                          totalBees <= 1 ? 0.0 : (index / totalBees) * 0.48;
                      final localProgress =
                          ((progress - stagger) / 0.50).clamp(0.0, 1.0);

                      if (localProgress <= 0) {
                        return const SizedBox.shrink();
                      }

                      final eased = Curves.easeInOutCubic.transform(
                        localProgress,
                      );

                      // Small different landing points inside the honey jar.
                      final landingAngle =
                          (index * 2 * pi) / max(1, totalBees);
                      final landingRadius =
                          jarSize * (0.05 + ((index % 4) * 0.025));
                      final targetX =
                          jarCenterX + cos(landingAngle) * landingRadius;
                      final targetY =
                          jarCenterY + sin(landingAngle) * landingRadius;

                      final dx = targetX - start.dx;
                      final dy = targetY - start.dy;

                      // Curved flight: each bee bends slightly in a different
                      // direction instead of moving on one straight line.
                      final perpendicularX = -dy;
                      final perpendicularY = dx;
                      final distance =
                          sqrt((dx * dx) + (dy * dy)).clamp(1.0, double.infinity);
                      final curveSide = index.isEven ? 1.0 : -1.0;
                      final curveAmount =
                          sin(localProgress * pi) * 28 * curveSide;

                      final x = start.dx +
                          (dx * eased) +
                          ((perpendicularX / distance) * curveAmount);
                      final y = start.dy +
                          (dy * eased) +
                          ((perpendicularY / distance) * curveAmount);

                      final bob =
                          sin((localProgress * pi * 10) + index) * 3.0;

                      final opacity = localProgress < 0.83
                          ? 1.0
                          : (1 -
                                  ((localProgress - 0.83) / 0.17))
                              .clamp(0.0, 1.0);

                      final scale = localProgress < 0.16
                          ? 0.72 + ((localProgress / 0.16) * 0.35)
                          : 1.07 -
                              (((localProgress - 0.16) / 0.84) * 0.44);

                      return Positioned(
                        left: x - 16,
                        top: y - 16 + bob,
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.rotate(
                            angle:
                                sin((localProgress * pi * 8) + index) * 0.08,
                            child: Transform.scale(
                              scale: scale,
                              child: const Text(
                                '🐝',
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridCell(int row, int col) {
    BeePiece? bee;

    for (final item in level.bees) {
      if (item.row == row && item.col == col) {
        bee = item;
        break;
      }
    }

    if (bee == null || removedBeeIds.contains(bee.id)) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6C9),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    final BeePiece currentBee = bee;
    final isFlying = flyingBeeId == currentBee.id;

    if (isFlying) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6C9),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    final highlighted = highlightedBeeId == currentBee.id;
    final canExit = _canExit(currentBee);

    final shouldShake = highlighted && !canExit;

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(
        'shake_${currentBee.id}_${shouldShake ? errors : 0}',
      ),
      tween: Tween<double>(
        begin: 0,
        end: shouldShake ? 1 : 0,
      ),
      duration: shouldShake
          ? const Duration(milliseconds: 420)
          : Duration.zero,
      curve: Curves.easeOut,
      builder: (context, progress, child) {
        final shakeOffset = shouldShake
            ? sin(progress * pi * 9) * 7 * (1 - progress)
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: AnimatedScale(
        scale: highlighted ? 1.07 : 1,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: highlighted
              ? (canExit
                  ? const Color(0xFFC8F7A6)
                  : const Color(0xFFFFB0A5))
              : const Color(0xFFFFF6C9),
          borderRadius: BorderRadius.circular(14),
          elevation: highlighted ? 5 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: flyingBeeId == null ? () => _tapBee(currentBee) : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  '🐝',
                  style: TextStyle(fontSize: 29),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3E351E),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _directionIcon(currentBee.direction),
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFFD36B),
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9A864F),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6E3E00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    this.stars,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final int? stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE7D393),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6E3E00),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A5A00),
            ),
          ),
          if (stars != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 94,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _CelebrationBackdrop(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final earned = index < stars!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _AnimatedRewardStar(
                          earned: earned,
                          index: index,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: const Color(0xFF5A2F00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _AnimatedRewardStar extends StatefulWidget {
  const _AnimatedRewardStar({
    required this.earned,
    required this.index,
  });

  final bool earned;
  final int index;

  @override
  State<_AnimatedRewardStar> createState() => _AnimatedRewardStarState();
}


class _AnimatedRewardStarState extends State<_AnimatedRewardStar> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    if (!widget.earned) {
      _visible = true;
      return;
    }

    Future<void>.delayed(
      Duration(milliseconds: 260 + (widget.index * 360)),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _visible = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.earned) {
      return const Icon(
        Icons.star_border_rounded,
        size: 38,
        color: Color(0xFFD7CBA8),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: _visible ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 620),
      curve: Curves.elasticOut,
      builder: (context, progress, child) {
        final safeProgress = progress.clamp(0.0, 1.0);
        final rotation = (1 - safeProgress) * -0.38;

        return Opacity(
          opacity: safeProgress,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: 0.15 + (safeProgress * 0.85),
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: 46,
            color: const Color(0xFFFFB300)
                .withValues(alpha: 0.22),
          ),
          const Icon(
            Icons.star_rounded,
            size: 38,
            color: Color(0xFFFFB300),
          ),
          Positioned(
            top: 7,
            left: 12,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _CelebrationBackdrop extends StatelessWidget {
  const _CelebrationBackdrop();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          _FireworkBurst(
            alignment: Alignment(-0.92, -0.10),
            color: Color(0xFFFF8A00),
            delayMs: 90,
            scale: 0.95,
          ),
          _FireworkBurst(
            alignment: Alignment(0.92, -0.06),
            color: Color(0xFFFF4D6D),
            delayMs: 340,
            scale: 1.00,
          ),
          _FireworkBurst(
            alignment: Alignment(0.00, -0.42),
            color: Color(0xFF42C8FF),
            delayMs: 620,
            scale: 0.88,
          ),
          _StreamerPiece(
            alignment: Alignment(-0.70, 0.60),
            rotation: -0.38,
            color: Color(0xFF6CCF5F),
            delayMs: 140,
            symbol: '❊',
            size: 18,
          ),
          _StreamerPiece(
            alignment: Alignment(-0.33, 0.42),
            rotation: 0.24,
            color: Color(0xFFFFB300),
            delayMs: 460,
            symbol: '✦',
            size: 18,
          ),
          _StreamerPiece(
            alignment: Alignment(0.28, 0.58),
            rotation: -0.16,
            color: Color(0xFFB86BFF),
            delayMs: 300,
            symbol: '❋',
            size: 16,
          ),
          _StreamerPiece(
            alignment: Alignment(0.64, 0.42),
            rotation: 0.42,
            color: Color(0xFFFF5F6D),
            delayMs: 180,
            symbol: '✦',
            size: 19,
          ),
          _StreamerPiece(
            alignment: Alignment(-0.04, 0.84),
            rotation: 0.00,
            color: Color(0xFF42C8FF),
            delayMs: 560,
            symbol: '❊',
            size: 14,
          ),
        ],
      ),
    );
  }
}


class _FireworkBurst extends StatefulWidget {
  const _FireworkBurst({
    required this.alignment,
    required this.color,
    required this.delayMs,
    required this.scale,
  });

  final Alignment alignment;
  final Color color;
  final int delayMs;
  final double scale;

  @override
  State<_FireworkBurst> createState() => _FireworkBurstState();
}


class _FireworkBurstState extends State<_FireworkBurst> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(
      Duration(milliseconds: widget.delayMs),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _visible = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: _visible ? 1 : 0,
        ),
        duration: const Duration(milliseconds: 920),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) {
          final safe = progress.clamp(0.0, 1.0);
          final burstScale = (0.15 + (safe * 0.95)) * widget.scale;
          final opacity = safe < 0.76
              ? 1.0
              : (1 - ((safe - 0.76) / 0.24)).clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: burstScale,
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final angle in <double>[
                0,
                pi / 4,
                pi / 2,
                3 * pi / 4,
              ])
                Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.color.withValues(alpha: 0),
                          widget.color,
                          widget.color.withValues(alpha: 0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.34),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StreamerPiece extends StatefulWidget {
  const _StreamerPiece({
    required this.alignment,
    required this.rotation,
    required this.color,
    required this.delayMs,
    required this.symbol,
    required this.size,
  });

  final Alignment alignment;
  final double rotation;
  final Color color;
  final int delayMs;
  final String symbol;
  final double size;

  @override
  State<_StreamerPiece> createState() => _StreamerPieceState();
}


class _StreamerPieceState extends State<_StreamerPiece> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(
      Duration(milliseconds: widget.delayMs),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _visible = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: _visible ? 1 : 0,
        ),
        duration: const Duration(milliseconds: 780),
        curve: Curves.elasticOut,
        builder: (context, progress, child) {
          final safe = progress.clamp(0.0, 1.0);
          final floatY = (1 - safe) * 20;
          final opacity = safe;
          final scale = 0.2 + (safe * 0.8);

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.rotate(
                angle: widget.rotation + ((1 - safe) * 0.18),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Text(
          widget.symbol,
          style: TextStyle(
            fontSize: widget.size,
            fontWeight: FontWeight.w900,
            color: widget.color,
            shadows: [
              Shadow(
                color: widget.color.withValues(alpha: 0.22),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner();

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  // In DEBUG usiamo SEMPRE l'ID test ufficiale Google.
  // In RELEASE verrà usato l'ID reale di Hive Escape.
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidProductionBannerId =
      'ca-app-pub-2076419085002638/3237250386';

  String get _androidBannerId =>
      kReleaseMode ? _androidProductionBannerId : _androidTestBannerId;

  @override
  void initState() {
    super.initState();
    adRequestsAllowedNotifier.addListener(_handleAdPermissionChanged);

    if (adRequestsAllowedNotifier.value) {
      _loadBanner();
    }
  }

  void _handleAdPermissionChanged() {
    if (!mounted) {
      return;
    }

    if (adRequestsAllowedNotifier.value) {
      _loadBanner();
    } else {
      _disposeCurrentBanner();
    }
  }

  void _disposeCurrentBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _isLoading = false;

    if (mounted) {
      setState(() {});
    }
  }

  void _loadBanner() {
    if (!Platform.isAndroid ||
        !adRequestsAllowedNotifier.value ||
        _isLoaded ||
        _isLoading) {
      return;
    }

    _isLoading = true;

    final banner = BannerAd(
      adUnitId: _androidBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          if (!mounted) {
            return;
          }

          debugPrint(
            'Banner load error ${error.code}: ${error.message}',
          );

          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _isLoading = false;
          });
        },
      ),
    );

    banner.load();
  }

  @override
  void dispose() {
    adRequestsAllowedNotifier.removeListener(_handleAdPermissionChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const SizedBox(height: 60);
    }

    if (!adRequestsAllowedNotifier.value) {
      return const SizedBox(height: 60);
    }

    if (!_isLoaded || _bannerAd == null) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            tr('loadingAd'),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFB07A1A),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}

class _GridCell {
  const _GridCell(this.row, this.col);

  final int row;
  final int col;
}

class _HardCandidate {
  const _HardCandidate({
    required this.cell,
    required this.direction,
    required this.score,
  });

  final _GridCell cell;
  final BeeDirection direction;
  final int score;
}

class LevelGenerator {
  static LevelData generate(
    int levelNumber,
    GameDifficulty difficulty,
  ) {
    late final int gridSize;
    late final int targetBees;
    late final int chainCount;
    late final int difficultySeed;

    // Sei famiglie di layout che continuano a ruotare anche ai livelli
    // molto alti. L'epoca rende diversi anche due cicli della stessa
    // famiglia (es. livello 20 e livello 2000).
    final variationProfile = (levelNumber - 1) % 6;
    final generationEpoch = (levelNumber - 1) ~/ 6;

    switch (difficulty) {
      case GameDifficulty.easy:
        gridSize = 5;
        targetBees = min(12, 4 + levelNumber);
        chainCount = min(4, targetBees);
        difficultySeed = 11000;
        break;

      case GameDifficulty.medium:
        gridSize = 6;
        targetBees = min(22, 7 + levelNumber);
        chainCount = levelNumber <= 5 ? 3 : 2;
        difficultySeed = 22000;
        break;

      case GameDifficulty.hard:
        gridSize = levelNumber <= 6 ? 6 : 7;
        targetBees = min(
          gridSize * gridSize - 5,
          19 + (levelNumber * 2),
        );
        chainCount = 1;
        difficultySeed = 33000;
        break;
    }

    final random = Random(
      92017 +
          difficultySeed +
          (levelNumber * 7919) +
          (variationProfile * 3571) +
          (generationEpoch * 104729),
    );

    for (var boardAttempt = 0; boardAttempt < 180; boardAttempt++) {
      final pieces = difficulty == GameDifficulty.hard
          ? _buildHardCrossChainBoard(
              random: random,
              gridSize: gridSize,
              targetBees: targetBees,
              variationProfile: variationProfile,
            )
          : _buildChainBoard(
              random: random,
              gridSize: gridSize,
              targetBees: targetBees,
              chainCount: chainCount,
              variationProfile: variationProfile,
            );

      if (pieces == null || pieces.length != targetBees) {
        continue;
      }

      final initiallyFree = pieces
          .where(
            (bee) => _canExit(
              bee: bee,
              pieces: pieces,
              gridSize: gridSize,
            ),
          )
          .length;

      if (initiallyFree != chainCount) {
        continue;
      }

      if (!_isSolvable(pieces, gridSize)) {
        continue;
      }

      return LevelData(
        number: levelNumber,
        gridSize: gridSize,
        bees: List<BeePiece>.unmodifiable(pieces),
      );
    }

    return _fallback(levelNumber, difficulty);
  }

  static List<BeePiece>? _buildHardCrossChainBoard({
    required Random random,
    required int gridSize,
    required int targetBees,
    required int variationProfile,
  }) {
    final allCells = <_GridCell>[
      for (var row = 0; row < gridSize; row++)
        for (var col = 0; col < gridSize; col++) _GridCell(row, col),
    ];

    for (var layoutAttempt = 0; layoutAttempt < 420; layoutAttempt++) {
      final shuffled = List<_GridCell>.from(allCells)..shuffle(random);
      final occupied = shuffled.take(targetBees).toList();
      final occupiedKeys = occupied
          .map((cell) => _cellKey(cell.row, cell.col))
          .toSet();

      final firstCandidates = <_HardCandidate>[];

      for (final cell in occupied) {
        for (final direction in BeeDirection.values) {
          final blockers = _occupiedKeysInRay(
            cell: cell,
            direction: direction,
            gridSize: gridSize,
            occupiedKeys: occupiedKeys,
          );

          if (blockers.isEmpty) {
            firstCandidates.add(
              _HardCandidate(
                cell: cell,
                direction: direction,
                score: 0,
              ),
            );
          }
        }
      }

      if (firstCandidates.isEmpty) {
        continue;
      }

      firstCandidates.shuffle(random);
      final startsToTry = min(16, firstCandidates.length);

      for (var startIndex = 0; startIndex < startsToTry; startIndex++) {
        final start = firstCandidates[startIndex];
        final selectedKeys = <String>{
          _cellKey(start.cell.row, start.cell.col),
        };
        final selectedOrder = <_GridCell>[start.cell];
        final assignedDirections = <String, BeeDirection>{
          _cellKey(start.cell.row, start.cell.col): start.direction,
        };

        var lastCell = start.cell;

        while (selectedOrder.length < targetBees) {
          final lastKey = _cellKey(lastCell.row, lastCell.col);
          final candidates = <_HardCandidate>[];

          for (final cell in occupied) {
            final cellKey = _cellKey(cell.row, cell.col);

            if (selectedKeys.contains(cellKey)) {
              continue;
            }

            for (final direction in BeeDirection.values) {
              final blockers = _occupiedKeysInRay(
                cell: cell,
                direction: direction,
                gridSize: gridSize,
                occupiedKeys: occupiedKeys,
              );

              if (blockers.isEmpty || !blockers.contains(lastKey)) {
                continue;
              }

              if (!blockers.every(selectedKeys.contains)) {
                continue;
              }

              final distance =
                  (cell.row - lastCell.row).abs() +
                  (cell.col - lastCell.col).abs();

              final centerDistance =
                  ((cell.row * 2) - (gridSize - 1)).abs() +
                  ((cell.col * 2) - (gridSize - 1)).abs();

              final edgeDistance = min(
                min(cell.row, gridSize - 1 - cell.row),
                min(cell.col, gridSize - 1 - cell.col),
              );

              final lastDirection = assignedDirections[lastKey];
              final currentIsHorizontal =
                  direction == BeeDirection.left ||
                  direction == BeeDirection.right;
              final lastIsHorizontal = lastDirection == null
                  ? currentIsHorizontal
                  : lastDirection == BeeDirection.left ||
                      lastDirection == BeeDirection.right;
              final changesAxis =
                  lastDirection != null &&
                  currentIsHorizontal != lastIsHorizontal;

              late final int score;

              switch (variationProfile) {
                case 0:
                  // Incroci lunghi: le dipendenze attraversano la griglia.
                  score = (distance * 7) + (blockers.length * 3);
                  break;
                case 1:
                  // Nido compatto: privilegia più bloccanti sulla stessa linea.
                  score = (blockers.length * 10) + (distance * 2);
                  break;
                case 2:
                  // Nucleo centrale: concentra parte della catena verso il centro.
                  score =
                      ((gridSize * 4 - centerDistance) * 4) +
                      (blockers.length * 3) +
                      distance;
                  break;
                case 3:
                  // Bordo e rientro: usa più spesso celle esterne e poi incrocia.
                  score =
                      (edgeDistance == 0 ? 22 : 0) +
                      (distance * 4) +
                      (blockers.length * 2);
                  break;
                case 4:
                  // Zig-zag: premia il cambio asse tra una dipendenza e l'altra.
                  score =
                      (changesAxis ? 26 : 0) +
                      (distance * 3) +
                      (blockers.length * 3);
                  break;
                default:
                  // Misto: equilibrio con una piccola componente casuale.
                  score =
                      (distance * 4) +
                      (blockers.length * 5) +
                      random.nextInt(13);
                  break;
              }

              candidates.add(
                _HardCandidate(
                  cell: cell,
                  direction: direction,
                  score: score,
                ),
              );
            }
          }

          if (candidates.isEmpty) {
            break;
          }

          candidates.sort((a, b) => b.score.compareTo(a.score));
          final choicePool = min(4, candidates.length);
          final selected = candidates[random.nextInt(choicePool)];
          final selectedKey =
              _cellKey(selected.cell.row, selected.cell.col);

          selectedKeys.add(selectedKey);
          selectedOrder.add(selected.cell);
          assignedDirections[selectedKey] = selected.direction;
          lastCell = selected.cell;
        }

        if (selectedOrder.length != targetBees) {
          continue;
        }

        final pieces = <BeePiece>[];

        for (var index = 0; index < selectedOrder.length; index++) {
          final cell = selectedOrder[index];
          final key = _cellKey(cell.row, cell.col);
          final direction = assignedDirections[key];

          if (direction == null) {
            break;
          }

          pieces.add(
            BeePiece(
              id: index,
              row: cell.row,
              col: cell.col,
              direction: direction,
            ),
          );
        }

        if (pieces.length != targetBees) {
          continue;
        }

        final initiallyFree = pieces
            .where(
              (bee) => _canExit(
                bee: bee,
                pieces: pieces,
                gridSize: gridSize,
              ),
            )
            .length;

        if (initiallyFree == 1 && _isSolvable(pieces, gridSize)) {
          return pieces;
        }
      }
    }

    return null;
  }

  static List<String> _occupiedKeysInRay({
    required _GridCell cell,
    required BeeDirection direction,
    required int gridSize,
    required Set<String> occupiedKeys,
  }) {
    final blockers = <String>[];
    var row = cell.row;
    var col = cell.col;

    while (true) {
      switch (direction) {
        case BeeDirection.up:
          row--;
          break;
        case BeeDirection.right:
          col++;
          break;
        case BeeDirection.down:
          row++;
          break;
        case BeeDirection.left:
          col--;
          break;
      }

      if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
        break;
      }

      final key = _cellKey(row, col);

      if (occupiedKeys.contains(key)) {
        blockers.add(key);
      }
    }

    return blockers;
  }

  static List<BeePiece>? _buildChainBoard({
    required Random random,
    required int gridSize,
    required int targetBees,
    required int chainCount,
    required int variationProfile,
  }) {
    final lengths = List<int>.filled(chainCount, 1);
    var remaining = targetBees - chainCount;

    while (remaining > 0) {
      lengths[random.nextInt(chainCount)]++;
      remaining--;
    }

    lengths.sort((a, b) => b.compareTo(a));

    final occupied = <String>{};
    final paths = <List<_GridCell>>[];

    for (final chainLength in lengths) {
      final borderCells = _borderCells(gridSize)..shuffle(random);
      List<_GridCell>? selectedPath;

      for (final tail in borderCells) {
        if (occupied.contains(_cellKey(tail.row, tail.col))) {
          continue;
        }

        for (var pathAttempt = 0; pathAttempt < 20; pathAttempt++) {
          final path = _buildRandomPath(
            random: random,
            gridSize: gridSize,
            tail: tail,
            length: chainLength,
            occupied: occupied,
            variationProfile: variationProfile,
          );

          if (path != null) {
            selectedPath = path;
            break;
          }
        }

        if (selectedPath != null) {
          break;
        }
      }

      if (selectedPath == null) {
        return null;
      }

      paths.add(selectedPath);

      for (final cell in selectedPath) {
        occupied.add(_cellKey(cell.row, cell.col));
      }
    }

    final pieces = <BeePiece>[];
    var nextId = 0;

    for (final path in paths) {
      for (var index = 0; index < path.length; index++) {
        final cell = path[index];
        late final BeeDirection direction;

        if (index == 0) {
          direction = _outwardDirection(
            cell: cell,
            gridSize: gridSize,
            random: random,
          );
        } else {
          final successor = path[index - 1];
          direction = _directionToward(
            from: cell,
            to: successor,
          );
        }

        pieces.add(
          BeePiece(
            id: nextId++,
            row: cell.row,
            col: cell.col,
            direction: direction,
          ),
        );
      }
    }

    return pieces;
  }

  static List<_GridCell>? _buildRandomPath({
    required Random random,
    required int gridSize,
    required _GridCell tail,
    required int length,
    required Set<String> occupied,
    required int variationProfile,
  }) {
    final path = <_GridCell>[tail];
    final used = <String>{_cellKey(tail.row, tail.col)};

    while (path.length < length) {
      final current = path.last;
      final candidates = _neighbors(current, gridSize)
          .where(
            (cell) =>
                !occupied.contains(_cellKey(cell.row, cell.col)) &&
                !used.contains(_cellKey(cell.row, cell.col)),
          )
          .toList();

      if (candidates.isEmpty) {
        return null;
      }

      candidates.shuffle(random);

      final previous =
          path.length >= 2 ? path[path.length - 2] : null;

      candidates.sort((a, b) {
        final scoreA = _pathCandidateScore(
          candidate: a,
          current: current,
          previous: previous,
          gridSize: gridSize,
          occupied: occupied,
          used: used,
          variationProfile: variationProfile,
        );
        final scoreB = _pathCandidateScore(
          candidate: b,
          current: current,
          previous: previous,
          gridSize: gridSize,
          occupied: occupied,
          used: used,
          variationProfile: variationProfile,
        );
        return scoreB.compareTo(scoreA);
      });

      final choicePool = min(2, candidates.length);
      final selected = candidates[random.nextInt(choicePool)];

      path.add(selected);
      used.add(_cellKey(selected.row, selected.col));
    }

    return path;
  }

  static int _pathCandidateScore({
    required _GridCell candidate,
    required _GridCell current,
    required _GridCell? previous,
    required int gridSize,
    required Set<String> occupied,
    required Set<String> used,
    required int variationProfile,
  }) {
    final futureOptions = _futureOptions(
      candidate,
      gridSize,
      occupied,
      used,
    );

    final edgeDistance = min(
      min(candidate.row, gridSize - 1 - candidate.row),
      min(candidate.col, gridSize - 1 - candidate.col),
    );

    final centerDistance =
        ((candidate.row * 2) - (gridSize - 1)).abs() +
        ((candidate.col * 2) - (gridSize - 1)).abs();

    var continuesStraight = false;

    if (previous != null) {
      final previousRowDelta = current.row - previous.row;
      final previousColDelta = current.col - previous.col;
      final nextRowDelta = candidate.row - current.row;
      final nextColDelta = candidate.col - current.col;

      continuesStraight =
          previousRowDelta == nextRowDelta &&
          previousColDelta == nextColDelta;
    }

    switch (variationProfile) {
      case 0:
        // Aperto: lascia più alternative future.
        return futureOptions * 12;
      case 1:
        // Bordo: crea catene che costeggiano maggiormente la griglia.
        return (edgeDistance == 0 ? 24 : 0) + (futureOptions * 5);
      case 2:
        // Centro: porta più spesso la catena verso il cuore del tabellone.
        return ((gridSize * 4 - centerDistance) * 4) + futureOptions;
      case 3:
        // Lineare: segmenti più lunghi e leggibili.
        return (continuesStraight ? 26 : 0) + (futureOptions * 4);
      case 4:
        // Zig-zag: cambia spesso direzione.
        return (!continuesStraight && previous != null ? 26 : 0) +
            (futureOptions * 4);
      default:
        // Misto: bilancia centro, bordo e spazio futuro.
        return (futureOptions * 7) +
            (edgeDistance == 0 ? 7 : 0) +
            (gridSize * 2 - centerDistance);
    }
  }

  static int _futureOptions(
    _GridCell cell,
    int gridSize,
    Set<String> occupied,
    Set<String> used,
  ) {
    return _neighbors(cell, gridSize)
        .where(
          (neighbor) =>
              !occupied.contains(_cellKey(neighbor.row, neighbor.col)) &&
              !used.contains(_cellKey(neighbor.row, neighbor.col)),
        )
        .length;
  }

  static List<_GridCell> _neighbors(
    _GridCell cell,
    int gridSize,
  ) {
    final result = <_GridCell>[];

    if (cell.row > 0) {
      result.add(_GridCell(cell.row - 1, cell.col));
    }
    if (cell.row < gridSize - 1) {
      result.add(_GridCell(cell.row + 1, cell.col));
    }
    if (cell.col > 0) {
      result.add(_GridCell(cell.row, cell.col - 1));
    }
    if (cell.col < gridSize - 1) {
      result.add(_GridCell(cell.row, cell.col + 1));
    }

    return result;
  }

  static List<_GridCell> _borderCells(int gridSize) {
    final cells = <_GridCell>[];

    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        if (row == 0 ||
            row == gridSize - 1 ||
            col == 0 ||
            col == gridSize - 1) {
          cells.add(_GridCell(row, col));
        }
      }
    }

    return cells;
  }

  static BeeDirection _outwardDirection({
    required _GridCell cell,
    required int gridSize,
    required Random random,
  }) {
    final directions = <BeeDirection>[];

    if (cell.row == 0) {
      directions.add(BeeDirection.up);
    }
    if (cell.row == gridSize - 1) {
      directions.add(BeeDirection.down);
    }
    if (cell.col == 0) {
      directions.add(BeeDirection.left);
    }
    if (cell.col == gridSize - 1) {
      directions.add(BeeDirection.right);
    }

    directions.shuffle(random);
    return directions.first;
  }

  static BeeDirection _directionToward({
    required _GridCell from,
    required _GridCell to,
  }) {
    if (to.row < from.row) {
      return BeeDirection.up;
    }
    if (to.row > from.row) {
      return BeeDirection.down;
    }
    if (to.col < from.col) {
      return BeeDirection.left;
    }

    return BeeDirection.right;
  }

  static bool _canExit({
    required BeePiece bee,
    required List<BeePiece> pieces,
    required int gridSize,
  }) {
    var row = bee.row;
    var col = bee.col;

    while (true) {
      switch (bee.direction) {
        case BeeDirection.up:
          row--;
          break;
        case BeeDirection.right:
          col++;
          break;
        case BeeDirection.down:
          row++;
          break;
        case BeeDirection.left:
          col--;
          break;
      }

      if (row < 0 ||
          row >= gridSize ||
          col < 0 ||
          col >= gridSize) {
        return true;
      }

      for (final other in pieces) {
        if (other.id == bee.id) {
          continue;
        }

        if (other.row == row && other.col == col) {
          return false;
        }
      }
    }
  }

  static bool _isSolvable(
    List<BeePiece> pieces,
    int gridSize,
  ) {
    final active = List<BeePiece>.from(pieces);

    while (active.isNotEmpty) {
      final removable = active
          .where(
            (bee) => _canExit(
              bee: bee,
              pieces: active,
              gridSize: gridSize,
            ),
          )
          .toList();

      if (removable.isEmpty) {
        return false;
      }

      final removableIds = removable.map((bee) => bee.id).toSet();
      active.removeWhere((bee) => removableIds.contains(bee.id));
    }

    return true;
  }

  static String _cellKey(int row, int col) => '$row:$col';

  static LevelData _fallback(
    int levelNumber,
    GameDifficulty difficulty,
  ) {
    final gridSize = difficulty == GameDifficulty.easy ? 5 : 6;

    return LevelData(
      number: levelNumber,
      gridSize: gridSize,
      bees: const [
        BeePiece(
          id: 0,
          row: 0,
          col: 1,
          direction: BeeDirection.up,
        ),
        BeePiece(
          id: 1,
          row: 1,
          col: 1,
          direction: BeeDirection.up,
        ),
        BeePiece(
          id: 2,
          row: 2,
          col: 1,
          direction: BeeDirection.up,
        ),
        BeePiece(
          id: 3,
          row: 3,
          col: 1,
          direction: BeeDirection.up,
        ),
      ],
    );
  }
}
