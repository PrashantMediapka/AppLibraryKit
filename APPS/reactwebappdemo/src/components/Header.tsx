import userEvent from "@testing-library/user-event";
import  React  , {useEffect }from "react";
import { Link } from 'react-router-dom';

export const Header: React.FC = () => {
       const token = localStorage.getItem('authToken');
        console.log('Existing token on Login load:', token);
        const user = JSON.parse(localStorage.getItem('user') || '{}');

    return (
        user && user.fullName ? (
            <div>                 
                <nav style={{ padding: '1rem', background: '#978e8eff' }}>
                    <div>Welcome {(user)?.fullName || 'User'}!</div>
                    <div><Link to={"/home"} style={{ marginRight: '1rem' }}>Home</Link>
                    <Link to="/aboutus" style={{ marginRight: '1rem' }}>AboutUs</Link>
                    <Link
                        to="/login"
                        style={{ marginRight: '1rem' }}
                        onClick={() => {
                            localStorage.removeItem('authToken');
                        }}
                    >Sign Out
                    </Link></div> 
                </nav>
            </div>
        ) : (
            <div>No User found...</div>
        )
    );
}

export default Header;