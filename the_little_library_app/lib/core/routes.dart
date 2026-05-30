/// Centralized route name constants. US-0.1.8.
/// All feature screens reference these instead of hardcoded strings.
library;

const String kRouteCatalog = '/catalog';
const String kRouteBookDetail = '/book/:id';
const String kRouteBookAdd = '/book/add';
const String kRouteBookEdit = '/book/edit/:id';
const String kRouteScannerBarcode = '/scanner/barcode';
const String kRouteScannerOcr = '/scanner/ocr';
const String kRouteVoiceInput = '/voice-input';
const String kRouteLocations = '/locations';
const String kRouteCheckout = '/checkout/:bookId';
const String kRouteLoan = '/loan/:bookId';
const String kRouteConflicts = '/conflicts';
const String kRouteActivity = '/activity';
const String kRouteSettings = '/settings';
const String kRouteSettingsGenres = '/settings/genres';
const String kRouteSettingsTags = '/settings/tags';
const String kRouteSettingsLanguages = '/settings/languages';
const String kRouteDeleted = '/deleted';
const String kRouteActiveLoans = '/active-loans';
const String kRouteExport = '/export';
const String kRouteShareLibrary = '/share-library';
const String kRouteChangeHistory = '/change-history/:bookId';
const String kRouteSetup = '/setup';
const String kRouteForceUpdate = '/force-update';
const String kRouteBulkScanner = '/bulk-scanner';
