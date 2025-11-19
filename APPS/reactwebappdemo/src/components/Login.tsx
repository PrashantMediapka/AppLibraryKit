import React, { useState, useEffect } from 'react';
import { useNavigate  } from 'react-router-dom';
import { validateUser, setAuthData } from '../api/authServiceApi';

export const Login: React.FC = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [status, setStatus] = useState<string>('');
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        const u = username.trim();
        const p = password;
        if (!u || !p) {
            setStatus('Please enter username and password.');
            return;
        }

        setIsLoading(true);
        setStatus('Logging in...');
        
        try {
            // Call the .NET 8 Web API to validate user
            const response = await validateUser(u, p);
            console.log('Login response:', response);
            if (response.isValid && response.token && response.user) {
                  //setStatus('Login successful!');
                // Store auth data and navigate to home
                setAuthData(response.token, response.user);
                setTimeout(() => navigate('/home', { state: { user: response.user } }), 500);
            } else {
                setStatus(response.message || 'Login failed. Invalid credentials.');
            }
        } catch (error: any) {
            console.error('Login error:', error);
            setStatus(`Login error: ${error.response?.data?.message || error.message || 'Unknown error'}`);
        } finally {
            setIsLoading(false);
        }
    };

    const handleReset = () => {
        setUsername('');
        setPassword('');
        setStatus('');
    };

    const token = localStorage.getItem('authToken');
    console.log('Existing token on Login load:', token);
    useEffect(() => {
        if (token) {
            navigate('/home', { state: { user: JSON.parse(localStorage.getItem('user') || '{}') } });
        }
    }, [token, navigate]);

    if (token) {
        return <div>Redirecting...</div>;
    }

    return (
        <div>
            <h1>Login</h1>
            <form onSubmit={handleSubmit} onReset={handleReset} aria-describedby="login-status">
                <div style={{ marginBottom: 8 }}>
                    <label htmlFor="username">Username</label><br />
                    <input
                        id="username"
                        name="username"
                        type="text"
                        value={username}
                        onChange={e => setUsername(e.target.value)}
                        autoComplete="username"
                    />
                </div>

                <div style={{ marginBottom: 8 }}>
                    <label htmlFor="password">Password</label><br />
                    <input
                        id="password"
                        name="password"
                        type="password"
                        value={password}
                        onChange={e => setPassword(e.target.value)}
                        autoComplete="current-password"
                    />
                </div>

                <div id="login-status" role="status" aria-live="polite" style={{ minHeight: 20, marginBottom: 8 }}>
                    {status}
                </div>

                <div>
                    <button type="submit">Submit</button>
                    <button type="reset" style={{ marginLeft: 8 }}>Reset</button>
                </div>
            </form>
        </div>
    );
};

export default Login;