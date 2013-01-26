 src/utils/wpa_debug.c |   32 ++++++++++++++++++++++++++++++--
 src/utils/wpa_debug.h |   31 +++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/src/utils/wpa_debug.c b/src/utils/wpa_debug.c
index 27a61c0..b5d02dc 100644
--- a/src/utils/wpa_debug.c
+++ b/src/utils/wpa_debug.c
@@ -21,13 +21,40 @@

 static int wpa_debug_syslog = 0;
 #endif /* CONFIG_DEBUG_SYSLOG */
-
-
+#ifdef CONFIG_ANDROID_LOG
+int wpa_debug_level = MSG_WARNING;
+#else
 int wpa_debug_level = MSG_INFO;
+#endif
 int wpa_debug_show_keys = 0;
 int wpa_debug_timestamp = 0;


+#ifdef CONFIG_ANDROID_LOG
+
+#include <android/log.h>
+
+void android_printf(int level, char *format, ...)
+{
+	if (level >= wpa_debug_level) {
+		va_list ap;
+		if (level == MSG_ERROR) {
+			level = ANDROID_LOG_ERROR;
+		} else if (level == MSG_WARNING) {
+			level = ANDROID_LOG_WARN;
+		} else if (level == MSG_INFO) {
+			level = ANDROID_LOG_INFO;
+		} else {
+			level = ANDROID_LOG_DEBUG;
+		}
+		va_start(ap, format);
+		__android_log_vprint(level, "wpa_supplicant", format, ap);
+		va_end(ap);
+	}
+}
+
+#else /* CONFIG_ANDROID_LOG */
+
 #ifndef CONFIG_NO_STDOUT_DEBUG

 #ifdef CONFIG_DEBUG_FILE
@@ -340,6 +367,7 @@ void wpa_debug_close_file(void)

 #endif /* CONFIG_NO_STDOUT_DEBUG */

+#endif /* CONFIG_ANDROID_LOG */

 #ifndef CONFIG_NO_WPA_MSG
 static wpa_msg_cb_func wpa_msg_cb = NULL;
diff --git a/src/utils/wpa_debug.h b/src/utils/wpa_debug.h
index 0c8cdf2..d31fa85 100644
--- a/src/utils/wpa_debug.h
+++ b/src/utils/wpa_debug.h
@@ -24,6 +24,36 @@ enum {
 	MSG_EXCESSIVE, MSG_MSGDUMP, MSG_DEBUG, MSG_INFO, MSG_WARNING, MSG_ERROR
 };

+#ifdef CONFIG_ANDROID_LOG
+
+#define wpa_debug_print_timestamp() do {} while (0)
+#define wpa_hexdump(...)            do {} while (0)
+#define wpa_hexdump_key(...)        do {} while (0)
+#define wpa_hexdump_buf(l,t,b)      do {} while (0)
+#define wpa_hexdump_buf_key(l,t,b)  do {} while (0)
+#define wpa_hexdump_ascii(...)      do {} while (0)
+#define wpa_hexdump_ascii_key(...)  do {} while (0)
+#define wpa_debug_open_file(...)    do {} while (0)
+#define wpa_debug_close_file()      do {} while (0)
+#define wpa_dbg(...)                do {} while (0)
+
+static inline int wpa_debug_reopen_file(void)
+{
+	return 0;
+}
+
+
+void android_printf(int level, char *format, ...);
+
+#define wpa_printf(level, ...) \
+        do {                                            \
+            if ((level) >= MSG_DEBUG) {                  \
+                android_printf((level), __VA_ARGS__);   \
+            }                                           \
+        } while (0)
+
+#else /* CONFIG_ANDROID_LOG */
+
 #ifdef CONFIG_NO_STDOUT_DEBUG

 #define wpa_debug_print_timestamp() do { } while (0)
@@ -157,6 +187,7 @@ void wpa_hexdump_ascii_key(int level, const char
*title, const u8 *buf,

 #endif /* CONFIG_NO_STDOUT_DEBUG */

+#endif /* CONFIG_ANDROID_LOG */

 #ifdef CONFIG_NO_WPA_MSG
 #define wpa_msg(args...) do { } while (0)

