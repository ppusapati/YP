import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'agriculture.crop.v1.CropService';

  group('CropServiceClient', () {
    group('getCrop', () {
      test('sends correct request and parses response', () async {
        final responseCrop = Crop(id: 'crop-1', name: 'Wheat');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetCrop');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(responseCrop.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final crop = await client.getCrop('crop-1');
        expect(crop.id, 'crop-1');
        expect(crop.name, 'Wheat');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('not found', 404);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getCrop('crop-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.method, 'method',
                  '$serviceName/GetCrop')),
        );
      });

      test('applies interceptors to request headers', () async {
        final responseCrop = Crop(id: 'crop-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer crop-token');
          return http.Response.bytes(responseCrop.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer crop-token';
              return headers;
            },
          ],
        );

        await client.getCrop('crop-1');
      });
    });

    group('listCrops', () {
      test('sends correct request and returns list', () async {
        final responseCrop = Crop(id: 'farm-1', name: 'Corn');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListCrops');
          return http.Response.bytes(responseCrop.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final crops = await client.listCrops('farm-1');
        expect(crops, isNotEmpty);
        expect(crops.first.name, 'Corn');
      });
    });

    group('createCrop', () {
      test('sends crop and returns created crop', () async {
        final responseCrop =
            Crop(id: 'crop-new', name: 'Rice', variety: 'Basmati');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CreateCrop');
          final sentCrop = Crop.fromBuffer(request.bodyBytes);
          expect(sentCrop.name, 'Rice');
          return http.Response.bytes(responseCrop.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final crop = await client.createCrop(Crop(name: 'Rice'));
        expect(crop.id, 'crop-new');
        expect(crop.variety, 'Basmati');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 400);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.createCrop(Crop(name: 'Test')),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getCropRequirements', () {
      test('sends correct request and returns requirements', () async {
        final response = CropRequirements(
          cropId: 'crop-1',
          minTemp: 15.0,
          maxTemp: 35.0,
          waterNeeds: 500.0,
          soilType: 'loamy',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetCropRequirements');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final requirements = await client.getCropRequirements('crop-1');
        expect(requirements.cropId, 'crop-1');
        expect(requirements.minTemp, 15.0);
        expect(requirements.maxTemp, 35.0);
        expect(requirements.waterNeeds, 500.0);
        expect(requirements.soilType, 'loamy');
      });
    });

    group('addVariety', () {
      test('sends variety and returns result', () async {
        final responseVariety =
            CropVariety(id: 'var-1', cropId: 'crop-1', name: 'Durum');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/AddVariety');
          return http.Response.bytes(responseVariety.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final variety = await client
            .addVariety(CropVariety(cropId: 'crop-1', name: 'Durum'));
        expect(variety.id, 'var-1');
        expect(variety.name, 'Durum');
      });
    });

    group('getGrowthStages', () {
      test('sends correct request and returns stages', () async {
        final responseStage = GrowthStage(
          id: 'stage-1',
          cropId: 'crop-1',
          name: 'Germination',
          durationDays: 14,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetGrowthStages');
          return http.Response.bytes(responseStage.writeToBuffer(), 200);
        });

        final client = CropServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final stages = await client.getGrowthStages('crop-1');
        expect(stages, isNotEmpty);
        expect(stages.first.name, 'Germination');
        expect(stages.first.durationDays, 14);
      });
    });
  });
}
