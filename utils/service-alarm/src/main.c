
#include "alarm.h"
#include <syslog.h>


static GMainLoop *loop;
static Alarm *skeleton;

static gboolean
emit_alarm_cb (gpointer skeleton)
{
	alarm_emit_beeeeeeeeep (ALARM (skeleton));
	alarm_set_activated (ALARM (skeleton), FALSE);
	return FALSE;
}

static gboolean
on_handle_configure (Alarm *skeleton,
	GDBusMethodInvocation *invocation,
	guint seconds)
{
	if (alarm_get_activated (skeleton)) {
		g_dbus_method_invocation_return_error_literal (invocation,
				G_IO_ERROR,
				G_IO_ERROR_EXISTS,
				"Exists");
		return;
	}

	alarm_set_activated (skeleton, TRUE);
	g_timeout_add_seconds (seconds, emit_alarm_cb, skeleton);
	alarm_complete_configure (skeleton, invocation);
}

static void
name_acquired (GDBusConnection *connection,
	const gchar *name,
	gpointer user_data)
{
	skeleton = alarm_skeleton_new ();
	g_signal_connect (skeleton,
			"handle-configure",
			G_CALLBACK (on_handle_configure),
			NULL);

	g_dbus_interface_skeleton_export (
			G_DBUS_INTERFACE_SKELETON (skeleton),
			connection,
			"/es/aleksander/Alarm",
			NULL);
}

static void
name_lost_cb (GDBusConnection *connection,
		const gchar *name,
		gpointer user_data)
{
	if (!name)
		syslog (LOG_CRIT, "%s", "Could not get the system bus");
	else
		syslog (LOG_CRIT, "%s", "Could not acquire service name");

	g_main_loop_quit (loop);
}

int
main (void)
{
	loop = g_main_loop_new (NULL, FALSE);

	g_bus_own_name (G_BUS_TYPE_SYSTEM,
			"es.aleksander.Alarm",
			G_BUS_NAME_OWNER_FLAGS_NONE,
			NULL,
			name_acquired,
			name_lost_cb,
			NULL,
			NULL);

	g_main_loop_run (loop);

	return 0;
}
