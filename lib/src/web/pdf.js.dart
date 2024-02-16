// ignore_for_file: avoid_web_libraries_in_flutter

@JS()
library pdf.js;

import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:synchronized/extension.dart';
import 'package:web/web.dart' as web;

import '../../pdfrx.dart';

/// Default pdf.js version
const _pdfjsVersion = '3.11.174';

/// Default pdf.js URL
const _pdfjsUrl =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/$_pdfjsVersion/pdf.min.js';

/// Default pdf.worker.js URL
const _pdfjsWorkerSrc =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/$_pdfjsVersion/pdf.worker.min.js';

/// Default CMap URL
const _pdfjsCMapUrl =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/$_pdfjsVersion/cmaps/';

bool get _isPdfjsLoaded => hasProperty(globalThis, 'pdfjsLib');

@JS('pdfjsLib.getDocument')
external _PDFDocumentLoadingTask _pdfjsGetDocument(dynamic data);

@JS('pdfjsLib.GlobalWorkerOptions.workerSrc')
external set _pdfjsWorkerSrc(String src);

@JS()
@anonymous
@staticInterop
class Promise<T> {}

extension PromiseExts<T> on Promise<T> {
  Future<T> get toFuture => promiseToFuture<T>(this);
}

@JS()
@staticInterop
@anonymous
class _PDFDocumentLoadingTask {}

extension on _PDFDocumentLoadingTask {
  external Promise<PdfjsDocument> get promise;
}

Future<PdfjsDocument> _pdfjsGetDocumentJsParams(Map<String, dynamic> jsParams) {
  final params = <String, dynamic>{
    'cMapUrl': PdfJsConfiguration.configuration?.cMapUrl ?? _pdfjsCMapUrl,
    'cMapPacked': PdfJsConfiguration.configuration?.cMapPacked ?? true,
  }..addAll(jsParams);
  return _pdfjsGetDocument(jsify(params)).promise.toFuture;
}

Future<PdfjsDocument> pdfjsGetDocument(String url, {String? password}) =>
    _pdfjsGetDocumentJsParams({'url': url, 'password': password});

Future<PdfjsDocument> pdfjsGetDocumentFromData(ByteBuffer data,
        {String? password}) =>
    _pdfjsGetDocumentJsParams({'data': data, 'password': password});

@JS()
@staticInterop
@anonymous
class PdfjsDocument {}

extension PdfjsDocumentExts on PdfjsDocument {
  external Promise<PdfjsPage> getPage(int pageNumber);
  external Promise<List?> getPermissions();
  external int get numPages;
  external void destroy();

  external Promise<int> getPageIndex(PdfjsRef ref);
  external Promise<Object> getDestination(String id);
  external Promise<List<dynamic>?> getOutline();
}

@JS()
@staticInterop
@anonymous
class PdfjsPage {}

extension PdfjsPageExts on PdfjsPage {
  external PdfjsViewport getViewport(PdfjsViewportParams params);
  external PdfjsRender render(PdfjsRenderContext params);
  external int get pageNumber;
  external int get rotate;
  external num get userUnit;
  external List<double> get view;

  external Promise<PdfjsTextContent> getTextContent(
      PdfjsGetTextContentParameters params);
  external ReadableStream streamTextContent(
      PdfjsGetTextContentParameters params);

  external Promise<List> getAnnotations(PdfjsGetAnnotationsParameters params);
}

@JS()
@anonymous
class PdfjsViewportParams {
  external factory PdfjsViewportParams(
      {double scale,
      int rotation, // 0, 90, 180, 270
      double offsetX = 0,
      double offsetY = 0,
      bool dontFlip = false});
  external double get scale;
  external set scale(double scale);
  external int get rotation;
  external set rotation(int rotation);
  external double get offsetX;
  external set offsetX(double offsetX);
  external double get offsetY;
  external set offsetY(double offsetY);
  external bool get dontFlip;
  external set dontFlip(bool dontFlip);
}

@JS('PageViewport')
class PdfjsViewport {
  external List<double> get viewBox;
  external set viewBox(List<double> viewBox);

  external double get scale;
  external set scale(double scale);

  /// 0, 90, 180, 270
  external int get rotation;
  external set rotation(int rotation);
  external double get offsetX;
  external set offsetX(double offsetX);
  external double get offsetY;
  external set offsetY(double offsetY);
  external bool get dontFlip;
  external set dontFlip(bool dontFlip);

  external double get width;
  external set width(double w);
  external double get height;
  external set height(double h);

  external List<double>? get transform;
  external set transform(List<double>? m);
}

@JS()
@anonymous
class PdfjsRenderContext {
  external factory PdfjsRenderContext(
      {required web.CanvasRenderingContext2D canvasContext,
      required PdfjsViewport viewport,
      String intent = 'display',
      int annotationMode = 1,
      bool renderInteractiveForms = false,
      List<double>? transform,
      dynamic imageLayer,
      dynamic canvasFactory,
      dynamic background});
  external web.CanvasRenderingContext2D get canvasContext;
  external set canvasContext(web.CanvasRenderingContext2D ctx);
  external PdfjsViewport get viewport;
  external set viewport(PdfjsViewport viewport);

