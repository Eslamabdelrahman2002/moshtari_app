import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatDB {
  ChatDB._();
  static final ChatDB instance = ChatDB._();

  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'mushtary_chat.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (sql, v) async {
        await _createTables(sql);
      },
      onUpgrade: (sql, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await sql.execute('ALTER TABLE conversations ADD COLUMN last_sync INTEGER;');
            debugPrint('✅ DB migrated: Added last_sync column');
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _createTables(Database sql) async {
    await sql.execute('''
      CREATE TABLE conversations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER,
        convo_key TEXT UNIQUE,
        peer_id INTEGER,
        peer_name TEXT,
        peer_avatar TEXT,
        last_message TEXT,
        last_time INTEGER,
        unread_count INTEGER DEFAULT 0,
        last_sync INTEGER
      );
    ''');
    await sql.execute('CREATE INDEX IF NOT EXISTS idx_convo_key ON conversations(convo_key);');

    await sql.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        conversation_id INTEGER,
        convo_key TEXT NOT NULL,
        sender_id INTEGER,
        receiver_id INTEGER,
        content TEXT,
        type TEXT,
        created_at INTEGER,
        status TEXT,
        is_mine INTEGER,
        ad_id INTEGER
      );
    ''');
    await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_convo_key ON messages(convo_key);');
    await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_conv_id ON messages(conversation_id);');
    await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_created ON messages(created_at);');
    await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_convo_created ON messages(convo_key, created_at);');

    // لمنع تكرار الرسائل بسيرفر آي دي
    await sql.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_messages_convo_server ON messages(convo_key, server_id);');
  }
}