# Mockup and wireframes

## Mockup
![Kalinga mockup](assets/mockup.pdf)

| Log-In | Register | Dashboard |
| --- | --- | --- |
| ![Log-In](docs/assets/screen-log-in.png) | ![Register](docs/assets/screen-register.png) | ![Dashboard](docs/assets/screen-dashboard.png) |

| Daily Log | Overview | Profile |
| --- | --- | --- |
| ![Daily Log](docs/assets/screen-daily-log.png) | ![Overview](docs/assets/screen-overview.png) | ![Add](docs/assets/screen-profile.png) |

## Wireframes
| Dashboard | Daily Log |
| --- | --- |
| ![Dashboard](docs/assets/wireframe-dashboard.png) | ![Daily Log](docs/assets/wireframe-daily-log.png) 

| Overview | Profile |
| --- | --- |
| ![Overview](docs/assets/wireframe-overview.png) | ![Add](docs/assets/wireframe-profile.png) |

## Screens

### Login
User signs in with username + password.
- *Login button* → Dashboard
- *Register link* → Register

### Register
User creates an account (username, name, DOB, height, weight, password).
- *Create Account button* → Dashboard
- *Back arrow* → Login

### Dashboard
User checks today's wellness score, progress, and sleep trend at a glance.
- *Profile avatar* → Profile
- *Bottom nav: Home / Daily Log / Overview / Profile* → respective screens

### Daily Log
User logs meals, drinks, sleep hours, and exercise minutes for the day.
- *+ buttons (Breakfast/Lunch/Dinner/Drinks)* → opens input for that entry
  (Gemini-validated)
- *Bottom nav* → Dashboard / Overview / Profile

### Overview
User reviews Gemini's daily summary, weekly trends, and suggestions.
- *Bottom nav* → Dashboard / Daily Log / Profile

### Profile
User views and edits personal info and goals.
- *Edit button* → edit mode (height, weight, avatar)
- *Log out button* → Login
- *Bottom nav* → Dashboard / Daily Log / Overview
