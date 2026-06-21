# Cidre Recovery Guide (v0.2.0)

If your graphical session or greeting manager breaks, this document provides the steps to safely recover your environment.

## 1. Access Fallback Console (TTY)
If the login screen hangs or loop-crashes, press:
`Ctrl + Alt + F2` (or F3, F4, etc.)
Log in using your user account credentials.

## 2. Using the `cidre-recovery` Tool
The `cidre-recovery` command-line utility provides operations to fix standard configuration or service issues:

*   **Disable Greetd:**
    If the graphical login loop prevents access to your system, run this to fall back to text console logins on next boot:
    ```bash
    sudo cidre-recovery disable-greetd
    ```
*   **Reset Niri config:**
    If custom compositor settings are causing crashes, restore default configurations:
    ```bash
    cidre-recovery reset-niri-config
    ```
*   **Force redeploy user profiles:**
    Re-deploy default settings for fuzzel, Waybar, starship, Mozc, and Ghostty:
    ```bash
    cidre-recovery reset-user-config
    ```
*   **Reset Audio cache:**
    ```bash
    cidre-recovery reset-audio
    ```
*   **Collect system logs:**
    Bundles diagnostic reports to `/var/log/cidre-recovery-bundle.tar.gz` for submission:
    ```bash
    cidre-recovery collect-logs
    ```
*   **Safe-mode execution:**
    Launches `niri-cidre` with standard fallback configurations:
    ```bash
    cidre-recovery safe-mode
    ```
