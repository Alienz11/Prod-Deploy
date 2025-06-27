# 🧩 Item Service API

A robust FastAPI service for managing items, featuring:

- Health check endpoint
- Full CRUD operations
- JSON-based storage (in-memory for simplicity)
- Unit and integration test coverage using `pytest` and `fastapi.testclient`.

## 🛠️ Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Alienz11/Prod-Deploy.git

cd Prod-Deploy
```

### 2. Create a Virtual Environment

```bash
python -m venv venv

source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r dev-requirements.txt
```

Check out contents of the [dev-requirements.txt](./dev-requirements.txt), before running the above command.

## 🚀 Run the Application

Start the FastAPIapp with:

```bash
uvicorn main:app --reload
```

This starts the development server on:

```bash
http://127.0.0.1:8000

OR

http://localhost:8000
```

## 🧪 Running Tests

### 1. Check Code Lint

```bash
flake8 .

flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
```

### 2. Format Code

```bash
black .
```

### 3. Run All Tests with pytest

```bash
pytest test.py
```

### 4. Run with Coverage

```bash
pytest test.py/ --tb=short --cov=. --cov-report=term --cov-report=xml --cov-config=.coveragerc

coverage report -m  
```

Ensure you have your the [.coveragerc](./.coveragerc) in you root directory, for more precise coverage

## Testing with Postman

You can test each endpoint usin [Postman](https://www.postman.com/)

### 📌 Base URL

```bash
http://localhost:8000
```

### ✅ Sample Endpoints

| Method | Endpoint         | Description           |
|--------|------------------|-----------------------|
| GET    | /health          | Check service status  |
| GET    | /items           | Get all items         |
| GET    | /items/{item_name}| Get one item          |
| POST   | /items           | Create a new item     |
| PUT    | /items/{item_name}| Update an existing item|
| DELETE | /items/{item_name}| Delete an item        |

### 📥 Sample JSON Body for POST / PUT

```json
{
  "name": "sample_item",
  "description": "A test item"
}
```

## 🧾 Project Structure

```txt
.
├── main.py           # FastAPI application
├── test.py           # Test cases using pytest + httpx
├── requirements.txt  # Python dependencies
├── .coveragerc       # Coverage configuration
└── APPLICATION.md         # Project documentation

```

## 🧠 Notes

- This app uses in-memory storage (items_db) for simplicity. Data resets when the server restarts.

- Logging is enabled to monitor API activity in the console.

- The app is modular and easily extendable for use with a real database.

## 🧑‍💻 Author

Kenechukwu Nnajim

GitHub: @Alienz11
