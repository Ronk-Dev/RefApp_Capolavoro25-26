//Servizio per le notifiche per Android anche ad app chiusa

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificaLocale {
  //Prendo il plugin per le notifiche
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _prefsKey = 'notifiche_schedulate';

  //Inizializzo la notifica
  static Future<void> init() async {
    //Setto la zona locale come Roma
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    //Prendo le impostazioni e setto il canale di notifica
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    //Aggiungi qui: EFFETTI SPECIALI, VIBRAZIONE ecc. ecc.
    const channel = AndroidNotificationChannel(
      'notifiche_s4y',
      'Notifiche S4Y',
      importance: Importance.high,
      enableVibration: true,
    );

    //Rendo effettivo il canale
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);
  }

static Future<void> schedula({
  required int id,
  required String titolo,
  required String corpo,
  required DateTime quando,
}) async {
  final scheduledTime = tz.TZDateTime(
    tz.local,
    quando.year,
    quando.month,
    quando.day,
    quando.hour,
    quando.minute,
    quando.second,
  );

  // Salta se la data è già passata
  if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
    print('Notifica ignorata: data già passata ($scheduledTime)');
    return;
  }

    await _plugin.zonedSchedule(
      id: id,
      title: titolo,
      body: corpo,
      scheduledDate: scheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'notifiche_s4y',
          'Notifiche S4Y',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await _salvaNotifica(id: id, titolo: titolo, corpo: corpo, quando: quando);
  }

  static Future<void> cancella(int id) async {
    await _plugin.cancel(id: id);
    await _rimuoviNotifica(id);
  }

  static Future<void> cancellatutte() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  static Future<void> ripristinaDopoRiavvio() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    final ora = DateTime.now();

    for (final item in raw) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      final quando = DateTime.parse(map['quando'] as String);

      if (quando.isBefore(ora)) {
        await _rimuoviNotifica(map['id'] as int);
        continue;
      }

      await schedula(
        id: map['id'] as int,
        titolo: map['titolo'] as String,
        corpo: map['corpo'] as String,
        quando: quando,
      );
    }
  }

  static Future<void> _salvaNotifica({
    required int id,
    required String titolo,
    required String corpo,
    required DateTime quando,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_prefsKey) ?? [];
    lista.removeWhere((e) => (jsonDecode(e)['id'] as int) == id);
    lista.add(jsonEncode({
      'id': id,
      'titolo': titolo,
      'corpo': corpo,
      'quando': quando.toIso8601String(),
    }));
    await prefs.setStringList(_prefsKey, lista);
  }

  static Future<void> _rimuoviNotifica(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_prefsKey) ?? [];
    lista.removeWhere((e) => (jsonDecode(e)['id'] as int) == id);
    await prefs.setStringList(_prefsKey, lista);
  }
}