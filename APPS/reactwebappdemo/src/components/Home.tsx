import React, { useState  } from "react";
import { Header } from "./Header";

export const Home: React.FC = () => {
  
   // const location = useLocation();
   // const user = location.state?.user;
   // console.log('User info from location state:', location);
   const user = JSON.parse(localStorage.getItem('user') || '{}');
    return (
        <div>
            <Header />
            <p>Name : {user?.fullName || 'User'}!</p>
            <p>Email: {user?.email}</p>
            <p>Username: {user?.username}</p>
        </div>
    );

//const username =  useState('Admin');

// const loadEmployeesData = () => {
//     // Dummy function to simulate loading weather data
//     return  getEmployees().then(data => {
//         console.log('Employees data loaded:', data);
//     }).catch(error => {
//         console.error('Failed to load employees data:', error);
//     });
// }
  
}

export default Home;