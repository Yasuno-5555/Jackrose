# Cidre Audio Configuration Guide

Cidre utilizes the PipeWire audio server and WirePlumber session manager, configured to integrate safely with Asahi Linux sound capabilities (speakersafetyd, bankstown).

## Buffer Tuning and Pop Noise Mitigation

To address popping/cracking noises that occur during seek operations (e.g. on YouTube Music), Cidre provides customizable audio profiles. These adjust WirePlumber buffer sizes (quantums) for ALSA output nodes.

## The `cidre-audio` Tool

You can configure sound states, adjust volume, toggle mute, and select profiles using the command-line helper:

```bash
# Display system audio status and current profile
cidre-audio status

# Get or set volume (e.g. 5%+, 5%-, 0.5, or a raw fraction)
cidre-audio volume 5%+
cidre-audio volume 10%-
cidre-audio volume 0.7

# Mute/unmute default audio sink
cidre-audio mute
cidre-audio unmute

# Restart PipeWire and WirePlumber services
cidre-audio restart

# Perform a quick diagnostic check and fix common service issues
cidre-audio doctor

# Switch to standard audio profiles
cidre-audio profile stable        # Sets quantum=1024, period=1024 (Mitigates seek pop noises)
cidre-audio profile balanced      # Sets quantum=512, period=512 (Recommended standard settings)
cidre-audio profile low-latency   # Sets quantum=256, period=256 (Low delay for DTM/gaming)

# Reset local configurations and cache back to default
cidre-audio reset
```

Profiles are deployed to `~/.config/wireplumber/wireplumber.conf.d/99-cidre-audio.conf`.
