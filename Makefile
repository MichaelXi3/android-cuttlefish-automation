DOWNLOADS_DIR=${HOME}/Downloads
DOCUMENTS_DIR=${HOME}/Documents
ADB=${PWD}/bin/adb

remount:
	@echo "cuttlefish remount, begin"
	${ADB} root
	sleep 1
	${ADB} remount
	${ADB} reboot
	sleep 20
	${ADB} root
	@echo "cuttlefish reboot, done"

mount-sec:
	sleep 30
	${ADB} shell "mount -t securityfs securityfs /sys/kernel/security"
	@echo "cuttlefish securityfs mount, done"

mount-debug:
	${ADB} shell "mount -t debugfs debugfs /sys/kernel/debug"
	@echo "cuttlefish debugfs mount, done"

mount-sys:
	${ADB} shell "mount -o rw,remount /system"
	@echo "cuttlefish /system mount rw, done"

mount: mount-sec mount-debug mount-sys

remount-all: remount mount

prepare:
	${ADB} push ${DOWNLOADS_DIR}/camflowd /data/local/tmp
	@echo "camflowd executable copied to /data/local/tmp, done"
	${ADB} push ${DOWNLOADS_DIR}/camflowexample /data/local/tmp
	@echo "camflowexample executable copied to /data/local/tmp, done"
	${ADB} push ${DOWNLOADS_DIR}/camconfd /data/local/tmp
	@echo "camconfd executable copied to /data/local/tmp, done"
	${ADB} shell "cd /data/local/tmp && chmod 777 camflowd && chmod 777 camflowexample && chmod 777 camconfd"
	@echo "camflowd, camflowexample, camconfd chomod, done"
	${ADB} push ${DOWNLOADS_DIR}/camflowd.ini /data/local/tmp
	@echo "camflowd.ini configuration copy, done"
	${ADB} push ${DOWNLOADS_DIR}/camflow.ini /data/local/tmp
	@echo "camflow.ini configuration copy, done"
	${ADB} push ${DOWNLOADS_DIR}/input.txt /data/local/tmp
	@echo "input.txt copy, done"
	${ADB} push ${DOWNLOADS_DIR}/libprovenance.so /system/lib64
	@echo "libprovenance.so copy, done"
	${ADB} push ${DOWNLOADS_DIR}/camflow-cli /system/bin
	@echo "camflow-cli copy, done"
	${ADB} shell "cd /system/bin && mv camflow-cli camflow"
	${ADB} shell "chmod 777 /system/bin/camflow"
	@echo "camflow-cli chmod, done"

clean:
	${ADB} shell "cd /data/local/tmp && rm *"
	@echo "clean, done"

run-camflowd:
	${ADB} shell "/data/local/tmp/camflowd" &
	@echo "camflowd executed, done"

run-camconfd:
	${ADB} shell "/data/local/tmp/camconfd" &
	@echo "camconfd executed, done"

run-example:
	${ADB} shell "/data/local/tmp/camflowexample"
	@echo "camflow example executed, done"

run: run-camconfd run-camflowd run-example

stop:
	@echo "stop previous cuttlefish device"
	HOME=$$PWD ${ADB} stop_cvd
	@echo "cuttlefish device stop, done"

shell:
	${ADB} shell

root:
	${ADB} root

pull:
	${ADB} pull /data/local/tmp/audit.log ${DOCUMENTS_DIR}
	@echo "pull audit.log from cuttlefish to Documents, done"
