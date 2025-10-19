// lib/features/product_details/data/repo/auction_socket_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

import '../model/place_bid_result.dart';

typedef MaxBidUpdateCallback = void Function(num maxBid, String type, int auctionId);

class AuctionSocketService {
  late IO.Socket _socket;
  final String _host;
  final bool _secure;
  final MaxBidUpdateCallback? onMaxBidUpdate;

  AuctionSocketService({
    required String host,
    bool secure = false,
    this.onMaxBidUpdate,
  })  : _host = host,
        _secure = secure {
    _initSocket();
  }

  void _initSocket() {
    final token = CacheHelper.getData(key: 'token') as String?;
    final scheme = _secure ? 'https' : 'http';

    if (token == null) {
      if (kDebugMode) print('AuctionSocketService: Token is missing.');
      return;
    }

    try {
      _socket = IO.io(
        '$scheme://$_host',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setQuery({'token': token})
            .enableForceNew()
            .enableReconnection()
            .setTimeout(20000)
            .build(),
      );

      _socket.onConnect((_) {
        if (kDebugMode) print('Auction Socket Connected');
      });

      _socket.onDisconnect((_) {
        if (kDebugMode) print('Auction Socket Disconnected');
      });

      _socket.on('updateMaxBid', (data) {
        if (kDebugMode) print('Received updateMaxBid: $data');
        if (data is Map && onMaxBidUpdate != null) {
          final maxBid = num.tryParse(data['max_bid'].toString()) ?? 0;
          final type = data['auction_type']?.toString() ?? '';
          final auctionId = int.tryParse(data['auctionId'].toString()) ?? 0;
          onMaxBidUpdate!(maxBid, type, auctionId);
        }
      });

      _socket.onError((error) {
        if (kDebugMode) print('Auction Socket Error: $error');
      });
    } catch (e) {
      if (kDebugMode) print('Auction Socket Initialization Error: $e');
    }
  }

  bool get isConnected => _socket.connected;

  void joinAuction({required int auctionId, required String auctionType}) {
    if (!_socket.connected) return;
    final data = {"auctionId": auctionId, "auction_type": auctionType};
    if (kDebugMode) print('Emitting joinAuction: $data');
    _socket.emit('joinAuction', data);
  }

  void leaveAuction({required int auctionId, required String auctionType}) {
    if (!_socket.connected) return;
    final data = {"auctionId": auctionId, "auction_type": auctionType};
    if (kDebugMode) print('Emitting leaveAuction: $data');
    _socket.emit('leaveAuction', data);
  }

  Future<PlaceBidResult> placeBid({
    required int auctionId,
    required num bidAmount,
    required String auctionType,
    required int itemId,
  }) async {
    if (!_socket.connected) {
      return PlaceBidResult(success: false, message: 'Socket not connected');
    }

    final data = {
      "auctionId": auctionId,     // أرسل كـ int
      "bid_amount": bidAmount,
      "auction_type": auctionType,
      "item_id": itemId,          // أرسل كـ int
    };
    if (kDebugMode) print('Emitting placeBid with Ack: $data');

    final completer = Completer<PlaceBidResult>();

    // أرسل الـ object مباشرة بدل [data]
    _socket.emitWithAck('placeBid', data, ack: (response) {
      if (kDebugMode) print('placeBid Ack Received: $response');
      completer.complete(PlaceBidResult.fromAck(response));
    });

    return completer.future;
  }

  void getMaxBid({required int auctionId, required String auctionType, required int itemId}) {
    if (!_socket.connected) return;
    final data = {"auctionId": auctionId, "item_id": itemId, "auction_type": auctionType};
    if (kDebugMode) print('Emitting getMaxBid: $data');
    _socket.emit('getMaxBid', data);
  }

  void dispose() {
    _socket.dispose();
  }
}