# Kurve CRUD

A simple full-stack customer management application built with Flutter (frontend) and Python Flask (backend) for the Kurve Full Stack Intern Programming Task.

## 🚀 Features

✅ Requirements Checklist
Core Features

- [x] Display a list of customers read from the database
- [x] Allow users to create new customers
- [x] Allow users to delete customers
- [x] Each customer must have:
-    [x] Name
-    [x] Age
-    [x] Email address

Bonus Features 

- [x] Use asynchronous operations where possible
- [x] Add comments to your code for clarity
- [x] Generate test data if the database is empty (Only 5)
- [x] Make the interface visually appealing
- [x] Add any other creative features or flare (Search Bar)
- [x] Host the code in a Git repository and share the link

You're reading this on GitHub!
## 📋 Requirements

### Backend
- Python 3.7+
- Flask 2.3.2
- flask-cors 4.0.0

### Frontend
- Flutter 3.0+
- Dart SDK
- http package

## 🛠️ Installation & Setup

### 1. Clone the Repository
```bash
git clone [https://github.com/yourusername/customer-management-system.git](https://github.com/Mohsin-Zeeshan/KurveCRUD.git)
```

### 2. Backend Setup

Navigate to the backend directory:
```bash
cd backend
```

Create a virtual environment (OPTIONAL):
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

Install dependencies:
```bash
pip install -r requirements.txt
```

Run the Flask server:
```bash
python app.py
```

The backend will start on `http://localhost:5000`

***USE ANOTHER TERMINAL SIMULTANEOUSLY***

### 3. Frontend Setup

Open a new terminal and navigate to the frontend directory:
```bash
cd frontend
```

Install Flutter dependencies:
```bash
flutter pub get
```

Run the Flutter app:
```bash
flutter run -d chrome 
```

Select your target device/platform when prompted.


## 📱 Usage

1. **Starting the Application**
   - First, start the backend server
   - Then run the Flutter frontend
   - The app will load with 5 sample customers

2. **Adding a Customer**
   - Click the green "Add Customer" button in the top right
   - Fill in all required fields:
     - Name (text only, no numbers)
     - Age (1-120)
     - Email (must contain @)
   - Click "Add" to save

3. **Searching for Customers**
   - Use the search bar at the top to filter customers by name
   - Search is case-insensitive and updates in real-time

4. **Deleting a Customer**
   - Click the red delete icon next to a customer
   - Confirm deletion in the dialog

## Project Structure

```
customer-management-system/
├── backend/
│   ├── app.py              # Flask API server
│   ├── requirements.txt    # Python dependencies
│   └── customers.db        # SQLite database (auto-created)
└── frontend/
    └── lib/
        └── main.dart       # Flutter application
```

## 🔍 API Endpoints

- `GET /api/customers` - Retrieve all customers
- `POST /api/customers` - Create a new customer
- `DELETE /api/customers/<id>` - Delete a customer by ID

## 💡 Technical Stack

- **SQLite Database**
- **Flask**
- **Flutter**

1.	# *What was Familiar* 
   - Coming into this project, I already had some previous experience working with Flutter for frontend development. I was comfortable building the UI on the client side. I also had experience with Python, though it had previously been used for data analysis, scripting, and backend logic in a non-web context. 

2.	# *What Was New*
   - This project introduced me to Flask as a lightweight Python web framework. It was my first time building an API using Flask, so I was still exploring while constructing the app. Another major learning curve was understanding how to connect the Flutter frontend to this new Flask backend, especially when it came to making successful API requests across different localhosts. Integrating an SQLite database with Flask was new, particularly understanding how to read, write, and manage data. 

3.	# *What I Learned*
   - This project significantly boosted my understanding of full-stack development. I learned 
       -	How Flask handles web requests, 
       -	How to configure and resolve CORS issues between the backend and frontend 
       -	How to connect the application to a database using SQLite.
       Another problem I encountered and resolved real-world challenges like the localhost vs 10.0.2.2 issue when running an emulator, which helped me develop better debugging skills. Most importantly, it set the foundation for me to solidify my understanding of how to bridge the gap between frontend and backend systems. This hands-on experience gave me the confidence to manage a complete full-stack workflow.


## 👤 Author

[Mohsin Zeeshan Syed]  
Computer Science Student @ University of Bristol
