# Keep failure handling bounded
Preserve an absolute nonrenewing deadline across read failures. Use bounded cleanup only for proved-owned processes and retain terminal failure when ownership or cleanup cannot be certified. A saved PID or retained executable does not establish current ownership or activity.
This authored method note carries the v0.1.0 common operating contract; it is guidance, not a new process test.
