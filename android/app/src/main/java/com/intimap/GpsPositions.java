package com.intimap;

import android.content.ComponentName;
import android.content.ContentProviderClient;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.UriMatcher;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;


import com.intimap.utils.DateHelper;

import java.util.ArrayList;
import java.util.List;

//import io.sentry.Sentry;

public class GpsPositions {

  // columns of position table
  public static final String TABLE_POS = "position";
  public static final String COLUMN_POS_ID = "id";
  public static final String COLUMN_POS_DATA = "pos_data";
  public static final String COLUMN_POS_INSERT_DATE = "insert_date";
  public static final String COLUMN_POS_TYPE = "type";    // 1: position, 2: reply command
  // columns of queue outgoing table
  public static final String TABLE_QUEUE = "queue";
  public static final String COLUMN_QUEUE_ID = "id";
  public static final String COLUMN_QUEUE_DEVICEID = "deviceid";  // device id
  public static final String COLUMN_QUEUE_MSG = "msg";
  public static final String COLUMN_QUEUE_MSGDT = "msg_dt";       // datetime from message
  public static final String COLUMN_QUEUE_POPUP = "popup";
  static final int POSITIONS_GET_ALL = 1;
  static final int POSITIONS_GET_ID = 2;
  static final int POSITIONS_UPDATE_ID = 3;
  static final int POSITIONS_DEL_ID = 4;
  static final int POSITIONS_DEL_LT_ID = 5;
  static final int POSITIONS_DEL_LE_ID = 6;
  static final int POSITIONS_DEL_GT_ID = 7;
  static final int POSITIONS_DEL_GE_ID = 8;
  static final int POSITIONS_INSERT = 9;
  static final int REQUESTS = 101;
  static final int REQUESTS_GET_ID = 102;
  static final int REQUESTS_INSERT = 103;
  static final int QUERY_GET = 201;
  static final int QUERY_EXEC = 202;
  private static final String PROVIDER_NAME = "com.intimap.hawk_mdt.DatabaseProvider";
  private static final String URL = "content://" + PROVIDER_NAME;
  static final Uri CONTENT_URI = Uri.parse(URL);
  public static final String ACTION_START_MDT_SERVICE = "ACTION_START_FOREGROUND_SERVICE";
  public static final String MDT_PACKAGE_NAME = "com.intimap.hawk_mdt";
  public static final String MDT_SERVICE_CLASS_NAME = "com.intimap.hawk_mdt.SerialForegroundService";
  private static final UriMatcher uriMatcher;

  static {
    uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    uriMatcher.addURI(PROVIDER_NAME, "position/get_all", POSITIONS_GET_ALL);
    uriMatcher.addURI(PROVIDER_NAME, "position/get/#", POSITIONS_GET_ID);
    uriMatcher.addURI(PROVIDER_NAME, "position/delete_le/#", POSITIONS_DEL_LE_ID);    // less equal than id <=
    uriMatcher.addURI(PROVIDER_NAME, "position/insert", POSITIONS_INSERT);
    uriMatcher.addURI(PROVIDER_NAME, "request/insert", REQUESTS_INSERT);
  }

  public static class CursorResult {
    public String type;
    public String content;

    public CursorResult(String type, String content) {
      this.type = type;
      this.content = content;
    }
  }

  public static boolean isProviderAvailable(Context context){
    boolean available = false;

    try {
        ContentProviderClient provider = context.getContentResolver().acquireContentProviderClient(PROVIDER_NAME);
        if (provider != null){
            provider.release();
            available = true;
        }
    }
    catch(IllegalArgumentException | SecurityException e){
        // Provider is not available
    }

    return available;
  }


