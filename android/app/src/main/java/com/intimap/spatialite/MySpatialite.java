package com.intimap.spatialite;

import android.content.Context;
import android.os.Build;

import androidx.annotation.RequiresApi;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;

import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class MySpatialite {
  private static final String CHANNEL = "com.intimap.spatialite/nativechannel";

  private Spatialite spatialite = null ;

  public void dispose() {
      if (spatialite != null) {
          spatialite.disconnectAll();
      }
  }


  public void init(Context context, FlutterEngine flutterEngine) {
    if (spatialite == null) {
        spatialite = new Spatialite(context);
    }


    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler((call, result) -> {
        switch (call.method) {
          // Connection actions
          case "connect": {
            String filename = call.argument("filename");
            String linkID = spatialite.connect(filename);
            result.success(linkID);
            break;
          }
          case "disconnect": {
            String linkID = call.argument("link_id");
            spatialite.disconnect(linkID);
            result.success("OK");
            break;
          }

          // Initialization & Test actions
          case "init": {
            String linkID = call.argument("link_id");
            spatialite.init(linkID);
            result.success("OK");
            break;
          }
          case "test": {
            String linkID = call.argument("link_id");
            String status = spatialite.test(linkID);
            result.success(status);
            break;
          }

          // Query & Execution actions
          case "query": {
            String linkID = call.argument("link_id");
            String query = call.argument("query");
            String resID = spatialite.query(linkID, query);
            result.success(resID);
            break;
          }
          case "exec": {
            String linkID = call.argument("link_id");
            String query = call.argument("query");
            spatialite.exec(linkID, query);
            result.success("OK");
            break;
          }

          // Fetch actions
          case "fetch": {
            String resID = call.argument("res_id");
            Map<String, Object> res = spatialite.fetch(resID);
            result.success(res);
            break;
          }
          case "fetchJson": {
            String resID = call.argument("res_id");
            Map<String, Object> res = spatialite.fetch(resID);
            JSONObject json = new JSONObject(res);
            result.success(json.toString());
            break;
          }

          // Utility actions
          case "freeResult": {
            String resID = call.argument("res_id");
            spatialite.freeResult(resID);
            result.success("OK");
            break;
          }
          case "escapeString": {
            String value = call.argument("value");
            if (value == null) {
              result.success(null);
              break;
            }
            String escapedValue = spatialite.escapeString(value);
            result.success(escapedValue);
            break;
          }

          // Error & Insert ID actions
          case "lastError": {
            String linkID = call.argument("link_id");
            Map<String, Object> res = spatialite.lastError(linkID);
            result.success(res);
            break;
          }
          case "lastInsertId": {
            String linkID = call.argument("link_id");
            long res = spatialite.lastInsertId(linkID);
            result.success(res);
            break;
          }
        }
      });
  }
}
