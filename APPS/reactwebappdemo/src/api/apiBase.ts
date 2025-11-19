import axios from 'axios';

const apiBase = axios.create({
    baseURL: process.env.REACT_APP_API_BASE_URL || 'https://localhost:63352/', // Local .NET API or set via env var
    headers: {
        'Content-Type': 'application/json',
    },
});

export default apiBase;

export const setAuthToken = (token: string | null) => {
    
    if (token) {
        apiBase.defaults.headers.common['Authorization'] = `Bearer ${token}`;   }
    else {
        delete apiBase.defaults.headers.common['Authorization'];
    }
};

export const handleApiError = (error: any) => {
    if (axios.isAxiosError(error)) {
        // Handle Axios errors
        console.error('API Error:', error.response?.data || error.message);
    } else {
        // Handle non-Axios errors
        console.error('Unexpected Error:', error);
    }
}

export const parseApiResponse = (response: any) => {
    return response.data;
}   

// You can add more utility functions as needed
// e.g., for GET, POST, PUT, DELETE requests using apiBase instance.

//GET example
export const apiGet = async (endpoint: string, params = {}) => {
    try {   
        const response = await apiBase.get(endpoint, { params });
        return parseApiResponse(response);      
    } catch (error) {
        handleApiError(error);
        throw error;
    }   
}

//POST example
export const apiPost = async (endpoint: string, data = {}) => {
    try {   
        const response = await apiBase.post(endpoint, data);
        return parseApiResponse(response);      
    } catch (error) {
        handleApiError(error);
        throw error;
    }   
}

// Similarly, you can implement apiPut, apiDelete, etc.     
//PUT example
export const apiPut = async (endpoint: string, data = {}) => {
    try {               
        const response = await apiBase.put(endpoint, data);
        return parseApiResponse(response);      
    } catch (error) {
        handleApiError(error);
        throw error;
    }   
}

//DELETE example
export const apiDelete = async (endpoint: string) => {
    try {               
        const response = await apiBase.delete(endpoint); 

        return parseApiResponse(response);
    } catch (error) {
        handleApiError(error);
        throw error;
    }
}