  public static List<CursorResult> checkPosition(Context context) {
    Cursor cursor = getGpsPosCursor(context);
    List<CursorResult> gpsPositions = new ArrayList<>();
    if (cursor == null) {
      return null;
    }
    if (cursor.getCount() <= 0) {
      cursor.close();
      return gpsPositions;
    }
    if (!cursor.moveToFirst()) {
      cursor.close();
      return gpsPositions;
    }
    long lastId = 0;
    String lastDate = "";
    while (!cursor.isAfterLast()) {
      int posIndex = cursor.getColumnIndex(COLUMN_POS_DATA);
      int typeIndex = cursor.getColumnIndex(COLUMN_POS_TYPE);
      int idIndex = cursor.getColumnIndex(COLUMN_POS_ID);
      int dateIndex = cursor.getColumnIndex(COLUMN_POS_INSERT_DATE);
      if (posIndex >= 0 && typeIndex >= 0 && idIndex >= 0) {
        String posString = cursor.getString(posIndex);
        String type = cursor.getString(typeIndex);
        lastId = cursor.getLong(idIndex);
        lastDate = cursor.getString(dateIndex);
        gpsPositions.add(new CursorResult(type, posString));
      }
      cursor.moveToNext();
    }
    // Log.d("DebugLastID", "Save LastID: " + lastId);
    // SharedPreferencesHelper.saveLastId(context, lastId);
    // Log.d("DebugDate", "Save Last Date: " + lastDate);
    SharedPreferencesHelper.saveLastDate(context, lastDate);
    cursor.close();
    return gpsPositions;
  }

  private static Cursor getGpsPosCursor(Context context) {
    Cursor cursor;
    String lastInsertDate = SharedPreferencesHelper.getLastDate(context);
    try {
      cursor =
        context
          .getContentResolver()
          .query(
            Uri.parse(URL + "/position/get_all"),
            null,
            lastInsertDate == "" ? null : COLUMN_POS_INSERT_DATE + " >= '" + lastInsertDate + "'",
            null,
            null,
            null
          );
    } catch (Exception ex) {
      //Sentry.captureException(ex);
      cursor = null;
    }
    return cursor;
  }

  public static String insertRequest(Context context, String deviceId, String command) {
    String currDt = DateHelper.getUTCDateTime(DateHelper.getCurrentUnixTime());
    ContentValues values = new ContentValues();
    if(deviceId != null) {
      values.put(COLUMN_QUEUE_DEVICEID, deviceId);
    }
    if(command != null) {
      values.put(COLUMN_QUEUE_MSG, command);
    }
    values.put(COLUMN_QUEUE_MSGDT, currDt);
    values.put(COLUMN_QUEUE_POPUP, 0);
    try {
      context.getContentResolver().insert(Uri.parse(URL + "/request/insert"), values);
      return "Success Insert";
    } catch (Exception ex) {
      //Sentry.captureException(ex);
      return ex.getMessage();
    }
  }

  public static boolean startMDTService(Context context) {
    try {
      Intent mdtService = new Intent();
      mdtService.setAction(ACTION_START_MDT_SERVICE);
      mdtService.setComponent(
        new ComponentName(MDT_PACKAGE_NAME, MDT_SERVICE_CLASS_NAME)
      );
      context.startService(mdtService);
      String lastDate = SharedPreferencesHelper.getLastDate(context);
      if (lastDate != null) {
        Log.d("DebugStart", "Delete Last Date: " + lastDate);
        String threeDaysBefore = DateHelper.getNewDateBeforeThreeDays(lastDate);
        String sql = "DELETE FROM " + TABLE_POS + " WHERE (" + COLUMN_POS_INSERT_DATE + " <= '" + threeDaysBefore + "' );";
        Log.d("DebugStart", "Delete Three Days Before: " + threeDaysBefore);
        Log.d("DebugStart", "Delete SQL: " + sql);
        try {
          context.
            getContentResolver()
            .query(Uri.parse(URL + "/query/exec/" + sql), null, null, null, null);
        } catch (Exception e) {
          Log.d("DebugStart", "Error Delete: " + e.getMessage());
          // //Sentry.captureException(e);
        }
      }
      return true;
    } catch (Exception ex) {
      Log.d("DebugStartMDT", "Error: " + ex.getMessage());
      //Sentry.captureException(ex);
      return false;
    }
  }
}