  /// `display` or `print`
  external String get intent;

  external set intent(String intent);

  /// DISABLE=0, ENABLE=1, ENABLE_FORMS=2, ENABLE_STORAGE=3
  external int get annotationMode;
  external set annotationMode(int annotationMode);
  external bool get renderInteractiveForms;
  external set renderInteractiveForms(bool renderInteractiveForms);
  external List<int>? get transform;
  external set transform(List<int>? transform);
  external dynamic get imageLayer;
  external set imageLayer(dynamic imageLayer);
  external dynamic get canvasFactory;
  external set canvasFactory(dynamic canvasFactory);
  external dynamic get background;
  external set background(dynamic background);
}

@JS()
@anonymous
class PdfjsRender {
  external Promise<void> get promise;
}

@JS()
@anonymous
class PdfjsGetTextContentParameters {
  external bool includeMarkedContent;
  external bool disableNormalization;
}

@JS()
@anonymous
class PdfjsTextContent {
  /// Either [PdfjsTextItem] or [PdfjsTextMarkedContent]
  external List<PdfjsTextItem> get items;
  external Object get styles;
}

@JS()
@anonymous
class PdfjsTextItem {
  external String get str;

  /// Text direction: 'ttb', 'ltr' or 'rtl'.
  external String get dir;

  /// Matrix for transformation, in the form [a b c d e f], equivalent to:
  /// | a  b  0 |
  /// | c  d  0 |
  /// | e  f  1 |
  ///
  /// Translation is performed with [1 0 0 1 tx ty].
  /// Scaling is performed with [sx 0 0 sy 0 0].
  /// See PDF Reference 1.7, 4.2.2 Common Transformations for more.
  external List<double> get transform;
  external num get width;
  external num get height;
  external String get fontName;
  external bool get hasEOL;
}

@JS()
@anonymous
class PdfjsTextMarkedContent {
  external String get type;
  external String get id;
}

@JS()
@anonymous
class PdfjsTextStyle {
  external num get ascent;
  external num get descent;
  external bool get vertical;
  external String get fontFamily;
}

@JS('BaseException')
class PdfjsBaseException {
  external String get message;
  external String get name;
}

@JS('PasswordException')
class PdfjsPasswordException {
  external String get message;
  external String get name;
  external String get code;
}

@JS()
@anonymous
class PdfjsGetAnnotationsParameters {
  external factory PdfjsGetAnnotationsParameters({
    String intent = 'display',
  });

  /// 'display' or 'print' or, 'any'
  external String get intent;
}

@JS()
@anonymous
class PdfjsRef {
  external int get num;
  external int get gen;
}

@JS()
@anonymous
class PdfjsAnnotationData {
  external String get subtype;
  external int get annotationType;
  external List get rect;
  external String? get url;
  external String? get unsafeUrl;
  external int get annotationFlags;
  external Object? get dest;
}

@JS()
@anonymous
class PdfjsOutlineNode {
  external String get title;
  external Object? get dest;
  external List<PdfjsOutlineNode> get items;
}

Object _dummyJsSyncContext = {};

bool _pdfjsInitialized = false;

Future<void> ensurePdfjsInitialized() async {
  if (_pdfjsInitialized) return;
  await _dummyJsSyncContext.synchronized(() async {
    await _pdfjsInitialize();
  });
}

Future<void> _pdfjsInitialize() async {
  if (_pdfjsInitialized) return;
  if (_isPdfjsLoaded) {
    _pdfjsInitialized = true;
    return;
  }

  final pdfJsSrc = PdfJsConfiguration.configuration?.pdfJsSrc ?? _pdfjsUrl;
  try {
    final script = web.document.createElement('script') as web.HTMLScriptElement
      ..type = 'text/javascript'
      ..charset = 'utf-8'
      ..async = true
      ..src = pdfJsSrc;
    web.document.querySelector('head')!.appendChild(script);
    await script.onLoad.first.timeout(
        PdfJsConfiguration.configuration?.pdfJsDownloadTimeout ??
            const Duration(seconds: 10));
  } catch (e) {
    throw StateError('Failed to load pdf.js from $pdfJsSrc: $e');
  }

  if (!_isPdfjsLoaded) {
    throw StateError('Failed to load pdfjs');
  }
  _pdfjsWorkerSrc =
      PdfJsConfiguration.configuration?.workerSrc ?? _pdfjsWorkerSrc;

  _pdfjsInitialized = true;
}

@JS()
@anonymous
class ReadableStream {
  external Object cancel();
  external ReadableStreamDefaultReader getReader(dynamic options);
}

@JS()
@anonymous
class ReadableStreamDefaultReader {
  external Object cancel(Object reason);
  external Object read();
  external Object releaseLock();
}

@JS()
@anonymous
class ReadableStreamChunk {
  external Object get value;
  external bool get done;
}
