# AeroBag – Excess Baggage Fee Calculator

A Flutter mobile app that estimates the excess baggage fee for air travel.

ICT602 Mobile Technology and Development – Individual Assignment

## Features

- Enter the checked baggage weight (kg), ticket class and excess rate per kg (RM)
- Calculates the excess baggage weight, excess baggage charge and total amount payable (with 8% service tax)
- Input validation with clear error messages
- Allowance used progress bar
- Share the result to other apps
- Navigation menu with Home and About pages
- About page with app icon, author information, copyright notice and GitHub link

## Calculation

| Ticket class | Free allowance (X) |
| --- | --- |
| Economy | 20 kg |
| Business | 40 kg |

```
Excess weight  = baggage weight - X   (never below 0)
Excess charge  = excess weight x rate per kg
Total payable  = excess charge + (8% x excess charge)
```

### Sample results

| Weight (kg) | Class | Rate (RM) | Excess (kg) | Charge (RM) | Total (RM) |
| --- | --- | --- | --- | --- | --- |
| 25 | Economy | 15 | 5 | 75.00 | 81.00 |
| 18 | Economy | 15 | 0 | 0.00 | 0.00 |
| 55 | Business | 12 | 15 | 180.00 | 194.40 |
| 42.5 | Business | 12 | 2.5 | 30.00 | 32.40 |

## Packages used

- [share_plus](https://pub.dev/packages/share_plus) – share the result
- [url_launcher](https://pub.dev/packages/url_launcher) – open the GitHub link
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) – generate the app icon

## How to run

```
flutter pub get
flutter run
```

## Author

- **Name:** Amirah Maisarah Binti Abdul Razak
- **Matric No:** 2025426422
- **Course:** ICT602 Mobile Technology and Development

© 2026 Amirah Maisarah Binti Abdul Razak. All rights reserved.
