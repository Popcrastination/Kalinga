<img width="393" height="852" alt="wireframe-profile" src="https://github.com/user-attachments/assets/7e78c51a-7f5a-40e2-a08d-ca91550d7888" /># Mockup and wireframes

## Mockup
![<img width="2000" height="802" alt="image" src="https://github.com/user-attachments/assets/5d1f0432-1097-4ca0-969d-23bbee65a9a6" />
](assets/mockup.pdf)

| Log-In | Register | Dashboard |
| --- | --- | --- |
| ![<img width="472" height="902" alt="image" src="https://github.com/user-attachments/assets/afcc8d8a-fea5-41d8-8113-3c649163c3af" />](docs/assets/screen-log-in.png) | ![<img width="473" height="905" alt="image" src="https://github.com/user-attachments/assets/7f4fd628-fe01-41b0-bcef-bd5bb462c1b4" />](docs/assets/screen-register.png) | ![<img width="487" height="901" alt="image" src="https://github.com/user-attachments/assets/88d829b4-0ad9-450a-9bf3-753ad43f27e7" />](docs/assets/screen-dashboard.png) |

| Daily Log | Overview | Profile |
| --- | --- | --- |
| ![<img width="497" height="899" alt="image" src="https://github.com/user-attachments/assets/2642741b-4eaf-42d3-9f86-4bdb93e39292" />](docs/assets/screen-daily-log.png) | ![<img width="498" height="900" alt="image" src="https://github.com/user-attachments/assets/7616776d-72d8-42b2-a3c4-1145fe9e9d34" />](docs/assets/screen-overview.png) | ![<img width="495" height="904" alt="image" src="https://github.com/user-attachments/assets/218d408d-1eed-46b1-b6d4-6cf659396512" />](docs/assets/screen-profile.png) |

## Wireframes
| Dashboard | Daily Log |
| --- | --- |
| ![<img width="393" height="852" alt="wireframe-dashboard" src="https://github.com/user-attachments/assets/95990eea-f9ce-4244-bb76-60bf39c40bee" />](docs/assets/wireframe-dashboard.png) | ![<img width="393" height="852" alt="wireframe-daily-log" src="https://github.com/user-attachments/assets/321f8d76-0964-48f7-b1d6-5f4151106ebb" />](docs/assets/wireframe-daily-log.png) 

| Overview | Profile |
| --- | --- |
| ![<img width="393" height="852" alt="wireframe-overview" src="https://github.com/user-attachments/assets/ec64850d-b99e-45ee-adcc-f78aa59a37ba" />
](docs/assets/wireframe-overview.png) | ![<img width="393" height="852" alt="wireframe-profile" src="https://github.com/user-attachments/assets/6cab7ca1-e32d-4b83-b76a-e0e674180f8f" />](docs/assets/wireframe-profile.png) |

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
