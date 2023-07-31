reboot:
	@echo "cuttlefish reboot, begin"
	./bin/adb reboot

stop:
	@echo "stop previous cuttlefish device"
	HOME=$$PWD ./bin/stop_cvd
	@echo "cuttlefish device stop, done"

shell:
	./bin/adb shell

root:
	./bin/adb root

remount:
	@echo "cuttlefish remount, begin"
	./bin/adb root
	sleep 1
	./bin/adb remount
	./bin/adb reboot
	sleep 20
	./bin/adb root
	@echo "cuttlefish reboot, done"

mount-sec:
	sleep 30
	./bin/adb shell "mount -t securityfs securityfs /sys/kernel/security"
	@echo "cuttlefish securityfs mount, done"

mount-debug:
	./bin/adb shell "mount -t debugfs debugfs /sys/kernel/debug"
	@echo "cuttlefish debugfs mount, done"

mount-sys:
	./bin/adb shell "mount -o rw,remount /system"
	@echo "cuttlefish /system mount rw, done"

mount: mount-sec mount-debug mount-sys

remount-all: remount mount