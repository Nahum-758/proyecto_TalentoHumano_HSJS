import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talento_humano/src/app.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';

const String kSupabaseUrl = 'https://orbeomotefuxeiqxwzud.supabase.co';
const String kSupabaseAnonKey =
    'sb_publishable_h5djKYm6F6IbPXz7Ob2tTw_Krsmb3YM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(const TalentoHumanoApp());

  TalentoHumanoStore.instance.sincronizarDesdeSupabase();
}