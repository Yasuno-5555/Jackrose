# Firstboot Service Ordering

## Systemd Unit Design

The `cidre-firstboot-root.service` is defined as a standard systemd one-shot service running early in the system setup cycle.

```ini
[Unit]
Description=Cidre Firstboot Root Setup
Documentation=file:/usr/share/doc/cidre/firstboot-oobe.md
After=basic.target
Wants=network-online.target
ConditionPathExists=!/var/lib/cidre/firstboot-root/completed
ConditionPathExists=!/var/lib/cidre/firstboot-root/skipped

[Service]
Type=oneshot
ExecStart=/usr/lib/cidre/cidre-firstboot-root --non-interactive
RemainAfterExit=yes
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
```

## After vs. Wants Policy

To ensure the system boots successfully even in offline configurations, `After=network-online.target` is avoided. Network targets can introduce massive timeout stalls (up to 90 seconds or more) when network cables are unplugged or Wi-Fi is unconfigured. 

Instead:
* **After=basic.target**: Ensures that basic system resources, filesystem mounts, and base device nodes are initialized.
* **Wants=network-online.target**: Declares a soft dependency on network online readiness, allowing the system to proceed without blocking if network initialization fails.

## Console Output and Visibility

Using `StandardOutput=journal+console` and `StandardError=journal+console` allows users to track setup logs directly from the tty1 display console, avoiding black screens or silent hangs that disguise system configuration failures.

## Repeated Execution Prevention

By adding `ConditionPathExists=!/var/lib/cidre/firstboot-root/completed` and `ConditionPathExists=!/var/lib/cidre/firstboot-root/skipped`, we guarantee the OOBE logic is only run exactly once. Once the completion marker is created, subsequent boots skip the service.
