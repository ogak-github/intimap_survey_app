package com.intimap;

import android.content.SharedPreferences;
import android.content.Context;


public class SharedPreferencesHelper {

  public static final String MY_PREFS = "MY_PREFS";
  public static final String LAST_ID = "LAST_ID";
  public static final String LAST_DATE = "LAST_DATE";

  public static void saveLastId(Context context, long id) {
    SharedPreferences.Editor editor = context
      .getSharedPreferences(MY_PREFS, Context.MODE_PRIVATE)
      .edit();
    editor.putLong(LAST_ID, id);
    editor.apply();
  }

  public static long getLastId(Context context) {
    SharedPreferences prefs = context.getSharedPreferences(
      MY_PREFS,
      Context.MODE_PRIVATE
    );
    return prefs.getLong(LAST_ID, 0);
  }

  public static void saveLastDate(Context context, String date) {
    SharedPreferences.Editor editor = context
      .getSharedPreferences(MY_PREFS, Context.MODE_PRIVATE)
      .edit();
    editor.putString(LAST_DATE, date);
    editor.apply();
  }

  public static String getLastDate(Context context) {
    SharedPreferences prefs = context.getSharedPreferences(
      MY_PREFS,
      Context.MODE_PRIVATE
    );
    return prefs.getString(LAST_DATE, "");
  }
}
