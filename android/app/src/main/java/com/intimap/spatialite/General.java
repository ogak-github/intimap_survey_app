package com.intimap.spatialite;

import static java.lang.Math.round;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class General {

  public static long currentTimeMillis() {
    return System.currentTimeMillis();
  }

  public static long currentTimeMicros() {
    return round(System.nanoTime() * 0.001);
  }

  public static String md5() {
    long time = currentTimeMillis();
    return md5("xxx" + time + "xxx");
  }

  public static String md5(final String s) {
    final String MD5 = "MD5";
    try {
      // Create MD5 Hash
      MessageDigest digest = java.security.MessageDigest.getInstance(MD5);
      digest.update(s.getBytes());
      byte messageDigest[] = digest.digest();

      // Create Hex String
      StringBuilder hexString = new StringBuilder();
      for (byte aMessageDigest : messageDigest) {
        String h = Integer.toHexString(0xFF & aMessageDigest);
        while (h.length() < 2)
          h = "0" + h;
        hexString.append(h);
      }
      return hexString.toString();
    } catch (NoSuchAlgorithmException e) {
      e.printStackTrace();
    }
    return "";
  }

}
