import React from 'react';
import './App.css';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login  from './components/Login';
import Home from './components/Home';
import AboutUs from './components/AboutUs';
// Example authentication flag
const isAuthenticated = false; // change to `true` to simulate a logged-in user

// const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
//   if (!isAuthenticated) {
//     // Redirect to login if not authenticated
//     return <Navigate to="/login" replace />;
//   }
//   return <>{children}</>;
// };

function App() {
  return (
    <div className="App">
    <header className="App-header">
    <Router>     
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/home" element={<Home />} />
        <Route path="/aboutus" element={<AboutUs />} />
      </Routes>
    </Router>
    </header>
    </div>
  );
}

export default App;
