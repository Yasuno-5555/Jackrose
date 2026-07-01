import QtQuick

// Liquid Catppuccin Mocha — Design System Colors
// Design spec v1.0
QtObject {
    // Base palette
    property string base: "#1e1e2e"
    property string mantle: "#181825"
    property string crust: "#11111b"
    property string surface0: "#313244"

    // Text
    property string text: "#cdd6f4"
    property string subtext0: "#a6adc8"
    property string subtext1: "#bac2de"

    // Accents
    property string mauve: "#cba6f7"       // Primary accent
    property string sapphire: "#89b4fa"     // Secondary accent (design spec corrected)
    property string rosewater: "#f5e0dc"    // Warm highlight
    property string sky: "#89dceb"

    // Semantic
    property string red: "#f38ba8"          // Danger
    property string green: "#a6e3a1"        // Success
    property string yellow: "#f9e2af"       // Warning
    property string peach: "#fab387"
    property string teal: "#94e2d5"
    property string lavender: "#b4befe"

    // Surface (glass panels)
    property string surface: "#2b11111b"    // rgba(17, 17, 27, 0.17)
    property string surfaceBorder: "#38ffffff" // rgba(255, 255, 255, 0.22)
    property string surfaceHighlight: "#14ffffff" // rgba(255, 255, 255, 0.08)
    property string surfaceHover: "#2effffff"   // rgba(255, 255, 255, 0.18)

    // For compatibility with existing code
    property string colors_mauve: mauve
    property string colors_sapphire: sapphire
    property string colors_rosewater: rosewater
    property string colors_base: base
    property string colors_mantle: mantle
    property string colors_crust: crust
    property string colors_text: text
}
