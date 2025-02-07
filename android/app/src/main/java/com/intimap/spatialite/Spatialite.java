package com.intimap.spatialite;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.system.ErrnoException;
import android.system.Os;

import com.intimap.survey_app.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import jsqlite.Callback;
import jsqlite.Constants;
import jsqlite.Database;
import jsqlite.Exception;
import jsqlite.Stmt;

public class Spatialite {
  private Context _context;
  private String DatabaseDirectory = "";
  private Map<String, Database> SpatialDBs = new HashMap<String, Database>();
  private Map<String, Stmt> SpatialStmts = new HashMap<String, Stmt>();

  public Spatialite(Context context) {
    _context = context;
    SpatialDBs = new HashMap<String, Database>();
    SpatialStmts = new HashMap<String, Stmt>();
  }

  public String connect(String Filename) {
    String md5ID = General.md5(Filename);
    String dbID = "";
    if (SpatialDBs.containsKey(md5ID)) {
      dbID = md5ID;
    } else {

      File dbFile = new File(Filename);

      DatabaseDirectory = dbFile.getParent();
      File DBDir = new File(DatabaseDirectory);
      String ProjDB = DatabaseDirectory + "/proj.db";
      File ProjDBFile = new File(ProjDB);
      if (!ProjDBFile.exists()) {
        InputStream in = _context.getResources().openRawResource(R.raw.proj);
        FileOutputStream out = null;
        try {
          out = new FileOutputStream(ProjDB);
          byte[] buff = new byte[1024];
          int read = 0;
          while ((read = in.read(buff)) > 0) {
            out.write(buff, 0, read);
          }
          in.close();
          out.close();
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
              // MAKE SURE TO SET THIS ENVIRONMENT VARIABLE TO MAKE IT WORK //
              Os.setenv("PROJ_LIB", DBDir.getAbsolutePath(), true);
            } catch (@SuppressLint({"NewApi", "LocalSuppress"}) ErrnoException e) {
              //e.printStackTrace();
            }
          }
        } catch (IOException e) {
          //e.printStackTrace();
        }
      }

      boolean initMeta = false;
      if (!dbFile.exists()) {
        initMeta = true;
      }

