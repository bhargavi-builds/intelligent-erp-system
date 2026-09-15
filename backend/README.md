# HITAM Intelligent ERP Backend (API Gateway & Supabase Integration)

Welcome to the backend service for the **Hyderabad Institute of Technology and Management (HITAM) Intelligent ERP System**.

---

## 🏛️ Architecture Overview

```
 ┌─────────────────────────────────────────────────────────┐
 │               Flutter Multi-Platform Client             │
 │  (Android, iOS, macOS, Windows, Linux, Web Browser)     │
 └────────────────────────────┬────────────────────────────┘
                              │ HTTP REST / JSON
                              ▼
 ┌─────────────────────────────────────────────────────────┐
 │            Express.js API Gateway (Port 5050)           │
 │  - Security: Helmet, CORS, Morgan Logging               │
 │  - Smart Host Detection: Android (10.0.2.2) vs Localhost│
 │  - Dynamic Fallback: In-Memory cache if offline         │
 └────────────────────────────┬────────────────────────────┘
                              │ Supabase JS SDK
                              ▼
 ┌─────────────────────────────────────────────────────────┐
 │             Supabase Cloud PostgreSQL Database          │
 │  - RLS Security Policies                                │
 │  - Automated Foreign Keys & Indexes                     │
 │  - Tables: students, faculty, announcements, etc.       │
 └─────────────────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Node.js**: v18 or higher (v20+ recommended)
- **npm**: v9 or higher

### 2. Setup Environment Variables
Copy `.env.example` to `.env` if you haven't already:
```bash
cp .env.example .env
```
Ensure your `backend/.env` contains your Supabase credentials:
```env
PORT=5050
SUPABASE_URL=https://luzdjghixvegqlwaeyna.supabase.co
SUPABASE_ANON_KEY=your_publishable_anon_key_here
```

### 3. Install Dependencies
```bash
npm install
```

### 4. Start the Server
- **Development Mode (Auto-restart on change):**
  ```bash
  npm run dev
  ```
- **Production Mode:**
  ```bash
  npm start
  ```

Once started, the server will output:
```
=======================================================
🚀 Intelligent ERP Backend Server running on port 5050
📡 Local URL: http://localhost:5050
📱 Android Emulator URL: http://10.0.2.2:5050
🗄️  Database Mode: Live Supabase PostgreSQL
=======================================================
```

---

## 📡 API Endpoints

### 🩺 Health & Root
- `GET /` — API Information & status
- `GET /health` — Health check endpoint

### 🔐 Authentication (`/api/auth`)
- `POST /api/auth/login` — Role-based login (Student, Faculty, Parent, Admin)
- `GET /api/auth/profile` — Fetch active session profile

### 🎓 Student Operations (`/api/student`)
- `GET /api/student` or `/api/student/overview` — Dashboard summary metrics
- `GET /api/student/attendance` — Subject-wise and overall attendance
- `GET /api/student/assignments` — Pending and submitted assignments
- `GET /api/student/exams` — Upcoming exam timetable
- `GET /api/student/results` — Semester grade sheets and GPA

### 👨‍🏫 Faculty Operations (`/api/faculty`)
- `GET /api/faculty` — Faculty profile & managed courses
- `POST /api/faculty/attendance` — Mark student attendance

### 👨‍👩‍👧 Parent Operations (`/api/parent`)
- `GET /api/parent/student` — Ward's academic & attendance performance
- `GET /api/parent/fees` — Fee receipts, outstanding dues, payment status

### 🏢 Admin Operations (`/api/admin`)
- `GET /api/admin/summary` — College-wide metrics (enrollment, fee rate, faculty count)

### 📢 Announcements (`/api/announcements`)
- `GET /api/announcements` — List latest college circulars & placement notices
- `POST /api/announcements` — Post new announcement (Admin / Faculty)

---

## 📱 Connecting with Flutter Frontend

The Flutter application automatically resolves the correct backend host using [`lib/config/api_config.dart`](../lib/config/api_config.dart):
- **Android Emulator**: `http://10.0.2.2:5050`
- **iOS Simulator / macOS Desktop / Web**: `http://localhost:5050`
- **Physical Device**: Replace with your local machine's Wi-Fi IP address in `lib/config/api_config.dart`.
