import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Gongura Griha'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Authentic Andhra Pickles'**
  String get appTagline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @searchPickles.
  ///
  /// In en, this message translates to:
  /// **'Search pickles...'**
  String get searchPickles;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @featuredProducts.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProducts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @pachadi.
  ///
  /// In en, this message translates to:
  /// **'Pachadi'**
  String get pachadi;

  /// No description provided for @chutney.
  ///
  /// In en, this message translates to:
  /// **'Chutney'**
  String get chutney;

  /// No description provided for @powder.
  ///
  /// In en, this message translates to:
  /// **'Powder'**
  String get powder;

  /// No description provided for @bannerTitle1.
  ///
  /// In en, this message translates to:
  /// **'Pure Gongura Delights'**
  String get bannerTitle1;

  /// No description provided for @bannerSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Authentic Andhra Gongura Flavors'**
  String get bannerSubtitle1;

  /// No description provided for @bannerTitle2.
  ///
  /// In en, this message translates to:
  /// **'100% Vegetarian'**
  String get bannerTitle2;

  /// No description provided for @bannerSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Fresh Gongura Leaf Products'**
  String get bannerSubtitle2;

  /// No description provided for @bannerTitle3.
  ///
  /// In en, this message translates to:
  /// **'Gongura Special'**
  String get bannerTitle3;

  /// No description provided for @bannerSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Free delivery on orders above Rs.499'**
  String get bannerSubtitle3;

  /// No description provided for @traditionalGonguraPachadi.
  ///
  /// In en, this message translates to:
  /// **'Traditional Gongura Pachadi'**
  String get traditionalGonguraPachadi;

  /// No description provided for @classicGonguraChutney.
  ///
  /// In en, this message translates to:
  /// **'Classic Gongura Chutney'**
  String get classicGonguraChutney;

  /// No description provided for @spicyGonguraPodi.
  ///
  /// In en, this message translates to:
  /// **'Spicy Gongura Podi'**
  String get spicyGonguraPodi;

  /// No description provided for @pachadiDescription.
  ///
  /// In en, this message translates to:
  /// **'Authentic Andhra-style gongura pachadi made with fresh, hand-picked gongura leaves. This tangy and spicy pachadi is prepared using traditional recipes passed down through generations. Perfect accompaniment for hot rice and rotis.'**
  String get pachadiDescription;

  /// No description provided for @chutneyDescription.
  ///
  /// In en, this message translates to:
  /// **'A delicious gongura chutney with the perfect blend of tangy and spicy flavors. Made fresh with tender gongura leaves, this chutney adds a burst of authentic South Indian taste to any meal. Ideal for dosas, idlis, and rice.'**
  String get chutneyDescription;

  /// No description provided for @podiDescription.
  ///
  /// In en, this message translates to:
  /// **'A flavorful dry powder made from sun-dried gongura leaves and aromatic spices. This versatile podi can be mixed with rice and ghee, sprinkled on dosas, or used as a seasoning. A must-have for gongura lovers!'**
  String get podiDescription;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select Size'**
  String get selectSize;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'VIEW CART'**
  String get viewCart;

  /// No description provided for @gonguraLeaves.
  ///
  /// In en, this message translates to:
  /// **'Gongura Leaves'**
  String get gonguraLeaves;

  /// No description provided for @redChillies.
  ///
  /// In en, this message translates to:
  /// **'Red Chillies'**
  String get redChillies;

  /// No description provided for @mustardSeeds.
  ///
  /// In en, this message translates to:
  /// **'Mustard Seeds'**
  String get mustardSeeds;

  /// No description provided for @fenugreekSeeds.
  ///
  /// In en, this message translates to:
  /// **'Fenugreek'**
  String get fenugreekSeeds;

  /// No description provided for @garlic.
  ///
  /// In en, this message translates to:
  /// **'Garlic'**
  String get garlic;

  /// No description provided for @salt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get salt;

  /// No description provided for @groundnutOil.
  ///
  /// In en, this message translates to:
  /// **'Groundnut Oil'**
  String get groundnutOil;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @addPicklesToCart.
  ///
  /// In en, this message translates to:
  /// **'Add some delicious pickles to your cart'**
  String get addPicklesToCart;

  /// No description provided for @browseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get browseProducts;

  /// No description provided for @addMoreForFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Add ₹{amount} more for FREE delivery'**
  String addMoreForFreeDelivery(String amount);

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @maxQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Max {max} for this size. Try a larger size for more!'**
  String maxQuantityHint(int max);

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get applyCoupon;

  /// No description provided for @availableCoupons.
  ///
  /// In en, this message translates to:
  /// **'Available Coupons'**
  String get availableCoupons;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @youSaved.
  ///
  /// In en, this message translates to:
  /// **'You saved ₹{amount}'**
  String youSaved(String amount);

  /// No description provided for @billDetails.
  ///
  /// In en, this message translates to:
  /// **'Bill Details'**
  String get billDetails;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Item Total'**
  String get itemTotal;

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount'**
  String get couponDiscount;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To Pay'**
  String get toPay;

  /// No description provided for @savedWithCoupon.
  ///
  /// In en, this message translates to:
  /// **'You saved ₹{amount} with coupon!'**
  String savedWithCoupon(String amount);

  /// No description provided for @viewBillDetails.
  ///
  /// In en, this message translates to:
  /// **'View Bill Details'**
  String get viewBillDetails;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get removeItem;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item?'**
  String get removeItemConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @pastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past Orders'**
  String get pastOrders;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get noActiveOrders;

  /// No description provided for @noPastOrders.
  ///
  /// In en, this message translates to:
  /// **'No past orders'**
  String get noPastOrders;

  /// No description provided for @activeOrdersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your active orders will appear here'**
  String get activeOrdersAppearHere;

  /// No description provided for @orderHistoryAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here'**
  String get orderHistoryAppearHere;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'{count} more item'**
  String moreItems(int count);

  /// No description provided for @expectedBy.
  ///
  /// In en, this message translates to:
  /// **'Expected by'**
  String get expectedBy;

  /// No description provided for @deliveredOn.
  ///
  /// In en, this message translates to:
  /// **'Delivered on'**
  String get deliveredOn;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get orderPlaced;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderConfirmed;

  /// No description provided for @orderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderPreparing;

  /// No description provided for @orderShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderShipped;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDelivered;

  /// No description provided for @outForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get outForDelivery;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @viewInvoice.
  ///
  /// In en, this message translates to:
  /// **'View Invoice'**
  String get viewInvoice;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get chatWithUs;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get callSupport;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @yesCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancelOrder;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmpty;

  /// No description provided for @saveItemsForLater.
  ///
  /// In en, this message translates to:
  /// **'Save items you love for later'**
  String get saveItemsForLater;

  /// No description provided for @discoverProducts.
  ///
  /// In en, this message translates to:
  /// **'Discover Products'**
  String get discoverProducts;

  /// No description provided for @moveToCart.
  ///
  /// In en, this message translates to:
  /// **'Move to Cart'**
  String get moveToCart;

  /// No description provided for @movedToCart.
  ///
  /// In en, this message translates to:
  /// **'moved to cart'**
  String get movedToCart;

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'removed from wishlist'**
  String get removedFromWishlist;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @yesLogout.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yesLogout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChangeInfo.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language. The app will restart to apply changes.'**
  String get languageChangeInfo;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @languageChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'The app needs to restart to apply the language change. Continue?'**
  String get languageChangeConfirm;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(String language);

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @aboutUsTitle.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsTitle;

  /// No description provided for @ourStory.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get ourStory;

  /// No description provided for @ourStoryContent.
  ///
  /// In en, this message translates to:
  /// **'Gongura Griha was born from a passion for authentic Andhra flavors. Started by a family of pickle enthusiasts in Hyderabad, we bring you the taste of homemade Andhra pickles, made with love and traditional recipes passed down through generations.\n\nOur gongura pickles are made from the finest sorrel leaves, sourced directly from farms in Telangana, ensuring the authentic tangy taste that Andhra pickles are famous for.'**
  String get ourStoryContent;

  /// No description provided for @whyChooseUs.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us'**
  String get whyChooseUs;

  /// No description provided for @natural100.
  ///
  /// In en, this message translates to:
  /// **'100% Natural'**
  String get natural100;

  /// No description provided for @naturalDesc.
  ///
  /// In en, this message translates to:
  /// **'No preservatives or artificial colors'**
  String get naturalDesc;

  /// No description provided for @authenticRecipes.
  ///
  /// In en, this message translates to:
  /// **'Authentic Recipes'**
  String get authenticRecipes;

  /// No description provided for @authenticDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Andhra cooking methods'**
  String get authenticDesc;

  /// No description provided for @freshDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fresh Delivery'**
  String get freshDelivery;

  /// No description provided for @freshDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Delivered fresh to your doorstep'**
  String get freshDeliveryDesc;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with Love'**
  String get madeWithLove;

  /// No description provided for @madeWithLoveDesc.
  ///
  /// In en, this message translates to:
  /// **'Handcrafted in small batches'**
  String get madeWithLoveDesc;

  /// No description provided for @connectWithUs.
  ///
  /// In en, this message translates to:
  /// **'Connect With Us'**
  String get connectWithUs;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @madeInIndia.
  ///
  /// In en, this message translates to:
  /// **'Made with love in India'**
  String get madeInIndia;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @popularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularity;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @tryDifferentFilters.
  ///
  /// In en, this message translates to:
  /// **'Try different filters or search terms'**
  String get tryDifferentFilters;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @veg.
  ///
  /// In en, this message translates to:
  /// **'Veg'**
  String get veg;

  /// No description provided for @nonVeg.
  ///
  /// In en, this message translates to:
  /// **'Non-Veg'**
  String get nonVeg;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @nameAToZ.
  ///
  /// In en, this message translates to:
  /// **'Name: A to Z'**
  String get nameAToZ;

  /// No description provided for @dietaryPreference.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preference'**
  String get dietaryPreference;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @vegOnly.
  ///
  /// In en, this message translates to:
  /// **'Veg Only'**
  String get vegOnly;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productsCount(int count);

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @highlight100Natural.
  ///
  /// In en, this message translates to:
  /// **'Made with 100% natural ingredients'**
  String get highlight100Natural;

  /// No description provided for @highlightNoPreservatives.
  ///
  /// In en, this message translates to:
  /// **'No preservatives or artificial colors'**
  String get highlightNoPreservatives;

  /// No description provided for @highlightTraditionalRecipe.
  ///
  /// In en, this message translates to:
  /// **'Traditional Andhra recipe'**
  String get highlightTraditionalRecipe;

  /// No description provided for @highlightFreshGongura.
  ///
  /// In en, this message translates to:
  /// **'Fresh gongura leaves from Andhra Pradesh'**
  String get highlightFreshGongura;

  /// No description provided for @highlightShelfLife6Months.
  ///
  /// In en, this message translates to:
  /// **'Shelf life: 6 months'**
  String get highlightShelfLife6Months;

  /// No description provided for @highlightTangySpicy.
  ///
  /// In en, this message translates to:
  /// **'Perfect tangy-spicy balance'**
  String get highlightTangySpicy;

  /// No description provided for @highlightNoArtificial.
  ///
  /// In en, this message translates to:
  /// **'No artificial flavors or colors'**
  String get highlightNoArtificial;

  /// No description provided for @highlightFreshSpices.
  ///
  /// In en, this message translates to:
  /// **'Freshly ground spices'**
  String get highlightFreshSpices;

  /// No description provided for @highlightHandcrafted.
  ///
  /// In en, this message translates to:
  /// **'Handcrafted in small batches'**
  String get highlightHandcrafted;

  /// No description provided for @highlightShelfLife4Months.
  ///
  /// In en, this message translates to:
  /// **'Shelf life: 4 months'**
  String get highlightShelfLife4Months;

  /// No description provided for @highlightSunDried.
  ///
  /// In en, this message translates to:
  /// **'Sun-dried gongura leaves'**
  String get highlightSunDried;

  /// No description provided for @highlightCoarseGround.
  ///
  /// In en, this message translates to:
  /// **'Coarsely ground for best texture'**
  String get highlightCoarseGround;

  /// No description provided for @highlightRichInIron.
  ///
  /// In en, this message translates to:
  /// **'Rich in iron and vitamins'**
  String get highlightRichInIron;

  /// No description provided for @highlightShelfLife8Months.
  ///
  /// In en, this message translates to:
  /// **'Long shelf life - 8 months'**
  String get highlightShelfLife8Months;

  /// No description provided for @highlightVersatile.
  ///
  /// In en, this message translates to:
  /// **'Versatile usage'**
  String get highlightVersatile;

  /// No description provided for @greenChillies.
  ///
  /// In en, this message translates to:
  /// **'Green Chillies'**
  String get greenChillies;

  /// No description provided for @tamarind.
  ///
  /// In en, this message translates to:
  /// **'Tamarind'**
  String get tamarind;

  /// No description provided for @cuminSeeds.
  ///
  /// In en, this message translates to:
  /// **'Cumin Seeds'**
  String get cuminSeeds;

  /// No description provided for @cumin.
  ///
  /// In en, this message translates to:
  /// **'Cumin'**
  String get cumin;

  /// No description provided for @sesameOil.
  ///
  /// In en, this message translates to:
  /// **'Sesame Oil'**
  String get sesameOil;

  /// No description provided for @driedGonguraLeaves.
  ///
  /// In en, this message translates to:
  /// **'Dried Gongura Leaves'**
  String get driedGonguraLeaves;

  /// No description provided for @uradDal.
  ///
  /// In en, this message translates to:
  /// **'Urad Dal'**
  String get uradDal;

  /// No description provided for @chanaDal.
  ///
  /// In en, this message translates to:
  /// **'Chana Dal'**
  String get chanaDal;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @nutritionInfoPer.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Info (per {weight})'**
  String nutritionInfoPer(String weight);

  /// No description provided for @addMoreToApply.
  ///
  /// In en, this message translates to:
  /// **'Add ₹{amount} more to apply'**
  String addMoreToApply(String amount);

  /// No description provided for @statusOrderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get statusOrderConfirmed;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get statusOutForDelivery;

  /// No description provided for @tomorrowDelivery.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, by 8 PM'**
  String get tomorrowDelivery;

  /// No description provided for @todayDelivery.
  ///
  /// In en, this message translates to:
  /// **'Today, by 6 PM'**
  String get todayDelivery;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @addressesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} addresses'**
  String addressesCount(int count);

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get browseCategories;

  /// No description provided for @vegPickles.
  ///
  /// In en, this message translates to:
  /// **'Veg Pickles'**
  String get vegPickles;

  /// No description provided for @nonVegPickles.
  ///
  /// In en, this message translates to:
  /// **'Non-Veg Pickles'**
  String get nonVegPickles;

  /// No description provided for @chutneys.
  ///
  /// In en, this message translates to:
  /// **'Chutneys'**
  String get chutneys;

  /// No description provided for @giftPacks.
  ///
  /// In en, this message translates to:
  /// **'Gift Packs'**
  String get giftPacks;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
