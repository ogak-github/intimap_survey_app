package com.intimap;

import android.content.Context;
import android.os.Build;

import androidx.annotation.RequiresApi;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;

import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class MyGpsPositions {
  private static final String CHANNEL = "com.intimap.gps_positions/nativechannel";


  public void init(Context context, FlutterEngine flutterEngine) {
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          // Note: this method is invoked on the main thread.
          if (call.method.equals("checkPosition")) {
            List<GpsPositions.CursorResult> gpsPositions = GpsPositions.checkPosition(context.getApplicationContext());

            if (gpsPositions == null) {
              result.error("ERROR", "Cursor is null", null);
              return;
            }
            List<Map<String, Object>> dartGpsPositions = new ArrayList<>();

            for (GpsPositions.CursorResult position : gpsPositions) {
              Map<String, Object> dartPosition = new HashMap<>();
              dartPosition.put("type", position.type);
              dartPosition.put("content", position.content);
              dartGpsPositions.add(dartPosition);
            }

            result.success(dartGpsPositions);

          } else if (call.method.equals("isMDTAvailable")) {
            boolean isAvailable = GpsPositions.isProviderAvailable(context.getApplicationContext());
            result.success(isAvailable);
          } else if (call.method.equals("startMDTService")) {
            boolean isStarted = GpsPositions.startMDTService(context.getApplicationContext());
            result.success(isStarted);
          } else if (call.method.equals("insertRequest")) {
            String deviceId = call.argument("deviceId");
            String command = call.argument("command");
            if (deviceId != null && command != null) {
                String insertRequestSendReport = GpsPositions.insertRequest(context.getApplicationContext(), deviceId, command);
                result.success(insertRequestSendReport);
            } else if (deviceId != null) {
                String insertRequestSendReport = GpsPositions.insertRequest(context.getApplicationContext(), deviceId, null);
                result.success(insertRequestSendReport);
            } else if (command != null) {
                String insertRequestSendReport = GpsPositions.insertRequest(context.getApplicationContext(), null, command);
                result.success(insertRequestSendReport);
            } else {
                result.error("ERROR", "Neither deviceId nor command were provided", null);
            }
          } else {
            result.notImplemented();
          }
        }
      );
  }
}
