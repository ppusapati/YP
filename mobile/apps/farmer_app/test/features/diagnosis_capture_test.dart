import 'dart:io';
import 'dart:typed_data';

import 'package:farmer_app/features/ai_diagnosis/data/datasources/diagnosis_remote_datasource.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/diagnosis.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The capture path, end to end from the file on disk to the request body.
///
/// The bug this pins: `submitDiagnosis` used to pass the picker's path
/// straight through as `imageUrl`, so the server received
/// `/data/user/0/in.p9e.farmer/cache/CAP1234.jpg` — an address only that phone
/// can resolve. plant-diagnosis-service accepts https and s3 only, rejected
/// every one, and the AI gateway got no bytes. A photo taken in the app was
/// accepted and never analysed.

/// Captures what the app actually put on the wire.
///
/// A real [ConnectClient] over a fake transport rather than a hand-written
/// double: the headers, the protobuf encoding and the non-200 mapping are all
/// the client's, and a double would assert against a copy of them.
class _Wire {
  _Wire({this.status = 200, List<int>? responseBody})
      : _responseBody = responseBody ?? SubmitDiagnosisResponse().writeToBuffer();

  final int status;
  final List<int> _responseBody;

  Uri? seenUrl;
  Uint8List? seenBody;

  ConnectClient get client => ConnectClient(
        // `baseUrl` is a bare host — the client supplies the scheme.
        config: const ApiConfig(baseUrl: 'api.test'),
        httpClient: MockClient((request) async {
          seenUrl = request.url;
          seenBody = request.bodyBytes;
          return http.Response.bytes(_responseBody, status);
        }),
      );

  SubmitDiagnosisRequest get sentRequest =>
      SubmitDiagnosisRequest.fromBuffer(seenBody!);
}

/// Writes [bytes] to a real file, because reading one is the point.
Future<String> _writePhoto(List<int> bytes, {String name = 'CAP1234.jpg'}) async {
  final dir = await Directory.systemTemp.createTemp('diagnosis_capture');
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  return file.path;
}

void main() {
  // JPEG magic, so the bytes are recognisably an image rather than filler.
  final photo = Uint8List.fromList(
    [0xFF, 0xD8, 0xFF, 0xE0, ...List<int>.filled(64, 0x42), 0xFF, 0xD9],
  );

  group('submitDiagnosis', () {
    test('sends the photo bytes, not the path', () async {
      final wire = _Wire();
      final source = DiagnosisRemoteDataSourceImpl(client: wire.client);
      final path = await _writePhoto(photo);

      await source.submitDiagnosis(fieldId: 'field-1', imagePath: path);

      final sent = wire.sentRequest;
      expect(sent.images, hasLength(1));
      expect(
        sent.images.first.imageBytes,
        photo,
        reason: 'the server can only classify bytes it was given',
      );
      expect(
        sent.images.first.imageUrl,
        isEmpty,
        reason: 'a device path is not an address the server can resolve, '
            'so sending it as a URL is worse than sending nothing',
      );
      expect(sent.fieldId, 'field-1');
    });

    test('addresses SubmitDiagnosis on the diagnosis service', () async {
      final wire = _Wire();
      final source = DiagnosisRemoteDataSourceImpl(client: wire.client);

      await source.submitDiagnosis(
        fieldId: 'field-1',
        imagePath: await _writePhoto(photo),
      );

      expect(
        wire.seenUrl.toString(),
        'https://api.test/agriculture.diagnosis.v1.PlantDiagnosisService/SubmitDiagnosis',
      );
    });

    test('labels the content type from the file extension', () async {
      for (final entry in {
        'leaf.jpg': 'image/jpeg',
        'leaf.png': 'image/png',
        'leaf.webp': 'image/webp',
        'leaf.HEIC': 'image/heic',
        'leaf': 'image/jpeg',
      }.entries) {
        final wire = _Wire();
        final source = DiagnosisRemoteDataSourceImpl(client: wire.client);

        await source.submitDiagnosis(
          fieldId: 'field-1',
          imagePath: await _writePhoto(photo, name: entry.key),
        );

        final sent = wire.sentRequest;
        expect(sent.images.first.mimeType, entry.value, reason: entry.key);
      }
    });

    test('says the photo is missing rather than sending an empty image',
        () async {
      final wire = _Wire();
      final source = DiagnosisRemoteDataSourceImpl(client: wire.client);

      // image_picker writes to a cache directory the OS can clear at any time.
      await expectLater(
        source.submitDiagnosis(
          fieldId: 'field-1',
          imagePath: '/tmp/definitely-not-here/CAP0000.jpg',
        ),
        throwsA(isA<ConnectException>().having(
          (e) => e.message,
          'message',
          contains('Could not read the photo'),
        )),
      );

      expect(wire.seenBody, isNull, reason: 'nothing should be sent');
    });

    test('refuses an oversized photo before uploading it', () async {
      final wire = _Wire();
      final source = DiagnosisRemoteDataSourceImpl(client: wire.client);
      final huge = List<int>.filled(
        DiagnosisRemoteDataSourceImpl.maxImageBytes + 1,
        7,
      );

      await expectLater(
        source.submitDiagnosis(
          fieldId: 'field-1',
          imagePath: await _writePhoto(huge),
        ),
        throwsA(isA<ConnectException>().having(
          (e) => e.message,
          'message',
          allOf(contains('MB'), contains('limit')),
        )),
      );

      expect(
        wire.seenBody,
        isNull,
        reason: 'spending a rural upload on bytes the server will reject '
            'is the worst of both',
      );
    });

    test('surfaces a server failure rather than an empty diagnosis', () async {
      final wire = _Wire(status: 500);
      final source = DiagnosisRemoteDataSourceImpl(client: wire.client);

      await expectLater(
        source.submitDiagnosis(
          fieldId: 'field-1',
          imagePath: await _writePhoto(photo),
        ),
        throwsA(isA<ConnectException>()),
      );
    });
  });
}
