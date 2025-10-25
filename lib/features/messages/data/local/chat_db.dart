import 'dart:async';
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
      version: 1,
      onCreate: (sql, v) async {
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
            unread_count INTEGER DEFAULT 0
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
            status TEXT,  -- pending/sent/delivered/read/failed
            is_mine INTEGER, -- 1 true, 0 false
            ad_id INTEGER
          );
        ''');

        await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_convo_key ON messages(convo_key);');
        await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_conv_id ON messages(conversation_id);');
        await sql.execute('CREATE INDEX IF NOT EXISTS idx_msgs_created ON messages(created_at);');
      },
    );
  }
}