# C/C++ positive control
Synthetic accepted design: acquire the permitted file, verify its type and size on that opened descriptor, then read the same descriptor within bounds. Preserve ownership and error paths. Named ancestor checks alone do not prove confinement against a hostile filesystem writer. Byte identity does not establish every runtime safety property.
Authored from the C/C++ Agent role and the current loader design review. This is a design control; native execution is not claimed.
