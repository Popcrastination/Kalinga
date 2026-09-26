# Design system

![Design system](assets/design-system.pdf)
[Design system (PDF)](assets/design-system.pdf)

## Palette

| Role | Hex | Used for |
|---|---|---|
| Primary | `#1A312C` | App bar (Daily Log / Overview / Profile / Register-back), primary buttons (Login, Create Account), active nav icon |
| onPrimary | `#FFFFFF` | "Kalinga" logo text, button labels on the green app bar / buttons |
| Secondary / Accent | `#428475` | Wellness score % text, "↑5% from yesterday", weekly chart line, outlined Register button, completed-chip color |
| Background | `#FFF4E1` | Screen background on every screen |
| Surface | `#FFFFFF` | Wellness Score card, Weekly Chart card, Daily Summary card, Suggestion cards, Profile info card, text-field fill |
| onSurface / Text | `#1A312C` | Body text on cream or white — form labels, card copy, list rows |
| Error | `#FF0052` | Password-mismatch on Register, "not recognized as food" from Gemini validation |

Light mode only, decided deliberately — see `docs/assets/design-system.pdf`
for the contrast check and full reasoning.

## Type scale

| Style | Flutter slot | Size | Weight | Used for |
|---|---|---|---|---|
| Heading | `headlineSmall` | 24 | Bold | App-bar titles, "Kalinga" logotype |
| Section Title | `titleMedium` | 18 | SemiBold | "Today's Progress", "Weekly Summary", "Goals", etc. |
| Body | `bodyMedium` | 16 | Regular | Form input text, list rows, paragraph text |
| Caption | `labelSmall` | 12 | Regular | Field hints, timestamps, small stats |

## Spacing

Base unit: **8px** — `xs=4, sm=8, md=16, lg=24` (see `lib/constants/app_spacing.dart`).

## Components

| Component | File | Constructor parameters | Appears on |
|---|---|---|---|
| PrimaryButton | `lib/widgets/primary_button.dart` | `String label, VoidCallback? onPressed` | Login, Register |
| AppTextField | `lib/widgets/app_text_field.dart` | `String label, String hint, bool obscureText, TextEditingController controller, String? Function(String?)? validator` | Login, Register, Profile (edit mode) |
| AppBottomNavBar | `lib/widgets/app_bottom_nav_bar.dart` | `int currentIndex, ValueChanged<int> onTap` | Dashboard, Daily Log, Overview, Profile |
| SectionCard | `lib/widgets/section_card.dart` | `Widget child, EdgeInsets? padding` | Dashboard, Overview, Profile |
| ProgressChip | `lib/widgets/progress_chip.dart` | `IconData icon, String label, bool completed` | Dashboard — Today's Progress |
| SuggestionTile | `lib/widgets/suggestion_tile.dart` | `String emoji, String? title, String description` | Dashboard (Quick Insight), Overview (Suggestions) |
| AddEntryRow | `lib/widgets/add_entry_row.dart` | `String label, bool isLogged, VoidCallback onTap` | Daily Log |
| StatRow | `lib/widgets/stat_row.dart` | `IconData icon, String label, String value` | Overview, Profile |
| AvatarPlaceholder | `lib/widgets/avatar_placeholder.dart` | `double radius, String? imageUrl` | Dashboard, Profile |

## Changes since the last version
- `Surface`/text roles corrected from the prelim (`#06202B` navy /
  `#7AE2CF` mint, which failed contrast at ~1.3:1) to `#FFFFFF` /
  `#1A312C` (~12–15:1), matching the actual mockup's light cards.
- Type scale expanded from 3 to 4 sizes to cover the mockup's section-header
  pattern ("Today's Progress", "Goals") that a 3-size scale flattened.
- Components expanded from 3 generic rows to 9 real ones with file paths and
  named constructor parameters, tied to specific mockup elements.
