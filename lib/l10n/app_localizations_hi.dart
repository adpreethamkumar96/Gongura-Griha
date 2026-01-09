// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'गोंगुरा गृह';

  @override
  String get appTagline => 'प्रामाणिक आंध्र अचार';

  @override
  String get home => 'होम';

  @override
  String get orders => 'ऑर्डर';

  @override
  String get wishlist => 'विशलिस्ट';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get deliverTo => 'डिलीवरी पता';

  @override
  String get searchPickles => 'अचार खोजें...';

  @override
  String get shopNow => 'अभी खरीदें';

  @override
  String get categories => 'श्रेणियाँ';

  @override
  String get featuredProducts => 'विशेष उत्पाद';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get pachadi => 'पचड़ी';

  @override
  String get chutney => 'चटनी';

  @override
  String get powder => 'पाउडर';

  @override
  String get bannerTitle1 => 'शुद्ध गोंगुरा व्यंजन';

  @override
  String get bannerSubtitle1 => 'प्रामाणिक आंध्र गोंगुरा स्वाद';

  @override
  String get bannerTitle2 => '100% शाकाहारी';

  @override
  String get bannerSubtitle2 => 'ताज़ा गोंगुरा पत्ती उत्पाद';

  @override
  String get bannerTitle3 => 'गोंगुरा स्पेशल';

  @override
  String get bannerSubtitle3 => '₹499 से ऊपर के ऑर्डर पर मुफ्त डिलीवरी';

  @override
  String get traditionalGonguraPachadi => 'पारंपरिक गोंगुरा पचड़ी';

  @override
  String get classicGonguraChutney => 'क्लासिक गोंगुरा चटनी';

  @override
  String get spicyGonguraPodi => 'मसालेदार गोंगुरा पोड़ी';

  @override
  String get pachadiDescription =>
      'ताज़ी, हाथ से चुनी गई गोंगुरा पत्तियों से बनी प्रामाणिक आंध्र शैली की गोंगुरा पचड़ी। यह खट्टी और मसालेदार पचड़ी पीढ़ियों से चली आ रही पारंपरिक रेसिपी से तैयार की जाती है। गर्म चावल और रोटी के साथ बिल्कुल सही।';

  @override
  String get chutneyDescription =>
      'खट्टे और मसालेदार स्वाद के सही मिश्रण के साथ एक स्वादिष्ट गोंगुरा चटनी। कोमल गोंगुरा पत्तियों से ताज़ा बनाई गई, यह चटनी किसी भी भोजन में प्रामाणिक दक्षिण भारतीय स्वाद जोड़ती है। डोसा, इडली और चावल के लिए आदर्श।';

  @override
  String get podiDescription =>
      'धूप में सुखाई गई गोंगुरा पत्तियों और सुगंधित मसालों से बना एक स्वादिष्ट सूखा पाउडर। इस बहुमुखी पोड़ी को चावल और घी के साथ मिलाया जा सकता है, डोसे पर छिड़का जा सकता है, या मसाले के रूप में उपयोग किया जा सकता है।';

  @override
  String get productDetails => 'उत्पाद विवरण';

  @override
  String get description => 'विवरण';

  @override
  String get ingredients => 'सामग्री';

  @override
  String get selectSize => 'साइज़ चुनें';

  @override
  String get price => 'मूल्य';

  @override
  String get add => 'जोड़ें';

  @override
  String get addToCart => 'कार्ट में जोड़ें';

  @override
  String get addedToCart => 'कार्ट में जोड़ा गया';

  @override
  String get viewCart => 'कार्ट देखें';

  @override
  String get gonguraLeaves => 'गोंगुरा पत्तियाँ';

  @override
  String get redChillies => 'लाल मिर्च';

  @override
  String get mustardSeeds => 'राई';

  @override
  String get fenugreekSeeds => 'मेथी';

  @override
  String get garlic => 'लहसुन';

  @override
  String get salt => 'नमक';

  @override
  String get groundnutOil => 'मूंगफली का तेल';

  @override
  String get myCart => 'मेरी कार्ट';

  @override
  String get cartEmpty => 'आपकी कार्ट खाली है';

  @override
  String get addPicklesToCart => 'अपनी कार्ट में स्वादिष्ट अचार जोड़ें';

  @override
  String get browseProducts => 'उत्पाद देखें';

  @override
  String addMoreForFreeDelivery(String amount) {
    return 'मुफ्त डिलीवरी के लिए ₹$amount और जोड़ें';
  }

  @override
  String get quantity => 'मात्रा';

  @override
  String maxQuantityHint(int max) {
    return 'इस साइज़ के लिए अधिकतम $max। अधिक के लिए बड़ा साइज़ चुनें!';
  }

  @override
  String get applyCoupon => 'कूपन लागू करें';

  @override
  String get availableCoupons => 'उपलब्ध कूपन';

  @override
  String get enterCouponCode => 'कूपन कोड दर्ज करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get remove => 'हटाएं';

  @override
  String youSaved(String amount) {
    return 'आपने ₹$amount बचाए';
  }

  @override
  String get billDetails => 'बिल विवरण';

  @override
  String get itemTotal => 'आइटम कुल';

  @override
  String get couponDiscount => 'कूपन छूट';

  @override
  String get delivery => 'डिलीवरी';

  @override
  String get free => 'मुफ्त';

  @override
  String get toPay => 'भुगतान';

  @override
  String savedWithCoupon(String amount) {
    return 'आपने कूपन से ₹$amount बचाए!';
  }

  @override
  String get viewBillDetails => 'बिल विवरण देखें';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get removeItem => 'आइटम हटाएं';

  @override
  String get removeItemConfirm => 'क्या आप वाकई इस आइटम को हटाना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get active => 'सक्रिय';

  @override
  String get pastOrders => 'पिछले ऑर्डर';

  @override
  String get noActiveOrders => 'कोई सक्रिय ऑर्डर नहीं';

  @override
  String get noPastOrders => 'कोई पिछले ऑर्डर नहीं';

  @override
  String get activeOrdersAppearHere => 'आपके सक्रिय ऑर्डर यहाँ दिखाई देंगे';

  @override
  String get orderHistoryAppearHere => 'आपका ऑर्डर इतिहास यहाँ दिखाई देगा';

  @override
  String get items => 'आइटम';

  @override
  String moreItems(int count) {
    return '$count और आइटम';
  }

  @override
  String get expectedBy => 'अपेक्षित तिथि';

  @override
  String get deliveredOn => 'डिलीवर हुआ';

  @override
  String get reorder => 'फिर से ऑर्डर करें';

  @override
  String get rate => 'रेट करें';

  @override
  String get orderPlaced => 'ऑर्डर किया';

  @override
  String get orderConfirmed => 'पुष्टि';

  @override
  String get orderPreparing => 'तैयारी';

  @override
  String get orderShipped => 'भेजा गया';

  @override
  String get orderDelivered => 'डिलीवर';

  @override
  String get outForDelivery => 'डिलीवरी के लिए निकला';

  @override
  String get orderStatus => 'ऑर्डर स्थिति';

  @override
  String get viewInvoice => 'इनवॉइस देखें';

  @override
  String get deliveryAddress => 'डिलीवरी पता';

  @override
  String get paymentDetails => 'भुगतान विवरण';

  @override
  String get paid => 'भुगतान किया';

  @override
  String get transactionId => 'लेनदेन आईडी';

  @override
  String get totalPaid => 'कुल भुगतान';

  @override
  String get needHelp => 'मदद चाहिए?';

  @override
  String get chatWithUs => 'हमसे चैट करें';

  @override
  String get callSupport => 'सपोर्ट को कॉल करें';

  @override
  String get cancelOrder => 'ऑर्डर रद्द करें';

  @override
  String get cancelOrderConfirm =>
      'क्या आप वाकई इस ऑर्डर को रद्द करना चाहते हैं?';

  @override
  String get yesCancelOrder => 'हाँ, रद्द करें';

  @override
  String get no => 'नहीं';

  @override
  String get myWishlist => 'मेरी विशलिस्ट';

  @override
  String get wishlistEmpty => 'आपकी विशलिस्ट खाली है';

  @override
  String get saveItemsForLater => 'अपनी पसंद की चीज़ें बाद के लिए सहेजें';

  @override
  String get discoverProducts => 'उत्पाद खोजें';

  @override
  String get moveToCart => 'कार्ट में ले जाएं';

  @override
  String get movedToCart => 'कार्ट में जोड़ा गया';

  @override
  String get removedFromWishlist => 'विशलिस्ट से हटाया गया';

  @override
  String get myProfile => 'मेरी प्रोफाइल';

  @override
  String get editProfile => 'प्रोफाइल संपादित करें';

  @override
  String get myAddresses => 'मेरे पते';

  @override
  String get paymentMethods => 'भुगतान के तरीके';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get aboutUs => 'हमारे बारे में';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirm => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get yesLogout => 'हाँ, लॉगआउट करें';

  @override
  String get language => 'भाषा';

  @override
  String get languageChangeInfo =>
      'अपनी पसंदीदा भाषा चुनें। परिवर्तन लागू करने के लिए ऐप पुनः आरंभ होगा।';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get languageChangeConfirm =>
      'भाषा परिवर्तन लागू करने के लिए ऐप को पुनः आरंभ करना होगा। जारी रखें?';

  @override
  String get continue_ => 'जारी रखें';

  @override
  String languageChangedTo(String language) {
    return 'भाषा $language में बदल दी गई';
  }

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get telugu => 'तेलुगु';

  @override
  String get aboutUsTitle => 'हमारे बारे में';

  @override
  String get ourStory => 'हमारी कहानी';

  @override
  String get ourStoryContent =>
      'गोंगुरा गृह प्रामाणिक आंध्र स्वाद के जुनून से पैदा हुआ था। हैदराबाद में अचार प्रेमियों के एक परिवार द्वारा शुरू किया गया, हम आपके लिए घर के बने आंध्र अचार का स्वाद लाते हैं, जो प्यार और पीढ़ियों से चली आ रही पारंपरिक रेसिपी से बनाया गया है।\n\nहमारे गोंगुरा अचार तेलंगाना के खेतों से सीधे प्राप्त बेहतरीन अम्बाड़ी की पत्तियों से बनाए जाते हैं।';

  @override
  String get whyChooseUs => 'हमें क्यों चुनें';

  @override
  String get natural100 => '100% प्राकृतिक';

  @override
  String get naturalDesc => 'कोई प्रिजर्वेटिव या कृत्रिम रंग नहीं';

  @override
  String get authenticRecipes => 'प्रामाणिक रेसिपी';

  @override
  String get authenticDesc => 'पारंपरिक आंध्र खाना पकाने के तरीके';

  @override
  String get freshDelivery => 'ताज़ी डिलीवरी';

  @override
  String get freshDeliveryDesc => 'आपके दरवाज़े पर ताज़ा डिलीवर';

  @override
  String get madeWithLove => 'प्यार से बनाया';

  @override
  String get madeWithLoveDesc => 'छोटे बैचों में हाथ से बनाया';

  @override
  String get connectWithUs => 'हमसे जुड़ें';

  @override
  String get contactInformation => 'संपर्क जानकारी';

  @override
  String get address => 'पता';

  @override
  String get email => 'ईमेल';

  @override
  String get phone => 'फोन';

  @override
  String get version => 'संस्करण';

  @override
  String get madeInIndia => 'भारत में प्यार से बनाया गया';

  @override
  String get allProducts => 'सभी उत्पाद';

  @override
  String get filter => 'फिल्टर';

  @override
  String get sortBy => 'क्रमबद्ध करें';

  @override
  String get priceRange => 'मूल्य सीमा';

  @override
  String get clearAll => 'सभी साफ करें';

  @override
  String get applyFilters => 'फिल्टर लागू करें';

  @override
  String get popularity => 'लोकप्रियता';

  @override
  String get priceLowToHigh => 'मूल्य: कम से अधिक';

  @override
  String get priceHighToLow => 'मूल्य: अधिक से कम';

  @override
  String get newest => 'नवीनतम';

  @override
  String get noProductsFound => 'कोई उत्पाद नहीं मिला';

  @override
  String get tryDifferentFilters => 'अलग फिल्टर या खोज शब्द आज़माएं';

  @override
  String get search => 'खोजें';

  @override
  String get recentSearches => 'हाल की खोजें';

  @override
  String get clearHistory => 'इतिहास साफ करें';

  @override
  String get searchResults => 'खोज परिणाम';

  @override
  String get noResults => 'कोई परिणाम नहीं मिला';

  @override
  String get tryDifferentKeywords => 'अलग कीवर्ड आज़माएं';

  @override
  String get veg => 'शाकाहारी';

  @override
  String get nonVeg => 'मांसाहारी';

  @override
  String get sort => 'क्रमबद्ध';

  @override
  String get filters => 'फिल्टर';

  @override
  String get reset => 'रीसेट';

  @override
  String get mostPopular => 'सबसे लोकप्रिय';

  @override
  String get nameAToZ => 'नाम: A से Z';

  @override
  String get dietaryPreference => 'आहार वरीयता';

  @override
  String get all => 'सभी';

  @override
  String get vegOnly => 'केवल शाकाहारी';

  @override
  String get clearFilters => 'फिल्टर साफ करें';

  @override
  String productsCount(int count) {
    return '$count उत्पाद';
  }

  @override
  String get tryAdjustingFilters => 'अपने फिल्टर बदलने का प्रयास करें';

  @override
  String get calories => 'कैलोरी';

  @override
  String get protein => 'प्रोटीन';

  @override
  String get carbs => 'कार्ब्स';

  @override
  String get fat => 'वसा';

  @override
  String get sodium => 'सोडियम';

  @override
  String get highlight100Natural => '100% प्राकृतिक सामग्री से बना';

  @override
  String get highlightNoPreservatives => 'कोई संरक्षक या कृत्रिम रंग नहीं';

  @override
  String get highlightTraditionalRecipe => 'पारंपरिक आंध्र रेसिपी';

  @override
  String get highlightFreshGongura => 'आंध्र प्रदेश से ताजी गोंगुरा पत्तियां';

  @override
  String get highlightShelfLife6Months => 'शेल्फ लाइफ: 6 महीने';

  @override
  String get highlightTangySpicy => 'परफेक्ट खट्टा-मसालेदार बैलेंस';

  @override
  String get highlightNoArtificial => 'कोई कृत्रिम स्वाद या रंग नहीं';

  @override
  String get highlightFreshSpices => 'ताजे पिसे मसाले';

  @override
  String get highlightHandcrafted => 'छोटी मात्रा में हस्तनिर्मित';

  @override
  String get highlightShelfLife4Months => 'शेल्फ लाइफ: 4 महीने';

  @override
  String get highlightSunDried => 'धूप में सुखाई गोंगुरा पत्तियां';

  @override
  String get highlightCoarseGround => 'बेहतरीन बनावट के लिए मोटा पिसा';

  @override
  String get highlightRichInIron => 'आयरन और विटामिन से भरपूर';

  @override
  String get highlightShelfLife8Months => 'लंबी शेल्फ लाइफ - 8 महीने';

  @override
  String get highlightVersatile => 'बहुमुखी उपयोग';

  @override
  String get greenChillies => 'हरी मिर्च';

  @override
  String get tamarind => 'इमली';

  @override
  String get cuminSeeds => 'जीरा';

  @override
  String get cumin => 'जीरा';

  @override
  String get sesameOil => 'तिल का तेल';

  @override
  String get driedGonguraLeaves => 'सूखी गोंगुरा पत्तियां';

  @override
  String get uradDal => 'उड़द दाल';

  @override
  String get chanaDal => 'चना दाल';

  @override
  String get highlights => 'विशेषताएं';

  @override
  String nutritionInfoPer(String weight) {
    return 'पोषण जानकारी (प्रति $weight)';
  }

  @override
  String addMoreToApply(String amount) {
    return 'लागू करने के लिए ₹$amount और जोड़ें';
  }

  @override
  String get statusOrderConfirmed => 'ऑर्डर कन्फर्म';

  @override
  String get statusOutForDelivery => 'डिलीवरी के लिए निकला';

  @override
  String get tomorrowDelivery => 'कल, शाम 8 बजे तक';

  @override
  String get todayDelivery => 'आज, शाम 6 बजे तक';

  @override
  String get account => 'खाता';

  @override
  String get savedAddresses => 'सहेजे गए पते';

  @override
  String addressesCount(int count) {
    return '$count पते';
  }

  @override
  String get preferences => 'प्राथमिकताएं';

  @override
  String get support => 'सहायता';

  @override
  String get termsConditions => 'नियम और शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get popularSearches => 'लोकप्रिय खोज';

  @override
  String get browseCategories => 'श्रेणियाँ ब्राउज़ करें';

  @override
  String get vegPickles => 'शाकाहारी अचार';

  @override
  String get nonVegPickles => 'मांसाहारी अचार';

  @override
  String get chutneys => 'चटनी';

  @override
  String get giftPacks => 'उपहार पैक';
}
