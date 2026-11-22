package at.anelkoo.untis_plus.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import at.anelkoo.untis_plus.MainActivity
import at.anelkoo.untis_plus.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/** Small widget: the current or next lesson. */
class NextLessonWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) =
        render(context, manager, ids, data, R.layout.widget_next_lesson, withLater = false)
}

/** Medium widget: the current or next lesson plus the rest of that day. */
class TodayWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) =
        render(context, manager, ids, data, R.layout.widget_today, withLater = true)
}

/** The app writes a timeline (see widget_timeline.dart); show the last entry that has started. */
private fun currentEntry(data: SharedPreferences): JSONObject? {
    val timeline = try {
        JSONArray(data.getString("timeline", null) ?: return null)
    } catch (e: Exception) {
        return null
    }
    val now = System.currentTimeMillis()
    var current: JSONObject? = null
    for (i in 0 until timeline.length()) {
        val entry = timeline.getJSONObject(i)
        if (current == null || entry.getLong("from") <= now) current = entry else break
    }
    return current
}

private fun render(
    context: Context,
    manager: AppWidgetManager,
    ids: IntArray,
    data: SharedPreferences,
    layout: Int,
    withLater: Boolean,
) {
    val entry = currentEntry(data)
    for (id in ids) {
        val views = RemoteViews(context.packageName, layout)
        views.setOnClickPendingIntent(R.id.widget_root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        if (entry == null) {
            views.setTextViewText(R.id.widget_label, "")
            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_open_app))
            listOf(R.id.widget_time, R.id.widget_place, R.id.widget_status).forEach { views.setViewVisibility(it, View.GONE) }
        } else {
            views.setTextViewText(R.id.widget_label, entry.optString("label"))
            views.setTextViewText(R.id.widget_title, entry.optString("title"))
            for ((view, key) in listOf(R.id.widget_time to "time", R.id.widget_place to "place", R.id.widget_status to "status")) {
                val text = entry.optString(key)
                views.setTextViewText(view, text)
                views.setViewVisibility(view, if (text.isEmpty()) View.GONE else View.VISIBLE)
            }
        }
        if (withLater) {
            val later = entry?.optJSONArray("later")
            val lines = (0 until (later?.length() ?: 0)).joinToString("\n") { later!!.getString(it) }
            views.setTextViewText(R.id.widget_later, lines)
            views.setViewVisibility(R.id.widget_later, if (lines.isEmpty()) View.GONE else View.VISIBLE)
        }
        manager.updateAppWidget(id, views)
    }
}
