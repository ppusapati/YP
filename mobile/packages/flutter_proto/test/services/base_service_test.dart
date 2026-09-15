import 'dart:convert';

import 'package:flutter_proto/flutter_proto.dart';
import 'package:flutter_proto/src/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

/// BaseService is where every service client's wire behaviour lives — the URL
/// it builds, the Connect headers it sets, how it reports a failure — and it
/// had no tests at all. The fourteen files that used to sit next to this one
/// tested a client API that does not exist: messages with the wrong fields,
/// methods no client declares, request types that were never the request type.
/// They could not compile, so none of them had ever run.
///
/// This file and service_clients_test.dart replace them with the same
/// intent — does a call go to the right place in the right shape — written
/// against what is actually there.

/// A minimal client, so the base class can be tested without a real service.
class _ProbeClient extends BaseService {
  _ProbeClient({required super.baseUrl, super.httpClient, super.interceptors});

  @override
  String get serviceName => 'agriculture.probe.v1.ProbeService';

  Future<GetFarmResponse> probe(String id) async {
    final bytes = await callUnary('Probe', GetFarmRequest(id: id));
    return GetFarmResponse.fromBuffer(bytes);
  }
}

void main() {
  const baseUrl = 'http://localhost:8080';
  const path = 'agriculture.probe.v1.ProbeService/Probe';

  group('callUnary', () {
    test('posts to baseUrl/service/method', () async {
      late Uri seen;
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((request) async {
          seen = request.url;
          expect(request.method, 'POST');
          return http.Response.bytes(GetFarmResponse().writeToBuffer(), 200);
        }),
      );

      await client.probe('farm-1');

      expect(seen.toString(), '$baseUrl/$path');
    });

    test('sets the Connect protocol headers', () async {
      // Without these two a Connect server rejects the call, and it does so
      // with a 4xx that looks like the request was wrong rather than the
      // envelope.
      late Map<String, String> headers;
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((request) async {
          headers = request.headers;
          return http.Response.bytes(GetFarmResponse().writeToBuffer(), 200);
        }),
      );

      await client.probe('farm-1');

      expect(headers['Content-Type'], 'application/proto');
      expect(headers['Connect-Protocol-Version'], '1');
    });

    test('sends the request as encoded protobuf, not JSON', () async {
      late List<int> body;
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((request) async {
          body = request.bodyBytes;
          return http.Response.bytes(GetFarmResponse().writeToBuffer(), 200);
        }),
      );

      await client.probe('farm-42');

      // Decodes back to the message that went in. Asserting on the bytes
      // rather than on a field keeps this a test of the encoding rather than
      // of protobuf's getters.
      expect(GetFarmRequest.fromBuffer(body).id, 'farm-42');
    });

    test('parses the response body into the response message', () async {
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((_) async => http.Response.bytes(
              GetFarmResponse(farm: Farm(id: 'farm-1', name: 'North'))
                  .writeToBuffer(),
              200,
            )),
      );

      final response = await client.probe('farm-1');

      expect(response.farm.id, 'farm-1');
      expect(response.farm.name, 'North');
    });

    test('applies interceptors in order, after the defaults', () async {
      // Order matters: an interceptor that sets Authorization must win over
      // anything set before it, and the second must see what the first did.
      late Map<String, String> headers;
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((request) async {
          headers = request.headers;
          return http.Response.bytes(GetFarmResponse().writeToBuffer(), 200);
        }),
        interceptors: [
          (h) async => {...h, 'Authorization': 'Bearer first'},
          (h) async => {...h, 'X-Saw-Auth': h['Authorization'] ?? 'none'},
        ],
      );

      await client.probe('farm-1');

      expect(headers['Authorization'], 'Bearer first');
      expect(headers['X-Saw-Auth'], 'Bearer first');
      // The defaults survive an interceptor that rebuilds the map.
      expect(headers['Connect-Protocol-Version'], '1');
    });

    test('throws ServiceException naming the method and status', () async {
      // The method name is what makes a failure traceable in a log: "500" on
      // its own says nothing about which call failed.
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((_) async => http.Response('boom', 500)),
      );

      await expectLater(
        client.probe('farm-1'),
        throwsA(isA<ServiceException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.method, 'method', path)),
      );
    });

    test('treats every non-200 as a failure, including redirects', () async {
      // A 3xx body is not a protobuf message. Parsing it would fail somewhere
      // further away with a message about a corrupt buffer.
      for (final status in [204, 301, 400, 401, 404, 503]) {
        final client = _ProbeClient(
          baseUrl: baseUrl,
          httpClient: MockClient((_) async => http.Response('', status)),
        );
        await expectLater(
          client.probe('farm-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', status)),
          reason: 'status $status should not be treated as success',
        );
      }
    });

    test('does not swallow a transport failure', () async {
      // A DNS failure or a refused connection is not a ServiceException with a
      // status — there is no status. It has to come out as itself.
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((_) async => throw http.ClientException(
              'connection refused',
            )),
      );

      await expectLater(client.probe('farm-1'), throwsA(isA<Exception>()));
    });
  });

  group('ServiceException', () {
    test('says which call failed and why', () {
      const e = ServiceException(
        method: 'agriculture.farm.v1.FarmService/GetFarm',
        statusCode: 503,
        message: 'RPC call failed with status 503',
      );

      final text = e.toString();
      expect(text, contains('agriculture.farm.v1.FarmService/GetFarm'));
      expect(text, contains('503'));
    });
  });

  group('callServerStream', () {
    test('adds the streaming content encoding header', () async {
      // Identity encoding is what tells a Connect server not to expect
      // compressed frames; without it the first frame is misread.
      late Map<String, String> headers;
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((request) async {
          headers = request.headers;
          return http.Response.bytes(utf8.encode('frame'), 200);
        }),
      );

      await client
          .callServerStream('Watch', GetFarmRequest(id: 'farm-1'))
          .toList();

      expect(headers['Connect-Content-Encoding'], 'identity');
      expect(headers['Connect-Protocol-Version'], '1');
    });

    test('fails the stream on a non-200 rather than yielding nothing',
        () async {
      // An empty stream and a rejected one look identical to a caller that
      // only iterates, which is how a failed subscription becomes "no data".
      final client = _ProbeClient(
        baseUrl: baseUrl,
        httpClient: MockClient((_) async => http.Response('nope', 403)),
      );

      await expectLater(
        client.callServerStream('Watch', GetFarmRequest(id: 'farm-1')).toList(),
        throwsA(isA<ServiceException>()
            .having((e) => e.statusCode, 'statusCode', 403)),
      );
    });
  });
}
