# Tandem Membership Application System

A simple membership workflow system built with the Phoenix Framework framework using PostgreSQL, designed to support two distinct user roles:

* **Applicant** — submits membership applications
* **Approver** — reviews, approves, or rejects applications

The system includes full audit logging for critical actions.

---

# Tech Stack

## Backend

* Elixir `v1.20.2`
* Erlang/OTP `v27`
* Phoenix Framework
* Ecto

## Frontend

* Bootstrap

## Database

* PostgreSQL

---

# Application Architecture

The application follows Phoenix’s MVC architecture:

Request → Router → Controller → Context → Schema → Database
                           ↓
                        Templates


---

## Database Design

The system uses **three core tables**:

### 1. `tbl_users`

Stores application users.

Fields include:

* First Name
* Last Name
* Email
* Password Hash
* User Type
* User Status

---

### 2. `tbl_membership`

Stores membership applications.

Fields include:

* Title
* Category
* Description
* Amount
* Status
* Rejection_Note

Statuses:

* `UNDER_REVIEW`
* `APPROVED`
* `REJECTED`

---

### 3. `tbl_user_logs`

Stores audit logs.

Used for:

* Application submission
* Application approval
* Application rejection

This ensures traceability and accountability.

---

# User Roles

The application supports role-based access.

| User Type | Role      |
| --------- | --------- |
| `1`       | Applicant |
| `2`       | Approver  |

Both use the same authentication flow.

---

# Installation Guide

Before running the application, install:

* [Elixir and Phoenix Installation Guide](https://phoenix.hexdocs.pm/installation.html?utm_source=chatgpt.com)

Required versions:

```bash
Erlang/OTP 27
Elixir 1.20.2
```

Verify installation:

```bash
elixir --version
```

---

# Project Setup

Clone the repository:

```bash
git clone <repository_url>
cd tandem
```

Install dependencies:

```bash
mix setup
```

---

# Database Setup

Create the database:

```bash
mix ecto.create
```

Default database name: tandem_dev


This can be changed in: config/dev.exs


Run migrations:

```bash
mix ecto.migrate
```

This will create all required tables.

---

# Running the Application

Start the Phoenix server:

```bash
mix phx.server
```

Or with IEx:

```bash
iex -S mix phx.server
```

Access the application:

```text
http://localhost:4000
```

---

# Creating Seed Users

No seed file has been provided intentionally to allow flexibility.

Create users manually in IEx:

```elixir
Tandem.Accounts.create_user_accounts(%{
  first_name: "Luis Roy",
  last_name: "Zulu",
  email: "luis@mail.com",
  password: "password06",
  auto_pwd: "Y",
  user_type: 1,
  user_status: "ACTIVE",
  inserted_at: NaiveDateTime.utc_now(),
  updated_at: NaiveDateTime.utc_now()
})
```

---

## Example Approver Account

```elixir
Tandem.Accounts.create_user_accounts(%{
  first_name: "Admin",
  last_name: "User",
  email: "admin@mail.com",
  password: "password06",
  auto_pwd: "Y",
  user_type: 2,
  user_status: "ACTIVE",
  inserted_at: NaiveDateTime.utc_now(),
  updated_at: NaiveDateTime.utc_now()
})
```

---

# Unit Testing

This project includes unit tests for:

* Account creation
* Membership application creation
* Membership approval flow
* Membership rejection flow
* User log creation

Run tests:

```bash
mix test
```

Run with coverage:

```bash
mix test --cover
```

Testing framework used:

* ExUnit

---

# Key Features

* User authentication
* Role-based dashboards
* Membership application workflow
* Approval and rejection process
* Transaction-safe updates using `Ecto.Multi`
* Audit logging
* Dynamic role-based redirects
* Flash messaging
* Secure CSRF protection

---

# Design Decisions

## Transaction Safety

Critical actions use `Ecto.Multi` to ensure:

* atomic inserts
* atomic updates
* rollback on failure

---

## Role-based Logic

Role handling was intentionally simplified using integer mapping:

```text
1 → Applicant
2 → Approver
```

This keeps authorization lightweight.

---

# Assumptions

* Only authenticated users can submit applications.
* Only approvers can approve/reject applications.
* Users are pre-created by administrators or via IEx.
* Email uniqueness is enforced.
* Logs must exist for every critical business action.

---

# AI Collaboration Disclosure

During development, I collaborated with **[ChatGPT by OpenAI](https://openai.com/chatgpt?utm_source=chatgpt.com)** as an engineering assistant.

Areas where AI support was used:

* Debugging Phoenix routing issues
* Refactoring controller logic
* Improving `Ecto.Multi` transaction flow
* Fixing HEEx syntax issues
* Designing dynamic redirect logic
* Reviewing schema relationships and preload strategies
* Improving flash message handling
* Reviewing architecture and best practices
* Documentation refinement

All implementation decisions, validation, testing, and final integration were manually reviewed and executed by me.

---

# Future Improvements

* Seed scripts for faster onboarding
* Stronger authorization layer
* Pagination for application lists
* Email notifications
* Admin dashboard analytics
* Soft deletes
* API layer support

---

# Author
Luis Roy Zulu
0979797337
luiszulu6@gmail.com
