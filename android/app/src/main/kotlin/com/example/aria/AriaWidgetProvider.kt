package com.ibrahimadiallo.aria

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AriaWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.aria_widget).apply {
                val pct = widgetData.getInt("pct", 0)
                val equilibre = widgetData.getString("equilibre", "") ?: ""
                val projets = widgetData.getString("projets", "") ?: ""
                setTextViewText(R.id.widget_pct, "$pct%")
                setTextViewText(R.id.widget_equilibre, equilibre)
                setTextViewText(R.id.widget_projets, projets)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
