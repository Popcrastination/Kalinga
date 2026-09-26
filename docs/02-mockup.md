# Mockup and wireframes

## Mockup
![Kalinga mockup](assets/mockup.pdf)

Six screens, in order: Login → Register → Dashboard → Daily Log → Overview →
Profile. Login → Register is a one-time, one-directional flow for new users
(existing users skip straight to Dashboard); Dashboard, Daily Log, Overview,
and Profile are siblings reachable from one another at any time via the
bottom nav bar.

## Wireframes
The proposal's original 4-screen concept (Dashboard, Health Logging,
Summary, Profile) served as the wireframe stage; the mockup above is the
painted-in version, with Login/Register added once account creation turned
out to be a real requirement rather than assumed.

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