      Database db = new Database();
      try {
        db.open(dbFile.getAbsolutePath(), Constants.SQLITE_OPEN_READWRITE | Constants.SQLITE_OPEN_CREATE);
        SpatialDBs.put(md5ID, db);
        dbID = md5ID;
        if (initMeta) {
          init(dbID);
        }
      } catch (Exception e) {
        dbID = "";
      }
    }
    return dbID;
  }

  public String escapeString(String value) {
    //return DatabaseUtils.sqlEscapeString(value);
    return value.replaceAll("'", "''");
  }

  public void init(String link) {
    ArrayList<String> Queries = new ArrayList<>();
    Queries.add("SELECT InitSpatialMetaDataFull(1) as initSpatialMetaDataFull, InitSpatialMetaData(1) as initSpatialMetaData, HasProj6() as HasProj6  ;");
    Queries.add("CREATE TABLE IF NOT EXISTS test ( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT ) ;");
    Queries.add("CREATE INDEX IF NOT EXISTS tName ON test(name) ;");
    Queries.add("SELECT AddGeometryColumn('test', 'geom',  4326, 'GEOMETRY', 2);");
    Queries.add("SELECT CreateSpatialIndex('test','geom');");

    for (int i = 0; i < Queries.size(); i++) {
      String query = Queries.get(i);
      exec(link, query);
            /*
            //Log.d("johkyxxx", query);
            String resID = SpatialQuery(link, query);
            if (!resID.equals("")) {
                HashMap<String, Object> res = SpatialFetch(resID);
                boolean status = (boolean) res.get("status");
                if (status == true) {
                    //HashMap<String, Object> row = (HashMap<String, Object>) res.get("assoc");
                    //Log.d("johkyxxx", (new JSONObject(row)).toString());
                }
                SpatialFreeResult(resID);
            }
             */
    }
    setProjDB(link);
  }

  public String test(String link) {
    String spatialTestResult = "";
    String query = "SELECT " +
      " ROUND(ST_AREA(ST_TRANSFORM(ST_GeomFromText('POLYGON((145.02736150526687 -37.732106014714084,145.02827345633034 -37.73221632261902,145.0282090833176 -37.73260664157798,145.02728640341417 -37.73250694073498,145.02736150526687 -37.732106014714084))',4326),3035)),2) AS area_size, " +
      " ROUND(ST_DISTANCE(MAKEPOINT(145.02736150526687,-37.732106014714084),MAKEPOINT(145.02728640341417,-37.73250694073498),1),2) AS point_distance ;";
    //Log.d("johkyxxx",query) ;
    long curTime = General.currentTimeMicros();
    String resID = query(link, query);
    curTime = General.currentTimeMicros() - curTime;
    if (!resID.equals("")) {
      long curFetchTime = General.currentTimeMicros();
      HashMap<String, Object> res = fetch(resID);
      curFetchTime = General.currentTimeMicros() - curFetchTime;
      //Log.d("johkyxxx", "Query OK : " + (new JSONObject(res)).toString());
      boolean status = (boolean) res.get("status");
      if (status == true) {
        HashMap<String, Object> row = (HashMap<String, Object>) res.get("assoc");
        float area_size = Float.parseFloat("" + row.get("area_size"));
        float point_distance = Float.parseFloat("" + row.get("point_distance"));
        spatialTestResult =
          "Area Should Be Around : 3622.35 sqm\n" +
            "Calculated Area : " + area_size + " sqm\n" +
            "Result Area : " + ((Float.compare(area_size, 3622.35f) == 0) ? "OK" : "NOK") + "\n\n" +
            "Distance Should Be Around : 44.99 sqm\n" +
            "Calculated Distance : " + point_distance + " m\n" +
            "Result Distance : " + ((Float.compare(point_distance, 44.99f) == 0) ? "OK" : "NOK") + "\n\n" +
            "Query in " + curTime + " ms & Fetch Data in " + curFetchTime + " ms\n" +
            "Final Result : " + ((Float.compare(area_size, 3622.35f) == 0 && Float.compare(point_distance, 44.99f) == 0) ? "OK" : "NOK");

      }
      freeResult(resID);
    } else {
      //Log.d("johkyxxx","query error") ;
    }
    return spatialTestResult;
  }

  public void exec(String link, String query) {
    if (SpatialDBs.containsKey(link)) {
      String md5Stmt = General.md5();
      try {
        SpatialDBs.get(link).exec(query, new Callback() {
          @Override
          public void columns(String[] coldata) {
          }

          @Override
          public void types(String[] types) {
          }

          @Override
          public boolean newrow(String[] rowdata) {
            return false;
          }
        });
      } catch (Exception e) {
        //e.printStackTrace();
      }
    }
  }


  public String query(String link, String query) {
    String stmtID = "";
    if (SpatialDBs.containsKey(link)) {
      String md5Stmt = General.md5();
      try {
        Stmt stmt = SpatialDBs.get(link).prepare(query);
        SpatialStmts.put(md5Stmt, stmt);
        stmtID = md5Stmt;
      } catch (Exception e) {
        //e.printStackTrace();
      }
    }
    return stmtID;
  }

  public HashMap<String, Object> fetch(String resId) {
    HashMap<String, Object> res = new HashMap<String, Object>();
    res.put("status", false);
    if (SpatialStmts.containsKey(resId)) {
      Stmt stmt = SpatialStmts.get(resId);
      try {
        if (stmt.step()) {
          res.put("status", true);
          HashMap<String, Object> assoc = new HashMap<String, Object>();
          ArrayList<Object> array = new ArrayList<Object>();

          for (int i = 0; i < stmt.column_count(); i++) {
            array.add(i, stmt.column(i));
            assoc.put(stmt.column_name(i), stmt.column(i));
            //Log.d("johkyxxx", "Fetch : " + i + " -> " + stmt.column_name(i) + " : " + stmt.column(i));
          }
          res.put("assoc", assoc);
          res.put("array", array);
        }
      } catch (Exception e) {
        res.put("status", false);
        //e.printStackTrace();
      }
    } else {
      res.put("status", false);
    }
    return res;
  }

  public HashMap<String, Object> lastError(String link) {
    HashMap<String, Object> res = new HashMap<String, Object>();
    if (SpatialDBs.containsKey(link)) {
      res.put("code", SpatialDBs.get(link).last_error());
      res.put("message", SpatialDBs.get(link).error_message());
      if (res.get("message").equals("not an error")) {
        res.put("code", 0);
      }
    } else {
      res.put("code", 9998);
      res.put("message", "No Connection");
    }
    return res;
  }

  public long lastInsertId(String link) {
    long lastInsertID = -2;
    if (SpatialDBs.containsKey(link)) {
      lastInsertID = SpatialDBs.get(link).last_insert_rowid();
    }
    return lastInsertID;
  }

  public void freeResult(String resId) {
    if (SpatialStmts.containsKey(resId)) {
      try {
        SpatialStmts.get(resId).close();
        SpatialStmts.remove(resId);
      } catch (Exception e) {
        //e.printStackTrace();
      }
    }
  }

  public void disconnect(String link) {
    if (SpatialDBs.containsKey(link)) {
      try {
        SpatialDBs.get(link).close();
        SpatialDBs.remove(link);
        //Log.d("johkyxxx", "Spatialite Disconnect OK");
      } catch (Exception e) {
        //Log.d("johkyxxx", "Spatialite Error Close");
        //e.printStackTrace();
      }
    }
  }


  private void setProjDB(String link) {
    String ProjDBFile = DatabaseDirectory + "/proj.db";
    File f = new File(ProjDBFile);

    if (f.exists()) {
      //Log.d("johkyxxx", "Proj.db file exists");

      String query = "SELECT PROJ_GetDatabasePath() as proj ;";
      //Log.d("johkyxxx", query);
      String resID = query(link, query);
      boolean loadProj = false;
      if (!resID.equals("")) {
        HashMap<String, Object> res = fetch(resID);
        boolean status = (boolean) res.get("status");
        if (status == true) {
          HashMap<String, Object> row = (HashMap<String, Object>) res.get("assoc");
          //Log.d("johkyxxx", (new JSONObject(row)).toString());
          String projRes = (String) row.get("proj");
          if (projRes != null) {
            if (projRes.isEmpty() || projRes.equals("null")) {
              loadProj = true;
            }
          } else {
            loadProj = true;
          }
        }
        freeResult(resID);
      }

      if (loadProj) {
        //Log.d("johkyxxx", "loading Proj.db ");
        query = "SELECT PROJ_SetDatabasePath('" + ProjDBFile + "') as proj ;";
        //Log.d("johkyxxx", query);
        resID = query(link, query);
        if (!resID.equals("")) {
          HashMap<String, Object> res = fetch(resID);
          boolean status = (boolean) res.get("status");
          if (status == true) {
            HashMap<String, Object> row = (HashMap<String, Object>) res.get("assoc");
            //Log.d("johkyxxx", (new JSONObject(row)).toString());
          }
          freeResult(resID);
        }
      } else {
        //Log.d("johkyxxx", "not load Proj.db ");
      }
    } else {
      //Log.d("johkyxxx", "Proj.db file not exists");
    }
  }

  public void disconnectAll() {
    for (String link : SpatialDBs.keySet()) {
      //System.out.println("Disconnect " + link);
      try {
        SpatialDBs.get(link).close();
        SpatialDBs.remove(link);
        //Log.d("johkyxxx", "Spatialite Disconnect OK");
        //System.out.println("Disconnect " + link + " = Success");
      } catch (Exception e) {
        //Log.d("johkyxxx", "Spatialite Error Close");
        //e.printStackTrace();
        //System.out.println("Disconnect " + link + " = Failed");
      }
    }
  }


}
