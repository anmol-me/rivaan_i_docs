import 'dart:convert';
import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:rivaan_i_docs/models/document_model.dart';
import 'package:rivaan_i_docs/models/error_model.dart';

import '../constants.dart';

/// Provider
final documentRepositoryProvider = Provider((ref) => DocumentRepository(
      client: Client(),
    ));

/// Class
class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  /// ------------------------------------------------------------------------------------------------------
  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error =
        const ErrorModel(error: 'Some error occurred', data: null);

    try {
      var res = await _client.post(
        Uri.parse('$host/doc/create'),
        body: json.encode({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "x-auth-token": token,
        },
      );

      log(res.statusCode.toString());
      log('${jsonDecode(res.body)['createdAt']}');

      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromMap(
              jsonDecode(res.body),
            ),
          );
          break;
        default:
          error = ErrorModel(
            error: res.body,
            data: null,
          );
      }
    } catch (e) {
      log('AR-createDoc: ${e}');
      ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  /// ------------------------------------------------------------------------------------------------------
  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error =
        const ErrorModel(error: 'Some error occurred', data: null);

    try {
      var res = await _client.get(
        Uri.parse('$host/docs/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "x-auth-token": token,
        },
      );

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];

          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(
              DocumentModel.fromMap(
                jsonDecode(res.body)[i],
              ),
            );
          }

          error = ErrorModel(
            error: null,
            data: documents,
          );
          break;
        default:
          error = ErrorModel(
            error: res.body,
            data: null,
          );
          break;
      }
    } catch (e) {
      log('AR-getDoc: ${e}');
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  /// ------------------------------------------------------------------------------------------------------
  void updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'title': title,
        'id': id,
      }),
    );
  }

  /// ------------------------------------------------------------------------------------------------------
  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error = const ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );

    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromMap(jsonDecode(res.body)),
          );
          break;
        default:
          throw 'This Document does not exist, please create a new one.';
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }
}
