package com.intimap.utils;

import android.annotation.SuppressLint;
import android.os.Build;
import android.text.format.DateUtils;
//import io.sentry.Sentry;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class DateHelper {

  public static final String PATTERN_ISO_8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSX";
  public static final String PATTERN_ISO_8601_2 =
    "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
  public static final String PATTERN_DATE = "yyyy-MM-dd";

  public static Date parseISO8601(String date) {
    try {
      return getDateFormatter().parse(date);
    } catch (ParseException e) {
      ////Sentry.captureException(e);
      e.printStackTrace();
    }

    return null;
  }

  public static Date parseDate(String dateString, String format) {
    SimpleDateFormat dateFormat = new SimpleDateFormat(format, Locale.US);
    dateFormat.setTimeZone(TimeZone.getDefault());
    try {
      return dateFormat.parse(dateString);
    } catch (ParseException e) {
      ////Sentry.captureException(e);
      e.printStackTrace();
    }
    return null;
  }

  public static String formatISODate(Date date) {
    return getDateFormatter().format(date);
  }

  public static SimpleDateFormat getDateFormatter() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      return new SimpleDateFormat(PATTERN_ISO_8601, Locale.US);
    }
    return new SimpleDateFormat(PATTERN_ISO_8601_2, Locale.US);
  }

  public static boolean isDateMoreThanOneDayAgo(String dateString) {
    if (dateString == null || dateString.isEmpty()) {
        return false;
    }

    try {
        SimpleDateFormat dateFormat;

        if (dateString.matches("\\d{14}")) {  // it means it's in 'yyyyMMddHHmmss' format
            dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        } else {
            dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        }

        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));  // set timezone to UTC
        Date inputDate = dateFormat.parse(dateString);

        Date currentDate = new Date();
        long differenceInMillis = currentDate.getTime() - inputDate.getTime();
        long daysDifference = differenceInMillis / (1000 * 60 * 60 * 24);

        return daysDifference > 1;
    } catch (ParseException e) {
        e.printStackTrace();
        return false;
    }
  }

  //create function for get new date before 3 days than given string date
  public static String getNewDateBeforeThreeDays(String dateString) {
    if (dateString == null || dateString.isEmpty()) {
        return "";
    }

    try {
        SimpleDateFormat dateFormat;

        if (dateString.matches("\\d{14}")) {  // it means it's in 'yyyyMMddHHmmss' format
            dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        } else {
            dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        }

        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));  // set timezone to UTC
        Date inputDate = dateFormat.parse(dateString);

        Calendar cal = Calendar.getInstance();
        cal.setTime(inputDate);
        cal.add(Calendar.DATE, -3);  // get date before 3 days
        Date newDate = cal.getTime();

        return dateFormat.format(newDate);
    } catch (ParseException e) {
        e.printStackTrace();
        return "";
    }
  }

  public static String formatDateHuman(Date date) {
    if (DateUtils.isToday(date.getTime())) {
      return "Today";
    }
    return new SimpleDateFormat("d MMMM y", Locale.US).format(date);
  }

  public static String formatDateHuman2(Date date) {
    if (DateUtils.isToday(date.getTime())) {
      return "Today";
    }
    return new SimpleDateFormat("d MMM", Locale.US).format(date);
  }

  public static String formatDateTimeHuman(Date date) {
    return new SimpleDateFormat("d MMMM y, KK:mm a", Locale.US).format(date);
  }

  @SuppressWarnings("unused")
  public static String formatDateSimple(Date date) {
    return new SimpleDateFormat("d MMM", Locale.US).format(date);
  }

  public static String formatDateCustom(Date date, String pattern) {
    return new SimpleDateFormat(pattern, Locale.US).format(date);
  }

  @SuppressWarnings("unused")
  public static String formatDateCustom(
    Date date,
    String pattern,
    TimeZone tz
  ) {
    SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.US);
    dateFormat.setTimeZone(tz);
    return dateFormat.format(date);
  }

  public static Date getDate00(Date date) {
    String sDate = DateHelper.formatDateCustom(date, "yyyy-MM-dd");
    return DateHelper.parseDate(sDate, "yyyy-MM-dd");
  }

  public static Date getToday00() {
    return getDate00(new Date());
  }

  public static Date addDays(Date date, int days) {
    Calendar cal = Calendar.getInstance();
    cal.setTime(date);
    cal.add(Calendar.DATE, days); //minus number would decrement the days
    return cal.getTime();
  }

  public static long getCurrentUnixTime() {
    return System.currentTimeMillis() / 1000L;
  }

  public static String getUTCDateTime(long unixtime) {
    return getDate(
      unixtime,
      "yyyy-MM-dd HH:mm:ss",
      TimeZone.getTimeZone("UTC")
    );
  }

  public static String getDate(long unixtime, String format, TimeZone tz) {
    long msTime = unixtime * 1000L;
    Date mdate = new Date(msTime);
    @SuppressLint("SimpleDateFormat")
    SimpleDateFormat dateFormat = new SimpleDateFormat(format);
    dateFormat.setTimeZone(tz);
    return dateFormat.format(mdate);
  }

  public static String getTimeFromNow(Date date) {
    long timeDifference = System.currentTimeMillis() - date.getTime();

    if (timeDifference < 60_000) {
      return (timeDifference / 1000) + " seconds ago";
    } else if (timeDifference < 3_600_000) {
      return (timeDifference / 60_000) + " minutes ago";
    } else if (timeDifference < 86_400_000) {
      return (timeDifference / 3_600_000) + " hours ago";
    } else {
      return (timeDifference / 86_400_000) + " days ago";
    }
  }
}
