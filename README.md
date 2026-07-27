# 🚀 FocusFlow

> A modern 3-tier productivity tracking application built with **React**, **Express.js**, and **PostgreSQL**, designed to demonstrate a complete software development workflow and serve as a foundation for Dockerized deployment and CI/CD automation.

---

## 📖 Project Overview

FocusFlow is a productivity tracking application that helps users monitor and improve their focus habits by logging work sessions.

Users can record each focus session by providing:

* Task name
* Category
* Duration
* Mood after completing the session

The application stores all records in a PostgreSQL database and displays productivity statistics and recent sessions through an intuitive dashboard.

This project was developed as part of a Cloud & DevOps Bootcamp capstone to demonstrate a complete **3-tier architecture** and prepare the application for containerization, automated deployment, and CI/CD.

---

# ✨ Features

* 📚 Record focus sessions
* 📊 View productivity statistics
* ⏱ Track total focus time
* 📈 Monitor average session duration
* 💾 Persistent PostgreSQL database
* ⚡ RESTful Express API
* 🎨 Responsive React interface
* ☁️ Ready for Docker and CI/CD integration

---

# 🏗 Architecture

```text
+----------------------+
|     React Frontend   |
|      (Client)        |
+----------+-----------+
           |
      HTTP Requests
           |
           ▼
+----------------------+
|   Express Backend    |
|     REST API         |
+----------+-----------+
           |
    PostgreSQL Queries
           |
           ▼
+----------------------+
| PostgreSQL Database  |
|  Focus Sessions      |
+----------------------+
```

The application follows a **3-tier architecture**, separating the presentation layer, business logic, and data layer for better scalability and maintainability.

---

# 🛠 Tech Stack

### Frontend

* React
* Vite
* Axios
* CSS3

### Backend

* Node.js
* Express.js
* pg (PostgreSQL Client)
* dotenv
* cors

### Database

* PostgreSQL (Supabase)

### DevOps

* Git
* GitHub
* Docker (planned)
* Docker Compose (planned)
* GitHub Actions (planned)

---

# 📂 Project Structure

```text
FocusFlow/

├── frontend/
│   ├── src/
│   ├── public/
│   └── package.json
│
├── backend/
│   ├── routes/
│   ├── server.js
│   ├── db.js
│   └── package.json
│
├── database/
│   └── init.sql
│
└── README.md
```

---

# ⚙️ Installation

## 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/focusflow.git
```

---

## 2. Navigate into the project

```bash
cd focusflow
```

---

## 3. Install backend dependencies

```bash
cd backend

npm install
```

---

## 4. Create a `.env`

```env
PORT=5000

DB_HOST=YOUR_HOST

DB_PORT=5432

DB_NAME=postgres

DB_USER=YOUR_DATABASE_USER

DB_PASSWORD=YOUR_PASSWORD

NOTE:  "copy .env.example to .env and set a real password."
```

---

## 5. Start the backend

```bash
npm run dev
```

---

## 6. Install frontend dependencies

```bash
cd ../frontend

npm install
```

---

## 7. Start the frontend

```bash
npm run dev
```

---

The application will be available at:

Frontend

```text
http://localhost:5173
```

Backend

```text
http://localhost:5000
```

---

# 📡 API Endpoints

## GET

Retrieve all focus sessions.

```http
GET /api/sessions
```

---

## POST

Create a new focus session.

```http
POST /api/sessions
```

Example request body:

```json
{
  "task": "Study Docker",
  "category": "Learning",
  "duration": 90,
  "mood": "Motivated"
}
```

---

# 🗄 Database Schema

The application stores data in a table named:

```sql
focus_sessions
```

Columns include:

* id
* task
* category
* duration
* mood
* created_at

---

# 🔒 Environment Variables

The backend requires the following variables:

| Variable    | Description         |
| ----------- | ------------------- |
| PORT        | Backend server port |
| DB_HOST     | PostgreSQL host     |
| DB_PORT     | PostgreSQL port     |
| DB_NAME     | Database name       |
| DB_USER     | Database username   |
| DB_PASSWORD | Database password   |

---

# 🚀 Future Improvements

* User authentication
* Daily productivity goals
* Weekly analytics
* Calendar integration
* Session editing
* Session deletion
* Docker containerization
* GitHub Actions CI/CD pipeline
* Automated deployment
* Versioned Docker images

---

# 📷 Screenshots

Add screenshots of:

* Landing Page
* Dashboard
* Statistics Cards
* Session Form
* PostgreSQL Database
* Successful API Response

---

# 👥 Contributors

cloned this repo from the project leader before dockerisings it, writing the vm script, updated the errors gotton for the backend and frontend to work from port 5000 to port 80.
