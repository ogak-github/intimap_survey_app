package com.intimap.survey_app

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.intimap.spatialite.MySpatialite;
import com.intimap.MyGpsPositions;

class MainActivity: FlutterActivity() {
   private var spatialite: MySpatialite? = null;
   private var gpsPosition: MyGpsPositions? = null;
  
   override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (flutterEngine != null) {
            // GeneratedPluginRegistrant.registerWith(flutterEngine!!)
            if (spatialite == null) {
                spatialite = MySpatialite()
            }
            if (gpsPosition == null) {
                gpsPosition = MyGpsPositions()
            }
            spatialite?.init(context, flutterEngine)
            gpsPosition?.init(context, flutterEngine)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (flutterEngine != null) {
            spatialite?.dispose()
        }
    }

}
